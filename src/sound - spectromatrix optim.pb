//This pattern uses the sensor expansion board
//it supports pixel mapped configurations with 2D or 3D maps
export var frequencyData

width = 14
zigzag = true

averageWindowMs =500

fade = .6
speed = 1
zoom = .3
targetFill = 0.15
var pic = makePIController(1, .1, 300, 0, 300)

var sensitivity = 0
brightnessFeedback = 0
var averages = array(32)
pixels = array(pixelCount)
vals = array(32)

// Makes a new PI Controller
function makePIController(kp, ki, start, min, max) {
  var pic = array(5)
  pic[0] = kp
  pic[1] = ki
  pic[2] = start
  pic[3] = min
  pic[4] = max
  return pic
}

function calcPIController(pic, err) {
  pic[2] = clamp(pic[2] + err, pic[3], pic[4])
  return max(pic[0] * err + pic[1] * pic[2],.3)
}

export function beforeRender(delta) {
  t1 = time(1)
  t2 = time(.6)
  
  wt1 = wave(t1 * speed)

  sensitivity = calcPIController(pic, targetFill - brightnessFeedback / pixelCount);
  brightnessFeedback = 0
  
  dw = delta / averageWindowMs
  for (i = 0; i < 32; i++) {
    averages[i] = max(.00001, averages[i] * (1 - dw) + frequencyData[i] * dw * sensitivity)
    vals[i] = (frequencyData[i] * sensitivity - averages[i]*2) * 10 * (averages[i] * 1000 + 1)
  }

}


export function render3D(index, x, y, z) {
  var  i, h, s, v
  
  i = triangle((wave((x+z)*zoom + wt1) + wave((y+z)*zoom - wt1)) *.5 + t2) * 31

  v = vals[i]

  h = i / 60 + t1 
  v = v > 0 ? v*v : 0
  s = 1 - v
  pixels[index] = pixels[index] * fade + v
  v = pixels[index];

  brightnessFeedback += clamp(v, 0, 2)
  hsv(h, s, v)
}

//support 2D pixel mapped configurations
export function render2D(index, x, y) {
  render3D(index, x, y, 0)
}

//this pixel mapper shim will work without a pixel map or on older Pixelblazes
//it calculates x/y based on a 2D LED matrix display given a known width and height
export function render(index) {
  var width = 8, height = 8
  var y = floor(index / width)
  var x = index % width
  //comment out this next line if you don't have zigzag wiring:
  x = (y % 2 == 0 ? x : width - 1 - x)
  x /= width
  y /= height
  render2D(index, x, y)
}
