/* 
  Color twinkle bounce
  
  The wave math in this pattern shows forming a pattern in terms of the
  traditional sin() / cos() functions instead of the unit-friendly wave().

    1 | _                      1 | _ 
      |/ \                     0_|/_\____
    0_|___\_/___              -1 |   \_/
       0     1                    0     PI2

       wave(x)                    sin(x)

  As the docs on this page explain,

    wave(x) = (1 + sin(x * PI2)) / 2
*/

export function beforeRender(delta) {
  t1 = time(.05) * PI2
}

export function render(index) {
  /*
    Start with hues bouncing back and forth. To do this, the phase shift 
    oscillates. Hue values from here are in 0..2. As a reminder, hsv() will 
    "wrap" the values outside of 0..1 for us.
  */
  h = 1 + sin(index / 2 + 5 * sin(t1))
  
  // We'll also shift the hues over time, slower than the bouncing. Try 
  // commenting this out to see the hues move in lockstep.
  h += time(.1)
  /*
    You might have noticed that timers are typically defined in the
    beforeRender() function and therefore set between frames. Is it inefficient
    to call time() in render()? Can time() progress between individual pixels'
    calls to render()? The answer is no to both. time() is memoized, meaning it
    returns a fast, consistent result for all calls within render() for a given
    frame.
  */

  // Using the same period as the hue bounce, we'll set brightness `v`alues
  // to zero to create space between pulses.
  v = (1 + sin(index / 2 + 5 * sin(t1))) / 2
  
  v = v * v * v * v // Gamma correction
  hsv(h, 1, v)
}
