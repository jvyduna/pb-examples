/*
  Spiral twirls 2D
  
  A configurable 2D pattern that creates a variety of rotating and swirling
  circular and spiral effects.
  
  Output demo: https://youtu.be/2sCOhYdifus
  
  For best results a matrix of 16x16 or greater is recommended.
  
  It's suggested to start with all the sliders at zero, then try each of them
  one at a time to see what impact it has on the resultant pattern. That way it
  should be easier to understand how to combine them all to get the effect you'd
  like.
  
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
  angle = (atan2(y, x) + PI) / PI / 2
  angle += dist * twist / 2
  
  h = angle * arms - rotation + 10
  h = h - floor(h)
  v = (1.01 - dist) * (h < .5 ? h * h * h : h)
  h = (h + startingColor) / 2 + colorShift
  
  hsv(h, 1, v)
}
