/*
  In this pattern we'll learn a technique to send an object across the strip.
  
  Our goal is to have a fiery rocket (oranges and reds) followed by a sparkling
  white tail.
  
  You'll learn some convenient tricks for animating things in Pixelblaze. You 
  might be thinking, "OK, I'll store a position for the head of the rocket. 
  The pixel should be red if it's a little behiind that, then some sparks, 
  then dark. Then I'll advance that positon between frames." While you could 
  build it that way, this pattern helps you start thinking in terms of,
  "Everything's a travelling wave or derivative of one." 
*/

export function beforeRender(delta) {
  // time() outputs a sawtooth from 0..1. An argument of 0.05 means it takes 
  // 0.04 * 65.536 seconds to progress to 1 before looping back to 0.
  t1 = time(0.04)
}

export function render(index) {
  /*
    Start with a square wave traveling left (because adding an offset like t1 
    is a left shift). The specified duty cycle of 0.15 means 15% of the
    wavelength is a 1, and the rest is 0. We're defining a section which is 15%
    of the strip's LEDs, and it's moving left. This section is the part that can
    be a spark.
  */
  canSpark = square(index / pixelCount + t1, 0.15)
  
  /*
    To be a white spark, two things need to be true: This pixel in the canSpark 
    section, and a randomly selected number between 0 and 1 needs to be greater 
    than 0.95 (a 1-in-20 chance)
  */
  isSpark = canSpark && random(1) > 0.95
  
  // To make a fiery rocket, set up a second square wave that will be 5% of the 
  // strip length, and lead the sparks secion by 5% of the strip length.
  isFire = square(index / pixelCount + t1 + 0.05, 0.05)
  
  /*
    Now we'll set our hues for the fiery section. We want something between 
    hue 0 (red) and hue 0.2 (yellow).

    You might think, how about making it yellow up front, and the redish portion
    trails behind, all of it moving along with the rocket. We could do that, but
    the alternate approach used here sort of simulates fire being expelled from
    a rocket instead. The red-to-yellow sawtooth gradient is only a function of
    the pixel's position in the strip. That way, as the rocket moves through 
    space, it leaves a trail behind it instead of keeping the plume with it.
    
    The "%" is the remainder operation, so we'll get a repeating sequence
    between 0 and 0.2
  
    As you'll see in a second, this hue will be ignored for sparks because 
    sparks will have their saturation set to zero. A zero saturation makes the 
    pixel white no matter what the hue is.
  */
  h = (index / (pixelCount / 5)) % .2

  /*
    Let's put it all together with hsv(hue, saturation, value). 
    
    The final color of a pixel will be either:
      - black (because value is zero)
      - white (because value is high and saturation is zero), or 
      - red-yellow (because value is high and saturation is high)
      
    h will always be a hue between red and yellow, even when hue is ignored
    because the pixel is a spark or off insead.
    
    We set the saturation to be the 0-or-1 value of isFire. isFire will be 1 for
    the fire pixels and 0 for the spark or off pixels. That means we'll have 
    saturated red-yellow colors when isFire is 1, and we'll have desaturated 
    (white) colors for a spark.
    
    Finally, for the brightness value, we want this pixel to be bright (1) if 
    it's either a fire pixel or a spark pixel, and fully off (0) otherwise.
  */
  hsv(h, isFire, isFire || isSpark)
}
