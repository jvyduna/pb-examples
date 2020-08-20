w = 8 // the width of the 2D matrix
zigzag = true //straight or zigzag wiring?
export function beforeRender(delta) {
  t1 = time(.05)*PI2
  t2 = time(.09)*PI2
  z = 1+ wave(time(.2))*5
  t3 = time(.1)
}

export function render(index) {
  y = floor(index/w)
  x = index%w
  if (zigzag) {
    x = (y % 2 == 0 ? x : w-1-x)
  }
  h = (1 + sin(x/w*z + t1) + cos(y/w*z + t2))*.5
  v = h
  v = v*v*v
  hsv(h,1,v/2)
}