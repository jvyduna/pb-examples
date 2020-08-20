numSparks = 20;
friction = 1 / pixelCount / 2;
sparks = array(numSparks);
sparkX = array(numSparks);
pixels = array(pixelCount);

export function beforeRender(delta) {
  delta *= .1;
  for (i = 0; i < pixelCount; i++)
    pixels[i] = 0;
  for (i = 0; i < numSparks; i++) {
    if (abs(sparks[i]) <= .001) {
      sparks[i] = .3 + random(.4);
      sparkX[i] = pixelCount/2;
      if (random(1) > .5) {
        sparks[i] *= -1
      }
    }
    sparks[i] -= friction * delta * (sparks[i] > 0 ? 1 : -1)
    sparkX[i] += sparks[i]  * delta;
    if (sparkX[i] > pixelCount || sparkX[i] < 0) {
      sparkX[i] = 0;
      sparks[i] = 0;
    }
    pixels[sparkX[i]] += abs(sparks[i]);
  }
}

export function render(index) {
  v = pixels[index];
  v = v*v
  hsv(.63, 1 - v, v)
}
