/*
  sound - spectromatrix

  This pattern is designed to use the sensor expansion board, but falls back to
  simulated sound data if the sensor board isn't detected.
  
  It also supports pixel mapped configurations with 2D or 3D maps. See how this
  pattern renders on a 3D walled cube:

  https://youtu.be/p1D3RK4Kxf4

  This pattern uses the different frequencies in sound (e.g. bass vs mids vs
  treble) and compares the current reading for each of the 32 frequency bins to
  its running average. When the current reading is high, it's projected onto
  certain sections of the strip, matrix, or 3D space. 

  This pattern builds heavily on components commented in "sound - blink fade"
  and "sound - spectro kalidastrip", so if you find it hard to follow, first 
  start there!
*/

/*
  These vars are set by the external sensor board, if one is connected. We
  don't actually use light readings in this pattern, so if the `light` value
  remains -1, no sensor board is connected. If connected, the sensor board sets 
  the 32 frequencyData array elements according to sensed spectrum energy.
*/
export var light = -1 
export var frequencyData = array(32)

// These config variables are only needed for 2D pixel matrices when no 2D map
// is defined in the mapper tab
width = 8
height = pixelCount / width
zigzag = true  // Many 2D LED matrices are wired in a zig-zag pattern 

// These variables control the character of the visualization itself
averageWindowMs = 500  // Compare spectrum energy to it's avg over this period
fade = .6  // What percentage of the pixel's brightness is retained each frame
speed = 1  // Speed of viewport travel through the spectrum field
zoom = .3  // .01 => zoomed way in; 10 => zoomed far out
targetFill = 0.15  // Seek a sensitivity that makes this the average light fill

var pic = makePIController(1, .1, 300, 0, 300)
var sensitivity = 0
brightnessFeedback = 0
vals = array(32)
averages = array(32)
pixels = array(pixelCount)


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
  return max(pic[0] * err + pic[1] * pic[2],.3)
}

export function beforeRender(delta) {
  sensitivity = calcPIController(pic, targetFill - brightnessFeedback / pixelCount)
  brightnessFeedback = 0
  t1 = time(6.6 / 65.536)
  t2 = time(39 / 65.536)
  wt1 = wave(t1 * speed)

  // If no sensor board is attached, simulate sensor data at 40Hz
  if (light == -1) doAt(40, delta, simulateSound)
  
  dw = delta / averageWindowMs
  
  for (i = 0; i < 32; i++) {
    averages[i] = max(.00001, 
      averages[i] * (1 - dw) + frequencyData[i] * dw * sensitivity)

    // Notice that we do not implement arrayLerp() as in "sound - spectro 
    // kalidastrip", and as a result this pattern trades some smoothing for
    // faster frame rates.
    vals[i] = (frequencyData[i] * sensitivity - 2 * averages[i]) * 10 * 
                (1 + averages[i] * 1000)
  }

}

// The fundamental rendering happens in 3D space, but will be projected down
// into lower dimensions for 2D matrices or 1D strips
export function render3D(index, x, y, z) {
  var i, h, s, v
  
  // Given the pixel's 3D position and the timers, i will be a decimal position
  // in the 32 frequency bins
  i = 31 * triangle(
           (wave((x + z) * zoom + wt1) + wave((y + z) * zoom - wt1)) * .5 + t2)

  v = vals[i] // i is implicitly truncated (like floor(i)) for an array index
  v = v > 0 ? v * v : 0
  
  s = 2 - v

  // The hue range is frequency-based, using half the rainbow, and cycling
  // around the hue wheel every 6.6 second
  h = i / 64 + t1  
  pixels[index] = pixels[index] * fade + v
  v = pixels[index]

  brightnessFeedback += clamp(v, 0, 1)
  hsv(h, s, v)
}

// Support 2D pixel mapped configurations
export function render2D(index, x, y) {
  render3D(index, x, y, 0)
}

/*
  This pixel mapper shim provides support for 1D strips and unmapped 2D matrices
  by calculating x & y assuming a 2D LED matrix display, given a matrix width
  and height.
*/
export function render(index) {
  var y = floor(index / width)
  var x = index % width

  if (zigzag) x = (y % 2 == 0 ? x : width - 1 - x)
  x /= width
  y /= height
  render2D(index, x, y)
}

// doAt calls a function `fn` at a specified freqency, given ms elapsed `delta`
// For example, simulate sensor board data updates at 40Hz.
var accumDelta = 0

function doAt(hertz, delta, fn) {
  accumDelta += delta // Accumulated miliseconds
  if (accumDelta <= 1000 / hertz) {
    return // Do nothing
  } else {
    accumDelta -= 1000 / hertz // Assumes `delta < 1000 / hertz`` on average
    fn() // Call the passed-in function
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
