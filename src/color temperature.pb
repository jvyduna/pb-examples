/*
  Color temperature
  
  Convert color temperature in degrees kelvin to r,g,b color.

  Color temperature data from Mitchell Charity's blackbody data table:
    http://www.vendian.org/mncharity/dir3/blackbody/
   
  General approach (subdivide the data into regions that can modeled with 
  simple, relatively inexpensive expressions) from Tanner Helland's blog:
    https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html

  IMPORTANT NOTE: Input color temperatures must be divided by 100 - e.g. to set
  a temperature of 2500k, you would call ctToRGB(25). This conversion is valid
  from 1000k (10) to 15,000k (150). It'll do *something* if given a temperature
  outside that range, but it is not guaranteed to be accurate, or even
  reasonable.
  
  For demo purposes, if you move the slider below 1000k (10), you get a slow
  sine wave of temperatures between 1000 and 8000k.

  White consumes the most power, and some people size their power supplies for a
  fraction of maximum. To limit current consumption, it defaults to coloring
  every 10th pixel, but allows up to 100% of pixles via a UI control named "Fill 
  $ Be $ Careful $". You can also limit max current consumption with the global
  brightness slider in the top bar, or the Limit Brightness setting in Settings.

  Another reason to start with 10% of pixels on is that the default pattern set
  attempts to be friendly at social gatherings without much forethought, for
  example, if the sequencer is enabled. 15 seconds of blinding white light could
  be a little jarring.
  
  Generously contributed by zranger1 (Jon) from the Pixelblaze forums.
   https://github.com/zranger1
*/

export var colorTemp = 0, fillPct = 0.1
var r, g, b

export function sliderColorTemperature(t) {
  colorTemp = t * 150
}

/*
  Fill 10%-100% of the strip.
*/
export function slider_fill_$_be_$_careful_$(_v) {
  fillPct = 0.1 + _v / 0.9
  if (_v == 1) fillPct = 0.1  // Failsafe to 10% for slider full right
}

function ctToRGB(ct){
    if (ct < 67) { 
        r = 1
        g = .5313 * log(ct) - 1.2909
        
        if (ct <= 19) {
          b = 0
        } else {
          b = 0.0223 * ct - .5063
        }
    } else {
        r = 38.309 * pow(ct, -.886)
        g = 10.771 * pow(ct, -.588)
        b = 1
    }
    
    r = clamp(r, 0, 1)
    g = clamp(g, 0, 1)
    b = clamp(b, 0, 1)
}

export function beforeRender(delta) {
  ct = (colorTemp < 10) ? ct = 10 + 70 * wave(time(0.07)) : colorTemp
  ctToRGB(ct)
}

export function render(index) {
  // Only color `fillPct` of pixels to limit the default current consumption
  if (index % 10 < fillPct * 10) {
    rgb(r, g, b)
  } else {
    rgb(0, 0, 0)
  }
}
