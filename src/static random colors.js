/* 
  Static random colors
  
  What if you need a sequence of random numbers? Well, you could set up a loop
  that runs once and populates an array with random values. 
  
    var a = array(n)
    for(i = 0; i < n; i++) a[i] = random(1)
  
  They would be a different sequence of random values each time you restarted
  the pattern. But what if you need to be able to access the same sequence of
  random numbers each time you run your program? You need a pseudorandom number
  generator (PRNG) that accepts a seed. The same random sequence is repeatably
  generated when the PRNG is given a particular seed. 

  This pattern generates random colors each time it's loaded. With a simple
  tweak, it can render the same random sequence on each restart.
*/

// This seed will be set to a random value each time the pattern is loaded.
// Change to a constant to freeze a particular pseudorandom sequence.
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
  
  t1 = time(5.4 / 65.536) // Used to fade each pixel in and out
}

export function render(index) {
  h = pseudorandomFraction()

  /*
    s will be a different random 0..1 value from h, and is not correlated with
    the prior output, but it is dependent on the state of the shift register
    that just generated h. Each result from pseudorandomFraction() is random,
    yet dependent on the seed and all prior states of the shift register.

    Put another way, you'll see there are three calls to pseudorandomFraction(),
    so each one is consuming a value from the deterministic random sequence,
    then on the next render() they consume the next three values, etc.
  */ 
  s = pseudorandomFraction()

  // Adjust saturation to favor vibrant colors, but still allow whites/pastels
  s = 1 - s * s * s 

  // Each pixel is faded in and out with a random phase. To make it truly
  // static, set v to be 1.
  v = wave(t1 + pseudorandomFraction())
  
  hsv(h, s, v * v)
}
