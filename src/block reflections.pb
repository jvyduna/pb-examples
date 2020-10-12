/*
 Block reflections
 
 Block reflections shows what's possible when you modulate a modulus.
 
 More specifically, the % operator in Pixelblaze is the remainder operation.

 dividend % divisor = remainder (where remainder has the sign of the dividend)

 This sign convention for `%` is as used in JS, most C, C#, Swift, Rust, but 
 unlike Python/Ruby, where the sign is that of the divisor.
 
 When running this pattern, look for the ramps of hue and brightness value,
 and notice a symmetry point around which the brightness ramps are reflected.
 
 The pattern Xorcery 2D/3D is an extension of this in 2D/3D space.
*/

export function beforeRender(delta) {
  t1 = time(0.1)       // 0..1 sawtooth every 0.1 * 65.535 seconds
  t2 = time(0.1) * PI2 // PI2 is 2 * Pi, so this traverses a circle in radians
  t3 = time(0.5)
  t4 = time(0.2) * PI2
}

export function render(index) {
  h = sin(t2) // While wave(0..1) outputs 0..1, sin(0..PI2) outputs -1..1
  
  /*
    The -1..1 sine wave has (-0.5..0.5)*(-4..14) added to it.  
    The -0.5..0.5 is a function of the pixel's position in the strip, 
    and the -4..14 is a function of time.
    Final range is -3..8.5
  */
  h += (index - pixelCount / 2) / pixelCount * 
              (10 * triangle(t3) + 4 * sin(t4))

  // Our dynamic dividend for the modulus (remainder) operation coming next.
  // 0.3 -> 0.5 and back, a triangle wave that peaks when t1 == 0.5.
  m = 0.3 + 0.2 * triangle(t1)
  
  /*
    To create our hues, we take the remainder when dividing by something 
    between 0.3 and 0.5. `%=` is the remainder assignment operator. `h %= m` 
    says, "Take h, divide it by m, and set h to be whatever the remainder is." 
    Remember that hue can wrap, so a -0.1 hue is the same hue as 0.9. Having a 
    0.3..0.5 divisor implies hues will be in -0.3..0.3, sometimes -0.5..0.5. 

    You should notice a reflected symmetry (hence this pattern's name) where 
    the direction seems to mirror, and the colors on each side have different
    palettes. This is the point where h == 0 before we apply the remainder 
    below. Notice that after the remainder operator, h is also 0 (red) at each 
    sharp transitions between ramps.

    Blue, green, purple or yellow are always marching back to something redish
    towards the symmetry point. When you don't see red, you'll notice it's just 
    a low brightness red.
  */
  h %= m
  
  /*
    The main ramps you can see in the output are ramps of both hue and 
    brightness. m and t1 can shift the 0..0.5 brightness higher, and even 
    "overdrive" back to low brightness spacers between blocks.
  */
  v = (abs(h) + m + t1) % 1
  
  v = v * v // Typical gamma scaling
  hsv(h, 1, v)
}
