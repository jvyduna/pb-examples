PI10 = PI2*5
PI6 = PI2*3

export function beforeRender(delta) {
  t1 = time(.03)*PI2
  t2 = time(.05)*PI2
  t3 = time(.04)*PI2
}

export function render(index) {
  a = sin(index*PI10/pixelCount + t1)
  a = a*a
  b = sin(index*PI6/pixelCount - t2)
  c = triangle((index*3/pixelCount + 1 + sin(t3))/2 % 1)
  v = (a+b+c)/3
  v = v*v
  hsv(.3, a, v/2)
}