//This pattern lets you pick a color and spread or sharpen it to point on a movable location
//this makes use of a color picker and 2 slider UI controls

//make some global variables to store parameters from UI controls
//these variables are also exported, so they can be read or written via the API, or watched with the var watcher
export var hue = .77, saturation = 1, value = 1
export var sharpness = 5, location = .5

//make a color picker UI control
export function hsvPickerColor(h, s, v) {
  //store the chosen color into global variables
  hue = h
  saturation = s
  value = v
}

//make a sharpness UI slider to spread the color across the whole strip or sharpen to a spot
export function sliderSharpness(v) {
  sharpness = v*v * 100 // give a range of 0-100 with more control at the lower end
}

//make a location UI slider 
export function sliderLocation(v) {
  location = v
}

export function render(index) {
  //use the distance from the location, then raise to the sharpness power (which can also be less than 1 to blur)
  var v = value * pow(1 - abs(location - index/pixelCount), sharpness)
  hsv(hue, saturation, v)
}
