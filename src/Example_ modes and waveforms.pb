/*
 * In this example you'll see:
 * - Using an array to switch between modes
 * - Lambda style function expressions
 * - Different waveform functions and combinations
 * - Accumulating delta to make a mode switch timer
 * - Using UI controls
 */
 
// Keep track of how many modes there will be
numModes = 13
modes = array(numModes) // Make an array to store the modes

// Make a bunch of lambda style mode functions and put them in the modes array
// f is expected to be in 0..4
modes[0] = (f) => f % 1 // This will just cause any numbers above 1.0 to wrap around
modes[1] = (f) => triangle(f) // triangle has a linear slope
modes[2] = (f) => wave(f) // wave uses the sin to create rounded slopes
modes[3] = (f) => square(f, .5) // A square wave is just on or off and has no transition
modes[4] = (f) => triangle(triangle(f)) // Combining wave functions can create interesting effects
modes[5] = (f) => wave(triangle(f))
modes[6] = (f) => triangle(wave(f))
modes[7] = (f) => wave(wave(f))
modes[8] = (f) => square(wave(triangle(f)), .7) // Here we've made a dash-dot-dash pattern
modes[9] = (f) => wave(f) * triangle(f * 1.3) // By multiplying waveforms, we get a darken effect
modes[10] = (f) => (wave(f*1) + triangle(f * 3.3)) / 2 // Blend waveforms by averaging them
modes[11] = (f) => triangle(f*2) - wave(f * 1.5) // Subtraction can create interesting interference patterns
modes[12] = (f) => abs(triangle(f) - wave(f * 2)) // Subtraction with absolute value gives a distance

timer = 0 // Accumulate all the deltas each animation frame
mode = 0 // Start with mode 0

// To create a UI slider control in the Pixelblaze IDE, write an event handler 
// that starts with "slider". All UI handlers in a parrtern are called when 
// *any* UI control changes. The value passed into this function will be between
// 0 and 1. Sliders remember their position.
var s = 0 // Default to white
export function sliderSaturaton(v) { s = v }

// To create a color picker UI control, write an event handler that starts with 
// "hsvPicker" or "rgbPicker". The first argument to the handler will be the hue.
// Here we discard the saturation and brightness value that are also passed in.
// The underscore just differentiates the local var _h from the global h.
var h = 0
export function hsvPickerHue(_h, _s, _v) { h = _h }

// The beforeRender function is called once before each animation frame
// and is passed a delta in fractional milliseconds since the last frame.
// This has very high resolution, down to 6.25 nanosecons!
export function beforeRender(delta) {
  timer += delta // Accumulate all the deltas into a timer
  if (timer > 600) { // After 600ms, rewind the timer and switch modes
    timer -= 600
    mode = (mode + 1) % numModes // Go to the next mode, and keep between 0 and numModes
  }
  
  // Uncomment this line to check out a specific mode
  // mode = 0
}

// The render function is called for every pixel. Here we're going to use 
// the pixel's index to make a number between 0.0 and 4.0. This acts as a 4X 
// frequency modifier, repeating the pattern 4 times across the strip length.
// That 0-4 value is passed in to the current mode function and its output is 
// used to set the pixel's hue. hsv() "wraps" hue between 0.0 and 1.0.
export function render(index) {
  // Look up the current mode function and call it
  v = modes[mode](4 * index / pixelCount)
  hsv(h, s, v)
}