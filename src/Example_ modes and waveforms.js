/*
  In this example you'll see:
  - Using an array to switch between modes
  - Lambda style function expressions
  - Different waveform functions and combinations
  - Accumulating delta to make a mode switch timer
  - Creating and using UI controls
*/
 
// Keep track of how many modes there will be
numModes = 13
modes = array(numModes) // Make an array to store the modes

// Make a bunch of lambda style mode functions and put them in the modes array
// f is expected to be in 0..frequency 
modes[0]  = (f) => f % 1 // This will just cause any numbers above 1.0 to wrap around
modes[1]  = (f) => triangle(f) // triangle has a linear slope
modes[2]  = (f) => wave(f) // wave uses the sin to create rounded slopes
modes[3]  = (f) => square(f, .5) // A square wave is just on or off and has no transition
modes[4]  = (f) => triangle(triangle(f)) // Combining wave functions can create interesting effects
modes[5]  = (f) => wave(triangle(f))
modes[6]  = (f) => triangle(wave(f))
modes[7]  = (f) => wave(wave(f))
modes[8]  = (f) => square(wave(triangle(f)), .7) // Here we've made a dash-dot-dash pattern
modes[9]  = (f) => wave(f) * triangle(f * 1.3) // By multiplying waveforms, we get a darken effect
modes[10] = (f) => (wave(f*1) + triangle(f * 3.3)) / 2 // Blend waveforms by averaging them
modes[11] = (f) => triangle(f*2) - wave(f * 1.5) // Subtraction can create interesting interference patterns
modes[12] = (f) => abs(triangle(f) - wave(f * 2)) // Subtraction with absolute value gives a distance

timer = 0 // Accumulate all the deltas each animation frame
mode = 0 // Start with mode 0

/* 
  To create a color picker UI control, write an event handler that starts with 
  "hsvPicker" or "rgbPicker". A color picker will appear in the code editor
  as well as when this pattern is selected from the main pattern list. The hue,
  saturation, and value selected in the web interface are passed as arguments to
  this handler as values between 0.0 and 1.0. The underscore just differentiates
  the local variable `_h`` from the global variable, `h`.
*/
var h = 0, s = 0, v = 1
export function hsvPickerColor(_h, _s, _v) { h = _h; s = _s; v = _v }

/*
  To create a UI slider control in the Pixelblaze IDE, write an event handler 
  that starts with "slider". All UI handlers in a pattern are called when 
  *any* UI control changes. The value passed into this function will be between
  0 and 1. Sliders remember their position.
*/
var frequency = 4 // Default to repeating waveforms 4 times across a strip
export function sliderFrequency(x) { frequency = 1 + 7 * x } // 1.0 to 8.0


/* 
  The beforeRender function is called once before each animation frame
  and is passed a delta in fractional milliseconds since the last frame.
  This has very high resolution, down to 6.25 nanoseconds!
*/
export function beforeRender(delta) {
  timer += delta // Accumulate all the deltas into a timer
  if (timer > 600) { // After 600ms, rewind the timer and switch modes
    timer -= 600
    mode = (mode + 1) % numModes // Go to the next mode, and keep between 0 and numModes
  }
  
  // Uncomment this line to check out a specific mode
  // mode = 0
}

/*
  The render function is called for every pixel. Here we're going to use the
  pixel's index to make a number between 0.0 and `frequency`. `frequency` is
  set in sliderFrequency() above to have a range from 1.0 to 8.0, selectible 
  by you in the Pixelblaze web interface. The result is that the math function
  selected by `mode` will be repeated `frequency` times across the strip length.
  The function's output modulates the pixel's brightness `v`alue.
*/
export function render(index) {
  // Look up the current mode function and call it
  brightness = modes[mode](frequency * index / pixelCount)

  hsv(h, s, v * brightness)
}
