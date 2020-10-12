/*
  Sound - Spectrum Analyser 1D/2D
  
  Output demo: https://youtu.be/sZIZiAt9l4o
  (You can connect multiple Pixelblaze to a single sensor expansion board.)
  
  This pattern requires the sensor expansion board and a 2D LED matrix.
  It displays a spectrum analyser based on the frequency data from the
  microphone. This is a real time graph where the low frequencies are plotted 
  on the left hand side, and higher frequencies are on the right.
  
  This pattern is meant to be displayed on an LED matrix or other 2D surface 
  defined in the Mapper tab. Using the computer graphics convention, (x, y) = 
  (0, 0) is the top left (positive y advances downwards.) You will also need to
  set the 'width' variable below to match the width of your matrix.
  
  There's also a 1D fallback and a spectrum simulator used when the sensor board
  is not detected.
  
  Generously contributed by ChrisNZ (Chris) from the Pixelblaze forums.
    https://forum.electromage.com/u/chrisnz
*/

// Set this to the width of your 2D display, or number of frequency bars to plot
width = 16
height = pixelCount / width

// Set the hue, saturation, and value for peak value indicators.
// E.g. For white peaks, set peakHSV[1] = 0. No peaks, set peakHSV[2] = 0
peakHSV = array(3)  // [h, s, v]
peakHSV[0] = 0; peakHSV[1] = 1; peakHSV[2] = 1


// Get frequency information from the sensor expansion board
export var frequencyData = array(32)
// Start with an impossible value to detect if the sensor board is connected
export var light = -1 

// Peak values for each bar, in the range 0..`height`
peaks = array(width)
// Current frequency values for each bar, in the range 0..`height`
fy = array(width)     
peakDropMs = 0  // This will accumulate `delta` to drop our peaks by a pixel

// Automatic gain / PI controller. See comments in "sound - blinkfade".
targetMax = .9       // Aim for a maximum bar of 90% full
// Approx rolling average of the maximum bar, for feedback into the PIController
averageMax = 0
pic = makePIController(.25, 1.8, 30, 0, 100)

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
  // Calculate sensitivity based on how far away we are from our target maximum
  sensitivity = max(1, calcPIController(pic, targetMax - averageMax))

  hueT = time(1 / 65.536)  // 1 second hue rotation
  
  peakDropMs += delta

  // Drop all the peaks every 100ms
  if (peakDropMs > 100) {
    peakDropMs = 0
    for (i = 0; i < width; i++) peaks[i] -= 1
  }

  if (light == -1) simulateSound() // `light` is >= 0 if the SB is connected
  
  currentMax = 0
  for (i = 0; i < width; i++) {
    logy = log(i / width + 1) // Plot lower bins (log of 2 = bottom 30%)
    // Determine the portion of the bar filled based on the current sound level.
    // We use the PIController sensitivity to try and keep this at the targetMax
    powerLevel = frequencyData[logy * 32] * sensitivity
    fy[i] = floor(min(1, powerLevel) * height)
    peaks[i] = max(peaks[i], fy[i] - 1)

    currentMax = max(currentMax, powerLevel)
  }
  averageMax = averageMax - (averageMax / 50) + (currentMax / 50)
}

export function render2D(index, x, y) {
  xPixel = floor(x * width)  // Converts 0..1 'world units' x into pixel width
  yPixel = height - 1 - floor(y * height) // Invert so baseline is yPixel == 0

  h = hueT + x // Cycle the bar color through the rainbow. hsv() 'wraps' h.
  s = 1
  v = fy[xPixel] > yPixel  // Fill bars from 0..fy[xPixel]
  
  // If this is a peak pixel, apply the peakHSV color
  if (peaks[xPixel] == yPixel) {
    h = peakHSV[0]; s = peakHSV[1]; v = peakHSV[2]
  }
  
  hsv(h, s, v)
}

// The 1D fallback plots the raw 32-bin spectrum across all pixels in a strip
export function render(index) {
  h = hueT + index/pixelCount // Cycle bar color. Remember, hsv() 'wraps' h.
  
  // Spread all 32 bins across the strip and interpolate
  binPixelWidth = pixelCount / 31
  LBin = floor(index / binPixelWidth)
  RBinPct = (index % binPixelWidth) / binPixelWidth
  v = (1 - RBinPct) * frequencyData[LBin] + RBinPct * frequencyData[LBin + 1]
  v *= sensitivity // Scale by PI controller's sensitivity

  hsv(h, 1, v * v)
}


/*
  Simulate the sensor board variables used in this pattern, if no sensor board
  is detected. The values and waveforms were chosen to approximate the look when
  real sound is sensed for a basic 4-on-the-floor loop.
*/
BPM = 120
var measurePeriod = 4 * 60 / BPM / 65.536

function simulateSound() {
  tM = time(measurePeriod) // 2 seconds per measure @120 BPM
  tP = time(8 * measurePeriod) // 8 measures per phrase
  for (i = 0; i < 32; i++) frequencyData[i] = 0
  
  beat = (-4 * tM + 5) % 1 // 4 attacks per measure
  beat *= .02 * pow(beat, 4)  // Scale magnitude and make concave-up
  // Splay energy out, most energy at lowest frequency bins
  for (i = 0; i < 10; i++) frequencyData[i] += beat * (10 - i) / 10

  claps = .01 * square(2 * tM - .5, .10) // "&" of every beat
  for (i = 9; i < 14 + random(10); i++) 
    frequencyData[i] += claps * (.7 + .6 * random(i % 2))

  highHat = .003 * square(4 * tM - .5, .05) // Beats 2 and 4
  for (i = 20; i < 30; i++) {
    frequencyData[i] += highHat * (.8 + random(.4)) * (i % 3 < 2)
  }

  lead = 4 + floor(16 * wander(tP))  // Wandering fundamental synth's freq bin
  for (i = 4; i < 20; i++)
    // Excite the fundamental and, 20% of the time, 4 bins up
    frequencyData[i] += .005 * (lead == i || lead == (i - 4) * r(.2))
}

// Random-ish perlin-esque walk for t in 0..1, outputs 0..1
// https://www.desmos.com/calculator/enggm6rcrm
function wander(t) {
  t *= 49.261 // Selected so t's wraparound will have continuous output
  return (wave(t / 2) * wave(t / 3) * wave(t / 5) + wave(t / 7)) / 2
}

function r(p) { return random(1) < p } // Randomly true with probability p