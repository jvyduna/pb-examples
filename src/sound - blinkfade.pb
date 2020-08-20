//This pattern uses the sensor expansion board

export var energyAverage
export var maxFrequency

targetFill = 0.2

vals = array(pixelCount)
hues = array(pixelCount)
brightnessFeedback = 0
pic = makePIController(.05, .15, 300, 0, 1000)
sensitivity = 0

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
  sensitivity = calcPIController(pic, targetFill - brightnessFeedback / pixelCount);
  brightnessFeedback = 0
  for (i = 0; i < pixelCount; i++) {
    vals[i] -= .005 * delta * .1 + abs(energyAverage * sensitivity / 5000)
    if (vals[i] <= 0) {
      vals[i] = energyAverage * sensitivity * random(1)
      hues[i] = time(.07) + triangle(maxFrequency / 1000) * .2
    }
  }
}

export function render(index) {
  v = vals[index] * 3
  v = v * v
  brightnessFeedback += clamp(v, 0, 1)
  hsv(hues[index], 1, v)
}
