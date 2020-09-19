/*
  sound - spectro kalidastrip

  This pattern is designed to use the sensor expansion board, but falls back to
  simulated sound data if the sensor board isn't detected.

  This pattern uses the different frequencies in sound (e.g. bass vs mids vs
  treble) and compares the current reading for each of the 32 frequency bins to
  its running average. When the current reading is high, it's plotted against a
  section of the strip. This approach results in a visual pattern that's more
  expressive and responsive to changes in the sensed audio.

  There are four examples to choose between that remap the pixels so we can
  project the sensed spectrum onto their 1D space. The default remapping
  projects a spectrum and its twin into each of 4 mirrored sections, creating a
  1D kaleidoscope effect.

  Please check out the "sound - blink fade" pattern for more verbose comments
  explaining the PI controller used below for automatic gain control. 
*/

/*
  These vars are set by the external sensor board, if one is connected. We
  don't actually use light readings in this pattern, so if the `light` value
  remains -1, no sensor board is connected. If connected, the sensor board sets 
  the 32 frequencyData array elements according to sensed spectrum energy.
*/
export var light = -1 
export var frequencyData = array(32)

// To tell if we should emphasize a frequency, we will compare it to it's
// average value over this many milliseconds.
averageWindowMs = 1500
speed = 2  // Seconds between cycles

// The PI controller will adjust it's sensitivity to loudness until the average
// pixel brightness value is targetFill
targetFill = .2

// Store the sum of all brightness values in the strip, to feed back to the PI 
// // controller
brightnessFeedback = 0

// The averages array will store the average of each frequency bin's readings 
// over the last averageWindowMs
averages = array(32)
pixels = array(pixelCount)

/*
  As described in the "sound - blink fade" pattern, you can add "export var" and
  inspect this to tune it. If pic[2] converges to 400 (the max) then the input
  is so soft that the PI controller has raised the sensitivity gain all the way
  it can, and the patteren may still be dark as a result.
*/
pic = makePIController(.2, .15, 50, 0, 400)

// Makes a new PI Controller
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
  return max(pic[0] * err + pic[1] * pic[2], .3)
}

export function beforeRender(delta) {
  sensitivity = calcPIController(pic, 
                  targetFill - brightnessFeedback / pixelCount)
  brightnessFeedback = 0
  t1 = time(speed / 65.536)

  /*
    To calculate and store the average of each frequency bin's readings over the
    last averageWindowMs, first we figure out how long the last frame took to
    render and divide it by our desired averaging window length. This gives us
    the weight we will apply to this particular sample, compared to all prior
    readings for a particular bin, which are already averaged in averages[].
    This is also known as an exponential moving average (like a single pole
    filter), and technically includes a component of all prior samples but has
    the benefit of requiring low storage.
  */
  dw = delta / averageWindowMs
  
  // If no sensor board is attached, simulate sensor data at 40Hz
  if (light == -1) doAt(40, delta, simulateSound)
  
  // For each frequency bin
  for (i = 0; i < 32; i++) {
    // Calculate the average as the rolling weighted average, applying a .0001
    // minimum energy to each frequency. Note that this means the pattern takes
    // at least averageWindowMs at startup to stabilize, not including the
    // additional time that the PI controller can take to converge on an
    // appropriate sensitivity.
    averages[i] = max(.0001, 
                  averages[i] * (1 - dw) + frequencyData[i] * dw * sensitivity)
  }
}

// Given a decimal index i, interpolate between subsequent values in an array.
// We'll use this to smoothly render 32 frequency bins across many more pixels.
function arrayLerp(arr, i) {
  var ifloor, iceil, ratio  // `var` declares these as local to this function
  ifloor = floor(i)
  iceil = ceil(i)
  ratio = i - ifloor
  return arr[ifloor] * (1 - ratio) + arr[iceil] * ratio
}

export function render(index) {
  var i, h, s, v

  /*
    Remap pixel index space into a decimal value `i` (in 0..31) that we'll use
    to index into our 32 element frequencyData array.
  
    It may help to understand them by playing a frequency sweep such as
    https://open.spotify.com/track/7wAvDQRFwahDUZPp5RzLTM and connecting it to
    the sensor board via the line-in jack for a clean signal.

    Then try any of the following:
  */

  // Static spectrum analyzer, low frequencies will be near index 0
  // i = 31 * index / pixelCount
  
  // Mirrored around the center
  // i = 31 * triangle((index + pixelCount / 2) / pixelCount)
  
  // Quick bounce
  // i = 31 * (index / pixelCount + wave(2 * t1)) % 31
  
  // Two spectrums, advancing with time, in mirrored quadrants
  i = 31 * triangle(triangle(2 * index / pixelCount) + t1) 

  /*
    This is the core of what's happening. Compute the difference between the 
    current frequencies in a bin and that's bin's average energy over
    averageWindowMs. That difference is scaled by the current sensitivity and
    then partially by how much energy there usually is in this frequency.
  */
  v = (arrayLerp(frequencyData, i) * 4 * sensitivity - arrayLerp(averages, i)) *
      (arrayLerp(averages, i) * 1000 + .5)
  v = v > 0 ? v * v : 0  // Only keep positive values of v, and γ-correct them 
  
  s = 2 - v // Turn high v into white (when v > 1)
  
  h = i / 31 + index / pixelCount / 4
  
  // Decay each pixel's brightness by 25% per frame and re-add the calculated v
  pixels[index] = pixels[index] * .75 + v
  v = pixels[index]
  
  // Feedback to the PI contoller to normalize the strip's overall brightness
  brightnessFeedback += clamp(v, 0, 1)
  hsv(h, s, v)
}

// Call a function `fn` at a specified freqency, given ms elapsed `delta`
var accumDelta = 0

function doAt(hertz, delta, fn) {
  accumDelta += delta // Accumulated miliseconds
  if (accumDelta <= 1000 / hertz) {  // Sensor board updates at 40Hz
    return // No need to recompute simulated sound
  } else {
    accumDelta -= 1000 / hertz // Assumes `delta < 1000 / hertz`` on average
    fn()
  }
}

/*
  Simulate the sensor board variables used in this pattern, if no senor board is
  detected. The values and waveforms were chosen to approximate the look when
  real sound is sensed for a basic 4-on-the-floor loop.
*/
BPM = 120
var measurePeriod = 4 * 60 / BPM / 65.536

function simulateSound() {
  tM = time(measurePeriod) // 2 seconds per measure @120 BPM
  tP = time(8 * measurePeriod) // 8 measures per phrase
  for (i = 0; i < 32; i++) frequencyData[i] = 0
  
  beat = (-4 * tM + 5) % 1 // 4 attacks per measure
  beat *= .02 * pow(beat, 4)  // Scale magnitute and make concave-up
  // Splay energy out, most energy at lowest frequency bins
  for (i = 0; i < 10; i++) frequencyData[i] += beat * (10 - i) / 10

  claps = .006 * square(2 * tM - .5, .10) // "&" of every beat
  for (i = 9; i < 14 + random(5); i++) 
    frequencyData[i] += claps * (.7 + .6 * random(i % 2))

  highHat = .01 * square(4 * tM - .5, .05) // Beats 2 and 4
  for (i = 18; i < 20; i++) frequencyData[i] += highHat * (.8 + random(.4))

  lead = 4 + floor(16 * wander(tP))  // Wandering fundamental synth's freq bin
  for (i = 4; i < 20; i++)
    // Excite the fundamental and, 40% of the time, 4 bins up
    frequencyData[i] += .005 * (lead == i || lead == (i - 4) * r(.4))
}

// Random-ish perlin-esque walk for t in 0..1, outputs 0..1
// https://www.desmos.com/calculator/enggm6rcrm
function wander(t) {
  t *= 49.261 // Selected so t's wraparound will have continuous output
  return (wave(t / 2) * wave(t / 3) * wave(t / 5) + wave(t / 7)) / 2
}

function r(p) { return random(1) < p } // Randomly true with probability p
