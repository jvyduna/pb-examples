export function beforeRender(delta) {
  t1 = time(.15)*PI2
  t2 = time(.5)*PI2
}

export function render(index) {
  a = (1+sin(index/3 + PI2*sin(index/2+t1)))/2
  a = a*a*a*a
  a = (a > .1 ? a : 0)
  b = sin(index/3 + PI2*sin(index/2+t2))
  hsv(b,1,a/2)
}