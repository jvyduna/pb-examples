/*
  Sparkfire
  
  What happens when you allow a pattern like 'sparks' to heat the air around it?
  You get spare fire!
*/

numSparks = 5
accel = .03
speed = .05
cooling1 = .24 // subtractive cooling
cooling2 = .95 // coefficient cooling
sparks = array(numSparks)
sparkX = array(numSparks)
pixels = array(pixelCount)

for (i = 0; i < numSparks; i++) {
  sparks[i] = random(.4)
  sparkX[i] = random(pixelCount)
}

export function beforeRender(delta) {
  delta *= speed

  for(i = 0; i < pixelCount; i++) {
    cooldown = cooling1 * delta
   
    if(cooldown > pixels[i]) {
      pixels[i] = 0
    } else {
      pixels[i] = pixels[i] * cooling2 - cooldown
    }
  }
  
  for(k= pixelCount - 1; k >= 4; k--) {
      h1 = pixels[k - 1]
      h2 = pixels[k - 2]
      h3 = pixels[k - 3]
      h4 = pixels[k - 4]
      pixels[k] = (h1 + h2 + h3 * 2 + h4 * 3) / 7
    }
  
  for (i = 0; i < numSparks; i++) {
    if (sparks[i] <= 0) {
      sparks[i] = random(1)
      sparkX[i] = 0
    }
    sparks[i] += accel * delta
    
    ox = sparkX[i]
    sparkX[i] += sparks[i] * sparks[i] * delta
    if (sparkX[i] > pixelCount) {
      sparkX[i] = 0
      sparks[i] = 0
      continue
    }
    
    for (j = ox; j < sparkX[i]; j++)
      pixels[j] += clamp(1 - sparks[i] * .4, 0 , 1) * .5
  }
}

export function render(index) {
  v = pixels[index]
  hsv(.1 * clamp(v * v, 0, 1), 1 - (v - 1) * 2, v * 2)
}
