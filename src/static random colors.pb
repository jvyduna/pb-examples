/* 
  Static random colors
  
  What if you need a sequence of random numbers? Well, you could set up a loop
  that runs once and populates an array with random values. 
  
    var a = array(n)
    for(i = 0; i < n; i++) a[i] = random(1)
  
  They would be a different sequence of random values each time you resarted the
  pattern. But what if you need to be able to access the same sequence of random
  numbers each time you run your program? You need a pseudorandom number
  generator (PRNG) that accepts a seed. The same random sequence is repeatably
  generated when the PRNG is given a particular seed. 

  This pattern generates random colors each time it's loaded. With a simple
  tweak, it can render the same random sequence on each restart.
*/

// This seed will be set to a random value each time the pattern is loaded
var seed = random(0xffff) 

// 16 bit xorshift from 
// http://www.retroprogramming.com/2017/07/xorshift-pseudorandom-numbers-in-z80.html
var xs
function xorshift() {
  xs ^= xs << 7
  xs ^= xs >> 9
  xs ^= xs << 8
  return xs
}

// Return a pseudorandom value between 0 and 1
function pseudorandomFraction() {
  return xorshift() / 100 % 1
}

export function beforeRender(delta) {
  /*
    Reset the initial shift register for each render frame so that each frame
    renders the same random sequence. Need repeatability across power cycles?
    Set this to a particular constant. Like 42.
  */
  xs = seed 
}

export function render(index) {
  h = pseudorandomFraction()

  // s is a different random 0..1 value from h, but yet oddly completely
  // repeatably random while still dependant on the fact that h was just emitted
  // prior ;) John 
  s = pseudorandomFraction()

  // Adjust saturation to favor vibrant colors, but still allow whites/pastels
  s = 1 - s * s * s 

  hsv(h, s, 1)
}
