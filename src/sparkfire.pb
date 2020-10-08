/*
  Sparkfire
  
  What happens when you allow a pattern like 'sparks' to heat the air around it?
  You get spark fire! It's probably a good idea to read through the comments on
  'sparks' first.

  Depending on the number of pixels in your strip, you may need to adjust the
  first few variables to your liking; While there's meant to
  mostly work depending on the number of pixels, you should tune them to look
  good on your setup.
*/

// Number of sparks. Try 3-6.
numSparks = 3 + floor(pixelCount / 80)  

// Subtractive cooling. Try 0.02..0.3. Higher cools faster.
cooling1 = .05

// Coefficient cooling. Try 0.9..0.995. Lower cools faster.
cooling2 = .8 + 0.2 / (1 + exp(-pixelCount/80))
accel = .03    // How much sparks accelerate as they rise (try 0.02..0.05)
speed = .05    // Baseline speed of travel for each spark (try 0.03..0.1)

// Energy of each spark. Affects pixel heating and spark speed.
sparks = array(numSparks)
sparkX = array(numSparks)  // X position of each spark, in units of pixel index
export var pixels = array(pixelCount) // Brightness (heat energy) of each pixel

// Initialize sparks with random position and energy
for (i = 0; i < numSparks; i++) {
  sparkX[i] = random(pixelCount)
  // Further sparks are older and have less energy
  sparks[i] = .2 * (1 - sparkX[i] / pixelCount) + random(.4)
}

// Set up an initial heat value so init doesn't look empty
pixels[0] = 20


export function beforeRender(delta) {
  delta *= speed // Scale the time between loops by speed.

  for(i = 0; i < pixelCount; i++) {
    // When more time has passed, more subtractive cooling occurs
    cooldown = cooling1 * delta
   
    if(cooldown > pixels[i]) {
      pixels[i] = 0
    } else {
      // Coefficient cooling (`cooling2`) makes hotter sparks lose more energy.
      // Subtractive cooling makes all sparks lose some energy.
      pixels[i] = pixels[i] * cooling2 - cooldown
    }
  }
  /*
    Heat rises. Starting at the far end and working towards the first pixel,
    compute a weighted average of the heat from the preceding pixels and apply
    it to this one. Weighting several pixels behind higher creates a nice wispy
    pattern that can be seen more clearly by turning down `speed`.
  */
  for (k = pixelCount - 1; k >= 4; k--) {
      h1 = pixels[k - 1]
      h2 = pixels[k - 2]
      h3 = pixels[k - 3]
      h4 = pixels[k - 4]
      pixels[k] = (h1 + h2 + h3 * 2 + h4 * 3) / 7
    }
  
  for (i = 0; i < numSparks; i++) {
    // Reinitialize a spark that's passed the end and been reset
    if (sparks[i] <= 0) {
      sparks[i] = random(1)
      sparkX[i] = 0
    }

    // Accelerate (add kinetic energy) to each spark
    sparks[i] += accel * delta
    
    // Stash the original x position of this spark 
    ox = sparkX[i]

    // Δd = r·Δt 
    // Sparks advance at a rate that's the square of their energy
    sparkX[i] += sparks[i] * sparks[i] * delta

    // Reset sparks that are past the end
    if (sparkX[i] > pixelCount) {
      sparkX[i] = 0
      sparks[i] = 0
      continue  // Skip the rest of the for() loop for this iteration
    }
    
    /*
      For all pixels between the new x position and the original x position,
      heat the pixels (add brightness). Higher energy sparks are travelling
      faster and thus don't heat each pixel of air as much.
    */
    for (j = ox; j < sparkX[i]; j++)
      pixels[j] += clamp(1 - sparks[i] * .4, 0 , 1) * .5
  }
}

export function render(index) {
  v = pixels[index]

  /*
    v * v is our typical gamma correction, and it's constrained to remain
    between 0 and 1. Multiplying this by 0.1 keeps us in the red-yellow range;
    higher energies will be yellow.
  */
  h = .1 * clamp(v * v, 0, 1) 
  
  /*
    Desaturate (to white) any pixel with energy values between 1 and 1.5;
    Saturation will be clamped to 0 for any energy value above 1.5. Without
    this, the hottest pixels are just yellow instead of white hot.
  */
  s = 1 - (v - 1) * 2

  // It's useful to remember that HSV clamps s and v for us to within 0..1
  hsv(h, s, v)
}
