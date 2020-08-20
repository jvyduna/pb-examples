
export function beforeRender(delta) {
  t1 = time(.05)*PI2
  t2 = time(.05)*PI2
}

export function render(index) {
  a = (1 + sin((index/2  +5* sin(t1)) ))/2
  b = (time(.1) + 1 + sin((index/2  +5* sin(t2)) ))
  v = (a*a*a*a)*.5
  hsv(b,1,v)
}