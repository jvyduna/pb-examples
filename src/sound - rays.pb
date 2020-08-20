//This pattern uses the sensor expansion board

export var energyAverage
export var maxFrequencyMagnitude
export var maxFrequency


vals = array(pixelCount)
hues = array(pixelCount)
pos = 0
lastVal = 0

pic = makePIController(.05, .35, 30, 0, 400)

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

  sensitivity = calcPIController(pic, .5 - lastVal)

  t1 = time(.1)
  pos = (pos + delta * .05) % pixelCount
  lastVal = vals[pos] = pow(maxFrequencyMagnitude * sensitivity, 2)
  hues[pos] = maxFrequency / 5000
}

export function render(index) {
  index = pixelCount - index
  i = (index + pos + 0) % pixelCount
  v = vals[i]
  v = v * v
  h = hues[i] + index / pixelCount / 4 + t1
  hsv(h, 1, v)
}
