/*
  Blink fade
  
  Blink fade is a great pattern to get acquainted with arrays in Pixelblaze.
  
  An array is a numbered collection of values. In this pattern we use two
  arrays, one for the brightness value of each pixel, and one for the color hue
  of each pixel.
  
  It's all in the name: Each pixel will blink to life, then fade out. Since we
  store every pixel in an array and do most operations between frames, this
  is also an example of frame buffering. Most of the interesting code is in 
  beforeRender(), and render() just plucks out the precomputed values needed 
  for that pixel.
  
  Each pixel starts its lifespan with a random brightness value between 0 and
  1. Between every frame, we reduce each pixel's value in a linear way such
  that it loses 10% of full brightness every 200ms. That means a pixel that was
  "born" with a full 0.9999 brightness would take 2 seconds to decay.
  
  We know a pixel needs to be reincarnated when it's value (after reduction)
  has become negative. If that's the case, we rebirth it with a new random
  brightness value. It's new color is determined by two factors: a looping 
  timer, and the position of the pixel in the overall strip. Notice in the
  preview how the pixels in the center seem to originate new colors and that
  those colors propogate to the edges.
  
  An array element can be a function instead of a value. Check out the
  "Example: Modes and Waveforms" pattern to see that technique in action.
  
  And remember, if you forget any of this, it's all in the concise language
  reference right on this page below your code!
*/

/*
  This is how you make an array. `pixelCount` is a special variable provided in
  all patterns that is set to the total number of pixels configured in the 
  Settings tab. 
*/
values = array(pixelCount)
hues = array(pixelCount)


export var colorShiftSpeed = 4.6
export var fade = .005


export function sliderColorSpeed(v) {
  colorShiftSpeed = .5 + 20 * (1-v) //.5 to 20.5 seconds
}

export function sliderFadeSpeed(v) {
  fade = .0001 + v * .015 // .0001 to 0.0151 or about to 1.5s to 100s
}

// Called between frames
export function beforeRender(delta) {
  // Loop through every pixel
  for (i = 0; i < pixelCount; i++) {
    // `delta` is how many ms have elapsed since the last beforeRender().
    // Therefore at 200 Frames Per Second (FPS), delta = 5, and each pixel's 
    // 0..1 value would be reduced by 0.0025 each frame.
    values[i] -= fade * delta * .1
    
    // If this pixel is now full faded fully off
    if (values[i] <= 0) {
      values[i] = random(1) // Bump it back up to a random number 0..1
      
      /*
        Set the new color to be the sum of two components: 
          1) A timer that sawtooths from 0 to 1 every 4.6 seconds
          2) A 0.2 boost for the pixels at the center of the strip 
        If you're thinking, "Wait, aren't hue values between 0 and 1? This goes
        from 0 to 1.2," just know that hsv() 'wraps' hues for us. 1.1 => 0.1
      */
      hues[i] = time(colorShiftSpeed / 65.536) + 0.2 * triangle(i / pixelCount)
    }
  }
}

/*
  render() will be called once per pixel per frame, and `index` is the pixel's 
  position in the strip. The first pixel is index 0. If we have 60 total pixels 
  (pixelCount == 60), the last one would be index 59.
*/
export function render(index) {
  h = hues[index]    // Retrieve the hue for this pixel
  v = values[index]  // Retrieve the brightness value for this pixel
  v = v * v          // Gamma scaling: v is in 0..1 so this makes small v smaller 
  hsv(h, 1, v)       // Saturation is 1 -- no white is mixed in
}
