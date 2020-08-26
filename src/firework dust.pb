/*
  Firework dust is for sparkle ponies.

  random(v) returns a random decimal number between 0 and v.

  After Pixeblazers understand that random() can make things glitter, they've
  been known to endlessly bedazzle other patterns by prepending any hsv() with:

    v += random(1) > 0.01

  Adding randomness to patterns can be a long and satifying quest.
*/

export function render(index) {
  // Every pixel is given a random hue from 0 to 1, IE the entire hue wheel
  h = random(1)
  
  /*
    If a random number between 0 and 100 is less than 90 (i.e. most of the 
    time), this comparison will return "true", which is also the value 1. A 
    saturation of 1 is a color, while saturation of 0 is white. So this makes 
    10% of the dust white.
  */
  s = random(100) < 90
  
  /* 
    If a random decimal between 0 and 1 is over 0.995, then the value is 1 and 
    the pixel is on. Otherwise it's zero (off). Another way of thinking about
    this: The odds of a pixel being on are ~ 5-in-1000, or 1-in-200. 
  */
  v = random(1) > .995
  
  hsv(h, s, v)
}