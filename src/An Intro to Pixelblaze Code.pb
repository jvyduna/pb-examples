/*
  Welcome to Pixelblaze!

  Let's get you started with the Pixelblaze language. If you're an experienced 
  developer, you can skip to the concise language reference at the bottom of 
  this Edit page.
  
  First, we'll want to make sure your LEDs are connected and configured
  correctly. When you load this tutorial pattern, there should be a test pattern
  running that chases a red pixel, then a green pixel, then a blue pixel through
  all your LEDs.

  If that's not working, you'll want to double check your wiring and think
  through each setting on the Settings tab.
  
  Have a look at the Getting Started page:
  https://www.bhencke.com/pixelblaze
  
  Another resource is the forums:
  https://forum.electromage.com/
  
  So, assuming your LEDs are all running, let's start learning the language.
  Pixelblaze runs a simplified version of JavaScript. In the editor, free-form
  text like this is called "comments" and are highlighted in brown. Code is in
  white and some other colors. We can disable any code by turning it into
  a comment. There are two ways:
  
  // Any single line can be a comment if it begins with two leading slashes
  
  Or an entire multi-line section (like this) can be a comment if you start
  with slash-star and end with star-slash:
*/

var ohHeyLookThisIsSomeCode

/*
  Practice commenting out some code. Here is the test pattern. You don't need 
  to understand it yet, but try surrounding it with slash-star, star-slash. 
  Or, play with disabling some of its lines by inserting a '//' on the left.
*/

export function render(index) {
  red = green = blue = 0
  leadPosition = time(0.08) * pixelCount
  red   = abs(leadPosition - index - 0) < 1
  green = abs(leadPosition - index - 4) < 1
  blue  = abs(leadPosition - index - 8) < 1
  rgb(red, green, blue)
}

/*
  Great! From here on out, we're going to keep learning by commenting out
  entire examples and 'uncommenting' the next example. 

  This code editor is called ACE and it has some useful shortcuts you can find
  here: https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts
  One is that you can select multiple lines and comment or uncomment
  them all at once with "Ctrl-/" (Win) or "Cmnd-/" (Mac). 
  
  Try uncommenting the entire next example.
*/

// export function render(index) {
//   purple = 0.8
//   hsv(purple, 1, 0.2)
// }

/*
  If that worked, all your LEDs should now be a light purple color. Select that
  block of code and re-comment it out so it doesn't interfere with the next
  examples.
  
  There are two basic concepts common to all Pixelblaze patterns:
    1. The function named render()
    2. Setting a pixel's color with hsv() or rgb()

  Every pattern in Pixelblaze needs to have an exported function named 
  `render`. `render(index)` will be run once for every pixel, and the pixel's
  index (its position in line) will be passed in as "index". The first LED in
  the strip has an index of zero, the second LED is index 1, and so on. 

  In code jargon, we say render takes one "argument". It's convention for that
  argument to be named "index". Render is "called" once per pixel, per frame.
  It is "passed" the pixel index number as the argument.
  
  The word `export` is put before any functions or variables that some code
  outside of your pattern will need to access. In this case, the overall
  Pixelblaze system code needs to be able to run your render() function
  and pass in all the pixels' indices.
  
  If we want to turn a pixel on, we need to have a line that sets its color.
  That can be either:
  
    rgb(red, green, blue)
    
  or 
  
    hsv(hue, saturation, value).
    
  Let's try turning on the third pixel and we'll make it green.
*/

// export function render(index) {
//   if (index == 2) {  // index 2 is the third pixel
//     rgb(0, 1, 0)     // Red is zero (off), green is 1 (full on), blue is 0
//   } else {
//     rgb(0, 0, 0)     // If the index is NOT equal to 2, all 3 colors are off
//   }
// }

/*
  That's actually quite verbose. If you're new to code, there's a few concepts 
  in there. First, the `if` and `else` statements let us do one thing or 
  another depending on whether the LED's index is 2, and note the use of
  curly braces to group together all the lines that should be run. Second, 
  notice the double equal sign. This is a common gotcha for beginners. You'll
  probably make this mistake sometime. If we're *testing* the value of
  something, we use a double equals: `==`. A double equals means, "is equal
  to". Contrast that to the code examples above where we *set* the value of a
  variable with a single equal sign, such as `purple = 0.8`. A single equal sign
  means, "set the thing on the left equal to".

  Here's something more concise that does the exact same thing, but makes 
  the third pixel red instead of green:
*/

// export function render(index) {
//   rgb(index == 2, 0, 0)    // Red is full on (1) when index is 2.
// }

/*
  We'll skip over some programming concepts for now like how true is cast to a
  1, and the only data type in Pixelblaze is 16.16 fixed point numbers.
  
  If we want to get learning by example, it's time to start going a little 
  faster to make our animated rainbow dreams into reality. Let's talk color.
  
  An artist doesn't typically think, "I'm envisioning a beautiful red-green in 
  the additive color model," they think, "I want it to be yellow."
*/

// export function render(index) {
//   rgb(0.5, 0.3, 0)    // Hey look it's red-green, and no blue! Err.. yellow.
// }

/*
  What we'd prefer is something where we could specify a color with a single
  number. That way, we could animate that number and traverse through a
  rainbow. This exists - there's an alternate representation of RGB color space
  known as HSV. In this model, hue is a continuous "wheel" of colors.
  
  You'll find that most people prefer to use hsv() over rgb() for this reason. 
  Another advantage is that using hsv() will do special things to render colors
  in HDR on the more advanced SK9822/APA102 LEDs.
  
  Let's break apart `hsv(hue, saturation, value)`:
  
    hue: A number from 0-1 that is the essential spectrum name of the color.
      0.0  = Red
      0.02 = Orange
      0.1  = Yellow
      0.33 = Green
      0.45 = Mint
      0.5  = Cyan
      0.66 = Blue
      0.9  = Violet
    
    saturation: How saturated, or pure, the color is.
      1   = Just that color
      0.5 = Some white mixed in with this color
      0   = All white, no matter what the hue is set to
    
    value: The overall brightness of the color.
      0 = Off
      1 = Full brightness
    
    Go ahead and play with all three.
*/

// export function render(index) {
//   hsv(0.5, 1, 0.2)
// }

/*
  Now that you understand how hsv() works, if we add the random() function, you
  can now understand how the "firework dust" pattern works.
*/

// export function render(index) {
//   v = random(1000) < 5 // v is "true" (1) about 5-in-1000 times 
//   // A pixel will be a random hue, and it's only on 5-in-1000 times
//   hsv(random(1), 1, v)
// }

/*
  Let's save you hours of experimenting by noting a few things up front if
  you're new to RGB LEDs and the HSV color space.

  Hue isn't uniformly spread across a rainbow. Notice how close orange (0.02)
  is to red (0)?

  Saturation is fairly sensitive and depends on the hue we are trying to 
  desaturate. While 1 = pure color, a saturation of 0.9 actually mixes in quite
  a bit of white.
  
  Value (v) is the amount of light energy. You might think that a `v` value of
  0.5 should be half of the maximum brightness when v = 1, but humans actually 
  perceive brightness on a power-law scale (search for "gamma correction" for
  more information). This means that our eyes perceive v = 0.25 as about half 
  as bright as v = 1. This is why you'll see a lot of example patterns that do 
  something like this:
  
  v = v * v  // or even v = v * v * v
  
  Recall that squaring or cubing a number in 0...1 makes it smaller. As a
  side note, you'll find that a lot of Pixelblaze involves math on values from
  zero to one. A lot of people eventually find this to be very convenient.

  To explore the perception of brightness as it relates to v, let's write a 
  pattern that makes each pixel half the v of the one before it, and see if 
  each pixel looks half as bright.

  If you find that only a few pixels are lit, you might want to raise your
  global brightness level. See the slider in the header, or check your global
  brightness limit in the Settings tab.
*/

// export function render(index) {
//   v = 1 / pow(2, index) // 1, 0.5, 0.25, 0.125, etc
//   // Try uncommenting the following v = v * v.
//   // It ends up looking more like "half" the prior pixel's brightness.
//   // v = v * v  
//   hsv(0, 0, v) // White, because saturation = 0
// }

/*
  Let's try another way. Let's say we wanted to fade the brightness across
  our whole strip. We want to see which fade-out is the most natural looking.

  This is a good time to introduce a special variable in Pixelblaze that's 
  always available and will be very useful. `pixelCount` will always be set to
  the total number of pixels configured in the Settings tab. Since a lot of
  functions in Pixelblaze take numbers in the 0..1 range, you'll see
  a lot of stuff like this:
  
    index / pixelCount  // Returns 0..1 across all LEDs
*/

// export function render(index) {
//   v = index / pixelCount
//   // Try uncommenting one of the following
//   // Also play with the global brightness slider to see the effect
//   // v = v * v
//   // v = pow(v, 2.5)
//   // v = 0.005 + v * v * v
//   hsv(2/3, 1, v) // Just the blue LED
// }

/* 
  I'm a little worried you're getting bored so here's something exciting. This
  is a pattern in the default library called "Block reflections".
*/

// export function render(index) {
//   t1 = time(0.1)
//   m = .3 + triangle(t1) * .2
//   n = triangle(time(0.5)) * 10 + 4 * sin(time(0.2) * PI2)
//   h = sin(t1*PI2) + (((index - pixelCount / 2) / pixelCount * n % m))
//   v = (abs(h) + abs(m) + t1) % 1
//   hsv(h, 1, v * v)
// }

/*
  Pretty, right? You may not understand the math (I'm not sure I do!), but the 
  important part is you can now recognize render(), index, pixelCount, hsv(),  
  v * v, and variables being set!
  
  Something that is initially frustrating about coding but eventually becomes
  easier is finding unbalanced brackets: {} () []
  
  See if you can uncomment and then repair the code below. Look for the red
  error message below the editor. Unbalanced brackets usually result in errors
  like "Unexpected token" or "Unexpected identifier". The solution is in the
  next comment block.
*/

// export function render(index) {
//   x = (wave(time(0.05) + index / pixelCount) / 2
//   v = wave(7 * x) * wave(11 * x)
//   if (x > index / pixelCount) {
//     offset = 0.5
//   else {
//     offset = 0
//   }
//   hsv(offset + x/4, 1, v * v)
// }

/*
  Answer: It was missing a ")" after "time(0.05)" to close the "wave(", and the
  line "else {" needs to be "} else {" to close the "if (condition) {".
  
  OK, let's move on to another special function you'll see in many patterns.
  beforeRender() is called between frames. beforeRender() takes an argument 
  we usually name "delta" which is how much time has passed (in milliseconds) 
  since the last time beforeRender() was called. In other words, how much time
  does it take to calculate all the pixels once?
  
  Let's say you have 4 pixels and it takes 10ms to compute all 4 of them. This 
  is what Pixelblaze does each time you run (or even edit!) your pattern:
  
    Interprets (runs) all of the pattern's code
    calls beforeRender()
    calls render(0)
          render(1)
          render(2)
          render(3) - This frame of 4 pixels is now complete and displayed
    calls beforeRender(10), because 10ms elapsed since the first beforeRender()
    calls render(0)
          ... etc
    
  beforeRender() is therefore a useful and efficient place to do a bunch of 
  things: Check timers, read sensors, calculate motion, or pre-compute an entire 
  frame, which is called frame buffering.
  
  We can set variables in beforeRender() that are accessible in render(). These
  are called global variables because they can be read and set in any function.
  
  Here's a very common use for beforeRender(). We're going to compute what 
  "time" it is for this frame. Instead of knowing the exact number of seconds
  of milliseconds elapsed, it's common practice to set up a global timer 
  variable that loops from 0 to 1 at a certain speed. That's what the time() 
  helper function does.

  You can think of this as being like a rotary stopwatch, but you get to set
  how long it takes to complete one revolution. 
  
  Let's try visualizing a 4 second timer in a variable called t1.
*/

// export function beforeRender(delta) {
//   t1 = time(4 / 65.536) // From 0..1 every 4 seconds
// }
// export function render(index) {
//   // Which pixel should we turn on? As t1 goes from 0..1, onPixel will be the
//   // integer from zero to the total number of pixels we've configured.
//   onPixel = floor(t1 * pixelCount) 
//
//   v = 0 // Start by assuming the pixel is off
//   // Turn it on only if the current pixel's index is equal to `onPixel`
//   if (index == onPixel) v = 1
//   hsv(0.02, 1, v)
// }

/*
  Want a challenge? See if you can modify that pattern to change the color
  of the pixel as it moves.
  
  It's nice that one pixel is on, but how can we make the animation smoother,
  so that it's more like a pulse with a halo? Let's set the brightness based
  on how far the pixel is from our traveling pulse. We'll also use the
  clamp() function, which limits a value to be within a certain range.
*/

// export function beforeRender(delta) {
//   t1 = time(4 / 65.536) // From 0..1 every 4 seconds
// }

// export function render(index) {
//   pulsePosition = t1 * pixelCount // In units of pixels
//   distanceFromPulse = abs(pulsePosition - index) // Still in pixels
//   // We need something that's high when we're close to the pulse, 
//   // and low or negative when we're far from the t1 pulse position.
//   halfWidth = 5 // pixels
//   // When proximityToPulse == 5, we're at the pulse, 1 is dim, >= 0 is off
//   proximityToPulse = halfWidth - distanceFromPulse 
//   pctCloseToPulse = proximityToPulse / halfWidth // Now from 1 to 0 
//   v = clamp(pctCloseToPulse, 0, 1)

//   // Or, much more succinctly
//   // v = max(0, 1 - abs(t1 * pixelCount - index) / 5)

//   // Or a third way: 10% of strip width, not 5 pixels
//   // v = triangle(clamp((index/pixelCount - t1) / 0.2 + 0.5, 0, 1))
//   hsv(0.02, 1, v * v)
// }

/*
  If that pattern made you think, "Oooooh I wonder if I could make a fire-like
  pattern," then congrats you'll fit right in here.
  
  If that pattern made you think, "Uh.. that's a lot of math I don't remember,"
  don't worry! You'll fit right in here too!
  
  Another technique you'll sometimes see in Pixelblaze code is counting time (by
  adding up deltas) to do something every X seconds. Let's make a pattern that
  has two modes, mode 0 and mode 1. Mode 0 is just all off, and mode one is all
  red. So it's kind of an overcomplicated blinker. How can we switch modes once
  per second? We'll keep adding up the deltas and switch modes after we've 
  counted out 1000ms (1 second).
*/

// elapsedMs = 0
// mode = 0
// export function beforeRender(delta) {
//   elapsedMs = elapsedMs + delta
//   if (elapsedMs > 1000) {
//     elapsedMs = 0 // A second has passed, so reset our accumulator
//     mode = 1 - mode
//   }
// }
// export function render(index) {
//   if (mode == 0) { 
//     hsv(0, 0, 0) 
//   } else { 
//     hsv(0, 1, 0.1)
//   }
// }

/*
  If you're coming from Arduino, you might think this is quite involved compared
  to the simplicity of:
  
    void loop() { delay(1000); toggleLED(); }
  
  Writing non-blocking code is just a different set of techniques. You'll pick
  it up, don't worry.
  
  There's usually several ways to do something, and the method above was
  written quite verbosely. Here's another way to do the same thing.
*/

// elapsedMs = 0
// export function beforeRender(delta) {
//   elapsedMs += delta   // Same as elapsedMs = elapsedMs + delta
//   if (elapsedMs > 2000) elapsedMs -= 2000
// }
// export function render(index) {
//   hsv(0, 1, 0.1 * (elapsedMs < 1000))
// }

/*
  That's a more compact way to do *something* every 2 seconds, but if all we
  needed to do was blink there's even simpler ways!
*/

// export function render(index) {
//   hsv(0, 1, time(0.03) > 0.5)
// }

/*
  But if we want to cycle through many modes in a single pattern, accumulating 
  deltas is a decent way. Check out the "Example: ..." built-in patterns to see 
  this in use.

  Remember how we mentioned that you can use beforeRender() to pre-compute (or
  "buffer") an entire frame? There are several examples that ship with 
  Pixelblaze showing this technique. First, see the "KITT" pattern, which 
  includes a video tutorial:
  
  "Writing a Knight Rider KITT LED Pattern with Pixelblaze" 
  https://www.youtube.com/watch?v=3ugNIZ96UK4
  
  Also check out the "sparks" and "blink fade" patterns to see buffering in 
  action.
  
  At this point you're ready to start checking out the other example patterns 
  and diving into the docs below the editor on this page.
  
  If you've got a specific coding challenge, there's usually someone ready to
  help you on the forums: https://forum.electromage.com/
  
  Good luck!
*/
