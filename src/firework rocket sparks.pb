/*
  In this patterns we'll learn some techniques to send an object across the strip.
  
  Our goal is to have a fiery rocket (oranges and reds) followed by a sparkling
  white tail.
  
  You'll learn some convenient tricks for animating things in Pixelblaze. You 
  might be thinking, "OK, I'll store a position for the head of the rocket. 
  The pixel should be red if it's a little behiind that, then some sparks, 
  then dark. Then I'll advance that positon between frames." While you could 
  build it that way, this pattern helps you start you thinking in terms of,
  "Everything's a wave or derivative of one." 
  
  This is an imperfect pattern, so as you read through, see if you can spot
  quirks. At the end there's a section that discusses possible improvements.
*/

export function beforeRender(delta) {
  // time() outputs a sawtooth from 0..1. An argument of 0.05 means it takes 
  // 0.05 * 65.536 seconds to progress to 1 before looping back to 0.
  t1 = time(0.05)
}

export function render(index) {
  // Start with a sine wave traveling left (because adding an offset like t1 
  // is a left shift). The amplitude goes from 0..1, and the wavelength is the 
  // entire strip.
  v = wave(index / pixelCount + t1)
  
  // To make a fiery rocket, set up a second wave that will lead by 10 pixels
  v2 = wave((index + 10) / pixelCount + t1)

  // When the rocket fire's 0-to-1 siusoid wave is any value from 0.9995 to 1 
  // (the very top of the curve), isFire will be 1 (true).
  isFire = (v2 > .9995)
  
  /*
    First, `*=` is multiplication assignment; it just means update a variable by
    multiplying it by whatever is on the right side. 
    `v *= k` is the same as `v = v * k`.
    
    A convenient trick is to multiply a value by a boolean. In this way, a 
    "false" conditional is cast to be zero, and multiplying a numeric value by
    it will zero out that value. 
    
    This statement creates the sparkling tail section. If we're in a part
    of the main wave where the top of the sinusoid is within 0.05 of it's max
    value (1), AND a random value between 0 and 1 is greater than 0.95 (a 5% 
    chance), then keep this high value that's above 0.95. Otherwise, zero it out.
    Another way of thinking about this line is, "For the sparks, make a tail
    from the top of a sinusoid that comprises about the 20% of the strips length,
    and randomly turn on those pixels 5% of the time.
  */
  v *= (v > .95 && random(1) > .95)

  /*
    Now we'll set our hues for the fiery section. We want something between 
    hue 0 (red) and hue 0.2 (yellow).

    You might think, how about making it yellow up front, and the redish portion
    trails behind, all of it moving along with the rocket. We could do that, but
    the alternate approach used here sort of simulates fire being expelled from
    a rocket instead. The red-to-yellow sawtooth gradient is only a function of
    the pixel's position in the strip. That way, as the rocket moves through 
    space, it leaves a trail behind it instead of "taking" the plume with it.
    
    The "%" is the remainder operation.  so we'll get a repeating sequence
    of 0, .05, .1, and 0.15.
  
    As you'll see in a second, for a spark, this hue will be ignored because 
    sparks will have their saturation set to zero. A zero saturation makes the 
    pixel white no matter what the hue is.
  */
  h = (index / 20) % .2

  /*
    Let's put it all together with hsv(hue, saturation, value). 
    
    The final color of a pixel will be either:
      - black (because value is zero)
      - white (because value is high and saturation is zero), or 
      - red-yellow (because value is high and saturation is high)
      
    h will always be a red-yellow hue
    
    isFire will be 1 of the fire pixels and 0 for sparks or off pixels. That
    means we'll saturate (color) for fire, and desaturate (white) for a spark.
    
    Finally, for value, we want it to be ON (a high value) if it's EITHER a fire
    pixel OR a spark pixel. hsv() conveniently accepts values larger than 1 and
    treats them as 1, so we can composite the two types of pixels we want on with
    by adding the boolean isFire (1 or 0) to the v for sparks (which you'll 
    recall is a high value above 0.95; basically all the way on for a spark).
    Sometimes we'll have a 1.97 for example; this pixel is a random spark within 
    the fire. This will be red-yellow, because the saturation of this pixel is 1.
    
    For binary values, clamped addition is an "OR" and multiplication is an "AND".
    
    hsv clamps v values to within 0 and 1, so you can also pass in brightness values
    less than 0 and it will have a brightness of 0 instead of throwing an error.
  */
  hsv(h, isFire, isFire + v)
}

/*
  OK, so how could it be improved? Well, you might notice we have mixed concepts
  when is comes to specifying an offset or width. 
  
  Sometimes we use a fairly standard method of thinking in terms of the 
  "percentage of the strip". Every time we see an `index/pixelCount` this is the
  "fractonal percentage of the strip's total width". Doing our math this way
  ensures strips of different length will display patterns nearly identically
  in proportion to the overall length. For example, 
  
    t1 = time(0.05)
    v = wave(index / pixelCount + t1)
    
  This ensures the rocket will loop every 3.3 seconds when t1 returns to 0,
  regardless of whether we have 10 pixels or 1000.
  
  In this pattern, the width of the sparking portion is determined similarly - 
  it's a constant percentage of the strip's overall length:
  
    v = wave(index / pixelCount + t1)
    v > .95  // Spark-eligible
    // See https://www.desmos.com/calculator/mnipavu3mk
  
  That's all good, but notice that two other elements are defined in number of 
  pixels instead. First, the fire's offset from the sparks is 10 pixels:
  
    v = wave(index / pixelCount + t1) // Peaks of this wave will be sparks
    v2 = wave((index + 10) / pixelCount + t1) // Peaks will be fire
  
  Second, the fire colors repeat every 4 pixels:
  
    h = (index / 20) % .2  // Same as `(index % 4) / 20`
  
  How does this affect us in real life? Well on long strips (e.g. 240 pixels
  in a 4 m * 60 pix/m), sparks can preceed the fire. At farther viewing
  distances, the 4-pixel fire gradient blends into just orange.
  
  Another interesting case is binking a random pixel in render() with 
  something equivalent to:
  
    hsv(0, 0, random(1) > 0.95)

  In addition to depending on the probability used, the final perceptual effect 
  will both depend on the number of pixels and on the speed (frames per second)
  that your pattern is running at. If you wanted to precisely scale how this 
  looks on a strip that's 10X more pixels and maintain the effect, you might 
  choose to blink groups of a few pixels together; In addition it might be 
  running 10X slower, so the minimum blink duration will be 10X longer.
  
  One last note: Notice how we use the tops of wave(), essentially:
  
    wave(index / pixelCount + t1) > 0.95 // spark eligible
    
  Since we never end up using the sinusoidal nature of the values much, it
  might be clearer and easier to use the square() function:
  
    square(index / pixelCount + t1, 0.144)
  
  This way we can just read off that 14.4% of the strip can spark, instead of
  wondering what percentage of wave() is above 0.95.
  
  
  When you take out the comments, this is a small 7-line pattern. It also 
  uses a variety of useful Pixelblaze techniques.
*/