/*
  Spiral twirls 2D
  
  A configurable 2D pattern that creates a variety of rotating and swirling
  circular and spiral effects.
  
  Output demo: https://youtu.be/Qa7B59CbYNw
  
  For best results a matrix of 16x16 or greater is recommended.
  
  It's suggested to start with all the sliders at zero, then try each of them
  one at a time to see what impact it has on the resultant pattern. That way it
  should be easier to understand how to combine them all to get the effect you'd
  like.
  
  There's a limited 3D and 1D projection provided.
  
  Generously contributed by ChrisNZ (Chris) from the Pixelblaze forums.
    https://forum.electromage.com/u/chrisnz
*/

var twistSpeed = .015
var rotateSpeed = .002
var startingColor = .3
var colorSpeed = .015
var twist, rotation, colorShift, arms


// How quickly the spiral should rotate back and forth
export function sliderTwistSpeed(v) { twistSpeed = v = 0 ? 0 : .015 / v }

// How quickly the entire pattern should rotate
export function sliderRotationSpeed(v) { rotateSpeed = v = 0 ? 0 : .005 / v }

// What initial colors to display. If colorSpeed is zero then the pattern will
// stay this color
export function sliderInitialColor(v) { startingColor = v * 2 }

// How quickly the colors of the pattern should change
export function sliderColorSpeed(v) { colorSpeed = v = 0 ? 0 : .015 / v }

// How many arms of symmetry the pattern should have (1-3)
export function sliderArms(v) { arms = 1 + floor(v * 2.999) }


export function beforeRender(delta) {
  twist = wave(time(twistSpeed)) * 2 - 1
  rotation = time(rotateSpeed)
  colorShift = time(colorSpeed)
}

export function render2D(index, x0, y0) {
  x = (x0 - .5) * 2
  y = (y0 - .5) * 2
  dist = sqrt(x * x + y * y)
  angle = (atan2shim(y, x) + PI) / PI / 2
  angle += dist * twist / 2
  
  h = angle * arms - rotation + 10
  h = h - floor(h)
  v = (1.01 - dist) * (h < .5 ? h * h * h : h)
  h = (h + startingColor) / 2 + colorShift
  
  hsv(h, 1, v)
}

// Experimentally-derived isometric projection. YMMV.
export function render3D(index, x0, y0, z0) {
  x = x0 / 3
  y = y0 / 3 + 0.68
  z = z0 / 3 - 0.75
  px = 0.4 * (1.71 * x - 1.71 * z)
  py = 0.4 * (x + 2 * y + z)
  render2D(index, px, py)
}

// Render the line sliced across the horizon, y = .5
export function render(index) {
  pct = index / pixelCount
  render2D(index, pct, 0.5)
}

// You can remove this shim if you're running v3.8 or newer
function atan2shim(y, x) {
  if (x == 0 || y == 0) {
    return 0 
  } else {
    return atan2(y, x)
  }
}
