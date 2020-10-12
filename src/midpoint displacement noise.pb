/*
  Midpoint displacement noise
  
  Recursive midpoint displacement to generate a pseudo-random 1D height map.

  It turns out that when composing computer graphics, there's a persistent need
  for randomness if we want to make things appear more "organic". Generating any
  individual random number is easy using `random()`. A sequence of purely random
  vales is white noise, which hops all around. In computer graphics, we commonly
  have a need for a continuous noise functions that can be procedurally
  generated, known as value noise or gradient noise. If you think of the
  continuous but random set of heights encountered while transiting a mountain
  range, that would be analogous to gradient noise, and could be represented as
  a 1-dimensional height map. A topo map is a representation of a 2-dimensional
  height map.

  In 1983, Ken Perlin invented an algorithm for his work on the movie Tron,
  which is now known as Perlin noise. In 2001, he extended that work into an
  n-dimensional approach called Simplex noise.

  In 1982, however, Fournier, Fussell and Carpenter (a cofounder of Pixar)
  published a paper on a value noise procedure which is now known as the
  diamond-square algorithm, or more appropriately in 1 dimension, "midpoint
  displacement". This is faster than Perlin, and is therefore provided in the 
  Pixelblaze examples for those who want to incorporate a more organic noise in
  their patterns. You can find a Perlin and Simplex noise generator in the
  pattern library.

  Generously contributed by zranger1 (Jon) from the Pixelblaze forums.
    https://github.com/zranger1
*/


var heightMap = array(pixelCount)
var maxDisplacement = 10  // Maximum height change at level 1

/* 
  Initial parameters chosen by eyeball. Many interesting things are
  possible, so please play with the sliders! Palette width and offset
  are good places to start. The relevant variables are exported so you can
  watch them in your browser.
*/
export var speed = .03         // .015 = 1 palette cycle / second
export var smoothness = .2     // Change in max displacement per level
export var paletteWidth = .15
export var paletteOffset = 0 
export var mapLifetime = 5000  // In milliseconds, 0 == forever
export var maxLevel = calcMaxRecursionDepth()

// Globals for animation
var t1
var xOffset
var mapTimer = 0

// Max recursion depth is the power of 2 nearest to, but less than pixelCount.
// The absolute max is 7 -- above that, current Pixelblazes will not go.  
function calcMaxRecursionDepth() {
  return min(7, floor(log2(pixelCount)))
}

function triggerNewMap() { mapTimer = mapLifetime }

// UI Controls
export function sliderMaxLevel(v) {
  maxLevel = floor(calcMaxRecursionDepth() * v)
  triggerNewMap()
}

export function slidermapLifetime(v) {
  mapLifetime = floor(30000 * v)
  triggerNewMap()
}

export function sliderSpeed(v) {
  speed = 0.1 * (1-v)
}

export function sliderPaletteWidth(v) { paletteWidth = v }

export function sliderPaletteOffset(v) { paletteOffset = v }

export function sliderRoughness(v) {
  smoothness = 0.3 + 2.7 * (1 - v)
  triggerNewMap()
}

// Calculate random offset proportional to current level
function displace(level) {
   var d = 2 * maxDisplacement / pow(smoothness, level)
   return d - random(2 * d)
}

// Displace initial segment endpoints and draw a smooth line between them
function initialize() {
  heightMap[0] = displace(1)
  heightMap[pixelCount - 1] = displace(1)
  interpolate(0, pixelCount)
}

// Rescale height map to range 0-1
function normalize() {
  var hMax, hMin, range
  
  hMax = -32000
  hMin = 32000
  
  for (i = 0; i < pixelCount; i++) {
    if (heightMap[i] > hMax) { hMax = heightMap[i] }
    if (heightMap[i] < hMin) { hMin = heightMap[i] }       
  }
  range = hMax - hMin
  
  for (i = 0; i < pixelCount; i++) {
    heightMap[i] = (heightMap[i] - hMin) / range
  }
}

// Line between segment endpoints
function interpolate(start, nPix) {
  var m = (heightMap[start + nPix - 1] - heightMap[start]) / nPix
  
  for (c = 1; c < nPix; c++) {
    heightMap[start + c] = heightMap[start] + m * c
  }
}

// Given a segment, find and displace midpoint, then subdivide and repeat for
// each new segment
function subdivide(indexStart, nPix, level) {
  var newLen, indexMid
          
  // If we can't subdivide further, we're done 
  if (level > maxLevel) { return }

  // Find midpoint and add random height displacement
  newLen = floor(nPix / 2)
  indexMid = indexStart + newLen - 1
  heightMap[indexMid] += displace(level)
    
  interpolate(indexStart, newLen)
  interpolate(indexMid, 1 + nPix - newLen)

// Recursion! Do the same thing with our two new line segments.
    level += 1
    subdivide(indexStart, newLen, level)
    subdivide(indexMid, 1 + nPix - newLen, level)
}

// Create initial heightmap
initialize()
subdivide(0, pixelCount, 1)
normalize()  


export function beforeRender(delta) {
  mapTimer += delta

  t1 = time(speed)

  // Generate new height map every `mapLifetime` milliseconds, where setting
  // mapLifetime to 0 == forever
   if (mapLifetime && (mapTimer > mapLifetime)) {
     mapTimer = 0

     initialize()
     subdivide(0, pixelCount, 1)
     normalize()
   }
}

// Render heightmap and do something inexpensive to animate 
export function render(index) {
  var v = heightMap[index]
  var h = (v + t1) % 1
  h = paletteOffset + (h * paletteWidth)
  hsv(perceptualH(h), 1, v * v)
}

// Utility to map HSV's hue into a more perceptually uniform rainbow
function perceptualH(pH) {
  pH = pH % 1 + (pH < 0)
  return wave((pH - .5) / 2)
}