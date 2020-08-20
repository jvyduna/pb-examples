export function beforeRender(delta) {
  t1 = time(.1)
  t2 = time(.1)
}

export function render(index) {
  h = index/pixelCount *(5+wave(t1)*5) + wave(t2)*2
  h = (h %.5) + t1
  v = triangle((index/pixelCount*5 + t1*10) %1)
  v = v*v*v
  hsv(h,1,v)
}