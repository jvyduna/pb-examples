/*
  sound - Pew-Pew-Pew!

  Pew-pew-pew is one of the most popular user-submitted patterns on the
  community pattern library, for good reason. It was one of the first Pixelblaze 
  patterns to illustrate bitwise packing, passing functions as arguments, and
  lightweight 1D particle physics. Who doesn't love an array of lasers?

  If the Pixelblaze Sensor Expansion Board is connected, the blue component
  reacts to sound.

  Original Author: Scott Balay 
  https://www.scottbalay.com/
  https://github.com/zenblender/pixel-blaze-patterns
*/


// User variables. These were set for a 150-LED strip; you can adjust the 
// settings to your liking.

/*
  A laser is a pulse travelling down the strip. When a laser passes the end,
  it's respawned. `laserCount` sets how many lasers are present at once on
  the strip. Use a multiple of numPaletteRGBs to have each available color
  represented equally.
*/
laserCount = 5

// Laser speed. Try values between 0.1 and 10.
speedFactor = 1

// Each frame we'll multiply each pixel's brightness by fadeFactor (try values 
// between 0.5 abd 0.99). Higher values create longer tails.
fadeFactor = 0.9

// Higher values are more dramatically responsive to sound
soundLevelPowFactor = 1.2

// When useBlueLightning is true, lasers being respawned cause the entire strip
// to flash blue. Consider disabling if you're using the sound sensor board.
useBlueLightning = true

// Flip to run backwards
isForwardDirection = true

// Ambient color added to all LEDs to provide a base color
ambientR = 15
ambientG = 0
ambientB = 0


// Adjust the user parameters specified above

// Slow lasers inherently need slower fades
fadeFactor = pow(fadeFactor, speedFactor)
// To effectively scale delta (which is in ms per frame) into the number of
// pixels to advance a laser by, we need to scale it. Delta is typically between
// 5ms and 30ms, depending on Pixelblaze HW and the number of pixels.
speedFactor /= 100


// Initialize a palette of available colors, specified in RGB
numPaletteRGBs = 5
paletteRGBs = array(numPaletteRGBs)
paletteRGBs[0] = packRGB(255, 13, 107)
paletteRGBs[1] = packRGB(232, 12, 208)
paletteRGBs[2] = packRGB(200, 0,  255)
paletteRGBs[3] = packRGB(124, 12, 232)
paletteRGBs[4] = packRGB(70,  13, 255)


function getRandomVelocity() { return random(4) + 3 }

// Initialize the RGB color of each laser
laserRGBs = createArray(laserCount, 
              function(i) { return paletteRGBs[i % numPaletteRGBs] }, true)

// Initialize randomized starting position for each laser
laserPositions = createArray(laserCount, 
                   function() { return random(pixelCount) }, true)

// Initialize each laser's velocity. This shows the anonymous short lambda syle.
laserVelocities = createArray(laserCount, 
                    () => { return getRandomVelocity() }, true)

// Initialize the full pixel array
pixelRGBs = createArray(pixelCount)


// Calculate sound

/*
  This exported variable is set by the external sensor board, if one is
  connected. The loudness of the strongest frequency is stored in
  `maxFrequencyMagnitude`, and it's smallest sensed value is zero. It's
  initialized here to an "impossible value" of -1. If it remains -1 in
  beforeRender(), then we know that a sensor board is not connected.
*/
export var maxFrequencyMagnitude = -1

soundLevelVal = 0

// Using a PI controller to autoscale sound readings is well documented in the
// "sound - blinkfade" pattern
pic = makePIController(.05, .35, 30, 0, 400)

function makePIController(kp, ki, start, min, max) {
  var pic = array(5)
  pic[0] = kp
  pic[1] = ki
  pic[2] = start
  pic[3] = min
  pic[4] = max
  return pic
}

function calcPIController(pic, err) {
  pic[2] = clamp(pic[2] + err, pic[3], pic[4])
  return pic[0] * err + pic[1] * pic[2]
}


export function beforeRender(delta) {
  // Recall that the exported `maxFrequencyMagnitude` is set above to -1 in the
  // absence of a sensor board
  sensorBoardConnected = (maxFrequencyMagnitude >= 0)  
  
  if (sensorBoardConnected) {
    // Use the PI controller to set `sensitivity` in a way that seeks a desired
    // `soundLevelVal` of 0.5
    sensitivity = calcPIController(pic, .5 - soundLevelVal)

    // Instead of using overall loudness, use the strongest frequency's energy
    soundLevelVal = pow(maxFrequencyMagnitude * sensitivity, 
                        soundLevelPowFactor)
  }

  // Fade existing pixels
  for (i = 0; i < pixelCount; i++) {
    pixelRGBs[i] = packRGB(
      floor(getR(pixelRGBs[i]) * fadeFactor),
      floor(getG(pixelRGBs[i]) * fadeFactor),
      floor(getB(pixelRGBs[i]) * fadeFactor)
    )
  }

  // Advance laser positions
  for (laserIndex = 0; laserIndex < laserCount; laserIndex++) {
    currentLaserPosition = laserPositions[laserIndex]
    nextLaserPosition = currentLaserPosition + 
                        delta * speedFactor * laserVelocities[laserIndex]
    
    // Draw new laser edge, but fill in "gaps" from last draw
    for (i = floor(nextLaserPosition); i >= currentLaserPosition; i--) { 
      if (i < pixelCount) {
        pixelRGBs[i] = packRGB(
          min(255, getR(pixelRGBs[i]) + getR(laserRGBs[laserIndex])),
          min(255, getG(pixelRGBs[i]) + getG(laserRGBs[laserIndex])),
          min(255, getB(pixelRGBs[i]) + getB(laserRGBs[laserIndex]))
        )
      }
    }

    laserPositions[laserIndex] = nextLaserPosition
    if (laserPositions[laserIndex] >= pixelCount) {
      // Respawn this laser back at the start
      laserPositions[laserIndex] = 0
      laserVelocities[laserIndex] = getRandomVelocity()
    }
  }
}

export function render(rawIndex) {
  index = isForwardDirection ? rawIndex : (pixelCount - rawIndex - 1)
  
  rgb(
    (getR(pixelRGBs[index]) + ambientR) / 255,
    (getG(pixelRGBs[index]) + ambientG) / 255,
    (getB(pixelRGBs[index]) +                        // Lasers' blue values
      (useBlueLightning ? getB(pixelRGBs[0]) : 0) +  // Blue lighting on respawn
      soundLevelVal * 255 +                          // Add blue for sound
      ambientB                                       // Add ambient blue
    ) / 255
  )
}


// Utilities

// Array initialization
function createArray(size, valueOrFn, isFn) {
  arr = array(size)
  if (!valueOrFn) return arr
  for (i = 0; i < size; i++) {
    arr[i] = isFn ? valueOrFn(i) : valueOrFn
  }
  return arr
}

// RGB functions 
// Assume each component is an 8-bit "int" (0-255)
function packRGB(r, g, b) { return _packColor(r, g, b) }
function getR(value) { return _getFirstComponent(value) }
function getG(value) { return _getSecondComponent(value) }
function getB(value) { return _getThirdComponent(value) }

// HSV functions 
// Assume each component is an 8-bit "int" (0-255)
function packHSV(h, s, v) { return _packColor(h, s, v) }
function getH(value) { return _getFirstComponent(value) }
function getS(value) { return _getSecondComponent(value) }
function getV(value) { return _getThirdComponent(value) }

// "Private" color functions
// Assume each component is an 8-bit "int" (0-255)
function _packColor(a, b, c) { return (a << 8) + b + (c >> 8) }
function _getFirstComponent(value)  { return (value >> 8) & 0xff } // R or H
function _getSecondComponent(value) { return  value       & 0xff } // G or S
function _getThirdComponent(value)  { return (value << 8) & 0xff } // B or V
