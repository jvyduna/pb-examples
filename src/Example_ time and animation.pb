/*
 * In this example you'll see:
 * - time and animation
 * - using an array to switch between modes
 * - lambda style function expressions
 * - accumulating delta to make a mode switch timer
 */

var t2 // declare this variable here so we can reference it in our mode functions

// keep track of how many modes there will be
numModes = 14
modes = array(numModes) // make an array to store the modes
// make a bunch of lambda style mode functions and put them in the modes array
modes[0] = (f, t) => (f + t) % 1 // moving left
modes[1] = (f, t) => (1 + f - t) % 1 // moving right
modes[2] = (f, t) => (f + triangle(t)) % 1 // bounce back and forth
modes[3] = (f, t) => (f + wave(t)) % 1 // smooth back and forth, 
modes[4] = (f, t) => square(f + t, .5) // a chaser 
modes[5] = (f, t) => (f + triangle(triangle(t) * t)) % 1 // combining wave functions can create interesting effects
modes[6] = (f, t) => (f + wave(wave(t))) % 1 // warbly movemovent
modes[7] = (f, t) => square(triangle(wave(t)) + f, .5) // bouncing
modes[8] = (f, t) => wave(f + t) * wave(f + t2) // times with different intervals create interesting waveform interactions
modes[9] = (f, t) => wave(wave(f + t) + wave(f - t2) + f - t) //wave textures
modes[10] = (f, t) => wave(f + wave(wave(t) + f / 4)) // stretchy efect
modes[11] = (f, t) => wave((f - 2) * (1 + wave(t))) * wave(wave(t2) + f) // zoomed and blended
modes[12] = (f, t) => 2 * triangle(f + wave(t)) - wave(f * .75 + wave(t2)) // kinetic
modes[13] = (f, t) => abs(triangle(f - triangle(t2)) - wave(f * 2 + triangle(t))) // glitch conveyer belt

timer = 0 // accumulate all the deltas each animation frame
mode = 0 // start with mode 0

// the beforeRender function is called once before each animation frame
// and is passed a delta in fractional milliseconds since the last frame
// this has very high resolution, down to 6.25 nanosecons!
export function beforeRender(delta) {
  t = time(.05)
  t2 = time(.03)
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
  v = modes[mode](4 * index / pixelCount, t)
  hsv(0, 0, v)
}