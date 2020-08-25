/*
  Color bands has a chill vibe that comes from applying slower phase shifts to
  shorter wavelengths.
  
  It's also a good pattern to learn about mixing in just the right amount of
  desaturation (making whites, pinks, mints, etc) as well as modulating your
  colors, white spots, and dark spots independently.
*/

export function beforeRender(delta) {
  t1 = time(.25)
  t2 = time(.15)
}

export function render(index) {
  h = index / (pixelCount / 2) // Notice how each hue appears twice
  
  // Create the areas where white is mixed in. Start with a wave.
  s = wave(-index / 3 + t1)
  
  // A little desaturation goes a long way, so it's typical to start from 1 
  // (saturated) and sharply dip to 0 to make white areas.
  s = 1 - s * s * s * s
  
  // Create the slowly moving dark reqions
  v = wave(index / 2 + t2) * wave(index / 5 - t2) + wave(index / 7 + t2)
  
  v = v * v * v * v
  hsv(h, s, v)
}
