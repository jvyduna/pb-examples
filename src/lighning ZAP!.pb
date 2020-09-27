/*
  Lightning ZAP!
  
  This pattern was for a Halloween installation of bifurcated strips that split
  off to took like lightning bolts. While many examples show smooth wave
  functions, this example shows one way to work with bigger chunks of time.
  
  Strips: https://www.instagram.com/p/B4F-93EBNVV/
  Installed: https://www.instagram.com/p/B4TuvDSBXHl/
*/

// Set up each bolt segment to be between 1/15th and 1/6th of the strip length
boltMin = floor(pixelCount / 15)
boltMax = ceil(pixelCount / 6)
delayFactor = 15  // Determines the time between successive bolt segments
resetDelayFactor = 1000 // Determines the pause between complete lightning bolts
fade = 15  // How fast each lightning bolt section fades out

pixels = array(pixelCount)
x = 0
timer = 0

export function beforeRender(delta) {
  // Most frames we are fading all pixels and counting down a timer
  for (i = 0; i < pixelCount; i++)
    pixels[i] -= (pixels[i] * fade * (delta / 1000)) + (1 >> 16)
  
  // `timer` is the ms remaining before we ignite a new lightning bolt section
  timer -= delta
  
  if (timer <= 0) {
    // New lightning bolt segment's size, in pixels
    boltSize = boltMin + random(boltMax - boltMin)
    while (boltSize-- > 0 && x < pixelCount) {
      pixels[x++] = 1  // Fill these pixels bright white
    }

    timer = random(delayFactor) + delayFactor / 5
    // Squaring makes longer delays, and makes them rarer. A delayFactor of 15
    // produces 9ms-324ms timers between successive bolt segments igniting.
    timer *= timer 
    
    // If a lightning bolt has reached the end of the strip,
    if (x >= pixelCount) {
      x = 0
      // Pause between bolts for 0.33-1.33 * resetDelayFactor milliseconds
      timer = random(resetDelayFactor) + resetDelayFactor/3
    }
  }
}

export function render(index) {
  v = pixels[index]
  hsv(2/3, 0, v)
}
