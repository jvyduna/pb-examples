/*
  Utility: Mapping helper 2D / 3D
  
  This pattern plays several patterns through 1D, 2D, and 3D coordinate space to
  help you debug the pixel maps you develop for your physical installation in
  the Mapper tab.
  
  This pattern builds on concepts developed by Roger Cheng:
    https://newscrewdriver.com
    Github: Roger-random / Twitter: @Regorlas

  His code has great expanded explanations and is linked below, near the
  corresponding modes.
  
  Jeff Vyduna edited for brevity and added additional modes.
*/

// Several modes sweep a surface through space. This sets the thickness of those
// surfaces. Use a higher percentage for projects with fewer pixels.
var thickness = 0.125

var modeCount = 4  // Total number of modes cycling through
var modes = array(modeCount)
var secPerMode = 6

// These are the animation modes it will cycle through
modes[0] = planarSweeps
modes[1] = axesAndRadius
modes[2] = mapperAnim
modes[3] = octants


var tBlink, tIndexChase, sphereRadius
export function beforeRender(delta) {
  tBlink = time(2 / 65.536)

  tIndexChase = time(secPerMode / 65.536)
  sphereRadius = tIndexChase * sqrt(3) // 0..vector distance to (1,1,1)
  
  tMode = time(secPerMode * modeCount / 65.536)
  mode = floor(modeCount * tMode)
  
  // mode = 1  // Set this to freeze a particular mode
}

export function render3D(index, x, y, z) {
  modes[mode](index, x, y, z)
  
  chaseIndex(index)
  
  if (index == 0) blinkWRGB()  // First pixel blinks white, then R-G-B
  if (index == pixelCount - 1) pulseRed() // Last pixel pulses red
}
  
export function render2D(index, x, y) {
  render3D(index, x, y, 0)
}

export function render(index) {
  render2D(index, index / pixelCount, 0)
}



/*
  Sweep 3 orthoginal planes through 3D space. The color corresponds to the 
  traditional color of the axis that the plan is normal to. 

  Derived from Roger Cheng's "RGB-XYZ 3D Sweep"
  https://github.com/Roger-random/glowflow/blob/master/rgbxyz%20sweep
*/

function planarSweeps(index, x, y, z) {
  oneAtATime = false  // Your choice
  
  // tIndexChase is scaled to begin before 0 and end after 1 so the sweeps
  // start and finish outside the visible space
  o = 1 + 2 * thickness
  t = o * tIndexChase - thickness
  
  if (oneAtATime) {
    t *= 3
    rgb(near(x, t), near(y, t - o), near(z, t - 2 * o))
  } else {
    rgb(near(x, t), near(y, t), near(z, t))
  }
}


// Color the axes and sweep a sphere through space, centered around the origin
function axesAndRadius(index, x, y, z) {
  if (y < thickness & z < thickness) rgb(0.5, 0, 0) // Red X-axis
  if (x < thickness & z < thickness) rgb(0, 0.5, 0) // Green Y-axis
  if (x < thickness & y < thickness) rgb(0, 0, 0.5) // Blue Z-axis
  
  // Distance between this pixel and 0,0,0
  distance = sqrt(x * x + y * y + z * z)
  
  // v == 1 right at the shell radius
  v = near(sphereRadius, distance)
  
  // Color this part of the shell acording to which axis it's closest to
  if (v > 0.01) rgb(v * x / distance, v * y / distance, v * z / distance)
}


// This is similar to the ranbow animation simulated in the mapper tab
function mapperAnim(index, x, y, z) {
  h = index / pixelCount + tIndexChase
  v = 0.2 + 0.7 * (near(index / pixelCount, tIndexChase) > 0.5)
  hsv(h, 1, v * v)
}


/*
  Divide XYZ space into octants and color them distinctly. This is particularly
  useful when assembling a walled cube from six square matrices.

  Derived from Roger Cheng's "RGB-XYZ 3D Octants"
  https://github.com/Roger-random/glowflow/blob/master/rgbxyz%20octants
*/
function octants(index, x, y, z) {
  // An octant's max brightness. Note that 1/8 of all 3D space is white in this
  // mode, so this lets you be extra cautious of heat and current
  var oB = 0.3

  r = (x > 0.5) * oB
  g = (y > 0.5) * oB
  b = (z > 0.5) * oB
  rgb(r, g, b)
}

/*
  Chase white through indices in ascending order. Note that in single pixel
  mode, if tIndexChase takes 6 seconds and the pattern is running on a large
  installation at 30FPS, only 180 of the total pixels will light.
*/
function chaseIndex(index) {
  longTail = false  // Chose wehther to render a single pixel or a faded tail
  
  if (longTail) {
    v = near(index / pixelCount, tIndexChase)
    on = (tIndexChase - index / pixelCount) > 0 && v > 0
    if (on) hsv(0, 0, v)
  } else {
    if (index == floor(tIndexChase * pixelCount)) hsv(0, 0, 1)
  }
}


// Returns 1 when a & b are proximate, 0 when they are more than `thickness`
// apart, and a gamma-corrected brightness for distances within `thickness`
function near(a, b) {
  v = clamp(1 - abs(a - b) / thickness, 0, 1)
  return v * v
}

// Blink a pixel white, then a quick red, green, and blue. This can help
// diagnose RGB color ordering misconfigurations.
function blinkWRGB() {
  step = floor(16 * tBlink)                         // 0123456789.....16
  h = floor(step % 8 / 2) / 3                       // RRGGBBrrRRGGBBrr
  v = step < 6 || step < 13 && (step - 7) % 2 == 1  // 1111110010101000
  hsv(h, step > 6, v)                               // WWWWWW__R_G_B___
}

function pulseRed() { hsv(0, 1, triangle(tBlink * 4)) }
