numSparks = 20;
friction = 1 / pixelCount ;
sparks = array(numSparks);
sparkX = array(numSparks);
pixels = array(pixelCount);

export function beforeRender(delta) {
  delta *= .1;
  for (i = 0; i < pixelCount; i++)
    pixels[i] = pixels[i] *.2
  for (i = 0; i < numSparks; i++) {
    if (sparks[i] <= 0) {
      sparks[i] = 1 + random(.4);
      sparkX[i] = random(5);
    }
    sparks[i] -= friction * delta;
    sparkX[i] += sparks[i] * sparks[i] * delta;
    if (sparkX[i] > pixelCount) {
      sparkX[i] = 0;
      sparks[i] = 0;
    }
    pixels[sparkX[i]] += sparks[i];
  }
}

export function render(index) {
  v = pixels[index];
  hsv(.02, 1.1 - v*v, v * v)
}
