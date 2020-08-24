/*
  In this example you'll see:
  - Colors!!!
  - Using an array to switch between modes
  - Lambda style function expressions
  - More colors!
  - Accumulating delta to make a mode switch timer
  - Viewing which mode is playing in the variable watcher
*/
 
// First, keep track of how many modes there will be
numModes = 13
modes = array(numModes) // Make an array to store the modes

// Make a bunch of lambda style mode functions and put them in the modes array
// f is expected to be in 0..4
modes[0]  = (f) => f     // As values progress, a rainbow is drawn
modes[1]  = (f) => 0     // A hue of 0.0 or 1.0 is red
modes[2]  = (f) => 1 / 3 // A hue around 1/3 is green
modes[3]  = (f) => 2 / 3 // 2/3 hue is blue
modes[4]  = (f) => 1     // This wraps back around to red
modes[5]  = (f) => f * .2 % .2 // Using modulus will wrap early and with a sharp edge
modes[6]  = (f) => triangle(f) * .2 // Using triangle will keep the transitions smooth
modes[7]  = (f) => wave(f) * .2 // Wave also works, but is non-linear
modes[8]  = (f) => square(f, .5) * .5 + .33 // Square can make stripes
modes[9]  = (f) => wave(f) * triangle(f*4) * .2 // Color textures by combining waveforms
modes[10] = (f) => wave(f)*.5 % .2 - triangle(f) * .2 + .66 // More textures
modes[11] = (f) => (f + f % .2) * .5 // Mod error overlay
modes[12] = (f) => abs(f* .25 - .5) * 2 // Centered  

timer = 0 // Accumulate all the deltas each animation frame

/*
  Adding `export` when declaring a variable will send it back to any connected 
  web browser via websockets. To see the current value of `mode`, click "Enable"
  next to "Vars Watch" in the web editor.
*/
export var mode = 0 // Start with mode 0

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
  The render function is called for every pixel. Here we're going to use 
  the pixel's index to make a number between 0.0 and 4.0. This acts as a 4X 
  frequency modifier, repeating the pattern 4 times across the strip length.
  That 0-4 value is passed in to the current mode function and its output is 
  used to set the pixel's hue. hsv() "wraps" hue between 0.0 and 1.0.
*/
export function render(index) {
  // Look up the current mode function and call it
  h = modes[mode](4 * index / pixelCount)
  hsv(h, 1, 1)
}
