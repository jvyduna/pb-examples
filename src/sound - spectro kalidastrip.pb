//This pattern uses the sensor expansion board
export var frequencyData

averageWindowMs = 1500
speed = .03
targetFill = .2

brightnessFeedback = 0
averages = array(32)
pixels = array(pixelCount)
pic = makePIController(.2, .15, 30, 0, 400)

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
  t1 = time(speed)
  dw = delta / averageWindowMs
  for (i = 0; i < 32; i++) {
    averages[i] = max(.0001, averages[i] * (1 - dw) + frequencyData[i] * dw * sensitivity)
  }
}

//interpolates values between indexes in an array
function arrayLerp(a, i) {
  var ifloor, iceil, ratio
  ifloor = floor(i)
  iceil = ceil(i);
  ratio = i - ifloor;
  return a[ifloor] * (1 - ratio) + a[iceil] * ratio
}

export function render(index) {
  var x, y, i, h, s, v

  //i = (index*31/pixelCount + wave(t1*2)*31) % 31
  i = triangle(triangle(index / pixelCount *2) + t1 ) * 31
  // i = triangle((index + pixelCount/2)/pixelCount)*31
  // i = index*31/pixelCount


  v = (arrayLerp(frequencyData, i) * 4 - arrayLerp(averages, i)) * sensitivity * (arrayLerp(averages, i) * 1000 + .5)
  h = i / 31 + index / pixelCount / 4
  v = v > 0 ? v * v : 0
  s = 2 - v
  pixels[index] = pixels[index] * .75 + v
  v = pixels[index]
  
  brightnessFeedback += clamp(v, 0, 2)
  hsv(h, s, min(v, 1))
}