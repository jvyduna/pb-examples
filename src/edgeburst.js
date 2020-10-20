/*
  Edgeburst
  
  The triangle() function is simple:
  
  output:   1  /\    /\
              /  \  /  \   etc
           0 /    \/    \/
  input:    0  .5  1     2
  
  triangle() is the go-to function when you want to mirror something (space, or
  time!) This pattern does both.
  
  Mirroring space is the building block for kaleidoscopes (see 'sound - spectro
  kalidastrip', 'xorcery', and 'glitch bands'). In this pattern we mirror the
  pixel's position (expressed as a percentage) around the middle of the strip
  with `triangle(pct)`.
  
  Mirroring a 0..1 time sawtooth turns a looping timer into a back-and-forth
  repetition.
*/

export function beforeRender(delta) {
  t1 = triangle(time(.1))  // Mirror time (bounce)
}

export function render(index) {
  pct = index / pixelCount
  edge = clamp(triangle(pct) + t1 * 4 - 2, 0, 1)  // Mirror space
  
  h = edge * edge - .2  // Expand violets
  
  v = triangle(edge)    // Doubles the frequency

  hsv(h, 1, v)
}
