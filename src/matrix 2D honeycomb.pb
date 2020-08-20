
w = 8 // the width of the 2D matrix
zigzag = true //straight or zigzag wiring?

export function beforeRender(delta) {
  tf = 5
  t1 = wave(time(.15*tf))*PI2
  t2 = wave(time(.19*tf))*PI2
  z = 2+wave(time(.1*tf))*5
  t3 = wave(time(.13*tf))
  t4 = (time(.01*tf))
}

export function render(index) {
  y = floor(index/w)
  x = index%w
  if (zigzag) {
    x = (y % 2 == 0 ? x : w-1-x)
  }
  h = (1 + sin(x/w*z + t1) + cos(y/w*z + t2))*.5
  v = wave(h + t4)
  v = v*v*v
  h = triangle(h%1)/2 + t3
  hsv(h,1,v)
}