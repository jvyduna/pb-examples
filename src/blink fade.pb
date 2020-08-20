vals = array(pixelCount)
hues = array(pixelCount)

export function beforeRender(delta) {
	for (i = 0; i < pixelCount; i++) {
  	vals[i] -= .005 * delta * .1
  	if (vals[i] <= 0) {
  	  vals[i] = random(1)
  	  hues[i] = time(.07) + triangle(i / pixelCount) * .2
  	}
	}
}

export function render(index) {
  v = vals[index]
  v = v*v
	hsv(hues[index], 1, v)
}
