/*
 * In this example you'll see:
 * - time and animation
 * - using an array to switch between modes
 * - lambda style function expressions
 * - Another way to make a mode switch timer
 */

var t2 // Declare this variable here so we can reference it in our mode functions

// Keep track of how many modes there will be
numModes = 14
modes = array(numModes) // Make an array to store the modes

// Make a bunch of lambda style mode functions and put them in the modes array
// f is expected to be in 0..4
modes[0] = (f, t) => (f + t) % 1 // Moving left
modes[1] = (f, t) => (1 + f - t) % 1 // Moving right
modes[2] = (f, t) => (f + triangle(t)) % 1 // Bounce back and forth
modes[3] = (f, t) => (f + wave(t)) % 1 // Smooth back and forth
modes[4] = (f, t) => square(f + t, .5) // A chaser 
modes[5] = (f, t) => (f + triangle(triangle(t) * t)) % 1 // Combining wave functions can create interesting effects
modes[6] = (f, t) => (f + wave(wave(t))) % 1 // Warbly movemovent
modes[7] = (f, t) => square(triangle(wave(t)) + f, .5) // Bouncing
modes[8] = (f, t) => wave(f + t) * wave(f + t2) // Times with different intervals create interesting waveform interactions
modes[9] = (f, t) => wave(wave(f + t) + wave(f - t2) + f - t) // Wave textures
modes[10] = (f, t) => wave(f + wave(wave(t) + f / 4)) // Stretchy efect
modes[11] = (f, t) => wave((f - 2) * (1 + wave(t))) * wave(wave(t2) + f) // Zoomed and blended
modes[12] = (f, t) => 2 * triangle(f + wave(t)) - wave(f * .75 + wave(t2)) // Kinetic
modes[13] = (f, t) => abs(triangle(f - triangle(t2)) - wave(f * 2 + triangle(t))) // Glitch conveyer belt

mode = 0 // Start with mode 0. Remember you can prepend "export var" to use the Var Watch.

// The beforeRender function is called once before each animation frame
// and is passed a delta in fractional milliseconds since the last frame.
// This has very high resolution, down to 6.25 nanosecons!
export function beforeRender(delta) {
  t = time(.05)  // Loops 0..1 about every 3.3 seconds
  t2 = time(.03) // Loops 0..1 about every 1.3 seconds
  modeT = time(numModes * 0.6 / 65.536) // 600ms per mode, so 0..1 every numModes * 0.6 seconds
  mode = floor(modeT *  numModes) // mode will be 0, 1, 2, etc up to (numModes - 1)

  // Uncomment this line to check out a specific mode
  // mode = 12
}

// The render function is called for every pixel. Here we're going to use 
// the pixel's index to make a number between 0.0 and 4.0. This acts as a 4X 
// frequency modifier, repeating the pattern 4 times across the strip length.
// That 0-4 value is passed in to the current mode function and its output is 
// used to set the pixel's hue. hsv() "wraps" hue between 0.0 and 1.0.
export function render(index) {
  // Look up the current mode function and call it
  v = modes[mode](4 * index / pixelCount, t)
  hsv(0, 0, v)
}