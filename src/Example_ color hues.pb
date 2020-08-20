/*
 * In this example you'll see:
 * - colors!!!
 * - using an array to switch between modes
 * - lambda style function expressions
 * - more colors!
 * - accumulating delta to make a mode switch timer
 */
 
// first, keep track of how many modes there will be
numModes = 13
modes = array(numModes) // make an array to store the modes
// make a bunch of lambda style mode functions and put them in the modes array
modes[0] = (f) => f // as values progress, a rainbow is drawn
modes[1] = (f) => 0 // a hue of 0.0 or 1.0 is red
modes[2] = (f) => 1/3 // a hue around 1/3 is green
modes[3] = (f) => 2/3 // 2/3 hue is blue
modes[4] = (f) => 1 // this wraps back around to red
modes[5] = (f) => f * .2 % .2 // using modulus will wrap early and with a sharp edge
modes[6] = (f) => triangle(f) *.2 // using triangle will keep the transitions smooth
modes[7] = (f) => wave(f) * .2 // wave also works, but is non-linear
modes[8] = (f) => square(f, .5) * .5 + .33 // square can make stripes
modes[9] = (f) => wave(f) * triangle(f*4) * .2 // color textures by combining waveforms
modes[10] = (f) => wave(f)*.5 % .2 - triangle(f) *.2 + .66 // more textures
modes[11] = (f) => (f + f % .2) * .5 // mod error overlay
modes[12] = (f) => abs(f* .25 - .5)*2 // centered  

timer = 0 // accumulate all the deltas each animation frame
mode = 0 // start with mode 0

// the beforeRender function is called once before each animation frame
// and is passed a delta in fractional milliseconds since the last frame
// this has very high resolution, down to 6.25 nanosecons!
export function beforeRender(delta) {
  timer += delta // accumulate all the deltas into a timer
  if (timer > 800) { // after 800ms, rewind the timer and switch modes
    timer -= 800
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
  h = modes[mode](4 * index / pixelCount)
  hsv(h, 1, 1)
}