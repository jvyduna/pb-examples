/*
 * In this example you'll see:
 * - Using an array to switch between modes
 * - lambda style function expressions
 * - different waveform functions and combinations
 * - accumulating delta to make a mode switch timer
 */
 
// first, keep track of how many modes there will be
numModes = 13
modes = array(numModes) // make an array to store the modes
// make a bunch of lambda style mode functions and put them in the modes array
modes[0] = (f) => f % 1 //this will just cause any numbers above 1.0 to wrap around
modes[1] = (f) => triangle(f) // triangle has a linear slope
modes[2] = (f) => wave(f) // wave uses the sin to create rounded slopes
modes[3] = (f) => square(f, .5) // a square wave is just on or off and has no transition
modes[4] = (f) => triangle(triangle(f)) // combining wave functions can create interesting effects
modes[5] = (f) => wave(triangle(f))
modes[6] = (f) => triangle(wave(f))
modes[7] = (f) => wave(wave(f))
modes[8] = (f) => square(wave(triangle(f)), .7) // here we've made a dash-dot-dash pattern
modes[9] = (f) => wave(f) * triangle(f*1.3) // by multiplying waveforms, we get a darken effect
modes[10] = (f) => (wave(f*1) + triangle(f*3.3))/2 // blend waveforms by averaging them
modes[11] = (f) => triangle(f*2) - wave(f*1.5) // subtraction can create interesting interference patterns
modes[12] = (f) => abs(triangle(f) - wave(f*2)) // subtraction with absolute value gives a distance

timer = 0 // accumulate all the deltas each animation frame
mode = 0 // start with mode 0

// the beforeRender function is called once before each animation frame
// and is passed a delta in fractional milliseconds since the last frame
// this has very high resolution, down to 6.25 nanosecons!
export function beforeRender(delta) {
  timer += delta // accumulate all the deltas into a timer
  if (timer > 600) { // after 800ms, rewind the timer and switch modes
    timer -= 600
    mode = (mode + 1) % numModes // go to the next mode, and keep between 0 and numModes
  }
  // uncomment this line to check out a specific mode
  // mode = 0
}

// the render function is called for every pixel. here we're going to use 
// the pixel's index to make a number between 0.0 and 4.0
// then pass that in to the current mode function and use it for brightness
export function render(index) {
  // look up the current mode function and call it
  v = modes[mode](4 * index / pixelCount)
  hsv(0, 0, v)
}