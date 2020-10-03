/*
  Glitch bands 

  Glitch bands is the result of two sharply convex, peaked waves, traveling
  in opposite directions. 
*/


export function beforeRender(delta) {
  t1 = time(.1) * PI2 // Notice we go from 0..2*Pi for timers fed to sin()
  t2 = time(.1)       // And 0..1 for timers fed to traingle()
  t3 = time(.5)
  t4 = time(.2) * PI2
  t5 = time(.05)
  t6 = time(.02)
}

export function render(index) {
  // For a discussion of how hue is being modulated here, see commentary in 
  // the "block reflections" pattern
  h = sin(t1)
  h += (index - pixelCount / 2) / pixelCount * (triangle(t3) * 10 + 4 * sin(t4)) 
  m = .3 + triangle(t2) * .2
  h %= m

  // Set up two opposing triangle waves, s1, and s2
  // s1 moves left and has 5 peaks in strip at a time
  s1 = triangle(t5 + index / pixelCount * 5)
  // Since triangle() outputs 0..1, this makes the peaks "sharper" (convex)
  s1 = s1 * s1

  // s2 moves right and has one peak in strip at a time
  s2 = triangle(t6 - index / pixelCount)
  // Strongly convex
  s2 = s2 * s2 * s2 * s2

  /*
    Where either wave is 0 or both are large valued, colors are saturated.
    In the rare places the wave values multply out to 0.5, colors go to white.
    The irregularity of this is one way in which the pattern makes glitches.
  */
  s = 1 - triangle(s1 * s2)

  /*
    A boolean comparison such as (a > b) can be cast to 0 or 1 and used with
    other artithmatic expressions.

    The brightness value is 0.5 if s2 is larger. If s1 is larger, it's 1.5 
    (which is clamped down to 1 by hsv()). This creates another aspect of the
    "glitches". To see this part clarly, try changing 0.5 to 0.
  */

  v = (s1 > s2) + .5

  hsv(h, s, v)
}
