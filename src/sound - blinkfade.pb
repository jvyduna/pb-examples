/*
  Sound - blink fade

  This pattern is designed to use the sensor expansion board.

  First please check out the "blink fade" pattern. With that as background, the
  goal now is to make it sound reactive.

  We're going to use something called a PI controller to perform an important
  function common to many sound-reactive patterns: Adjusting the sensitivity
  (the gain).

  Imagine a person who observes the pixels reacting to sound and is continuously
  tuning the overall brightness knob to keep things looking good. They would
  turn the brightness up when the sound is faint and everything's too dark, and
  turn it down if the sound is loud and the LEDs are pegged too bright. The PI
  controller is code to perform this job. This form of Automatic Gain Control
  allows the pattern to adapt over time so it can be in a visual Goldielocks
  zone, whether the environment's sound is soft, loud, or changing.

  The wikipedia article is more approachable than some:

    https://en.wikipedia.org/wiki/PID_controller#PI_controller
*/

/*
  By exporting these special reserved variable names, they will be set to
  contain data from the sensor board at about 40 Hz. 

  By initializing energyAverage to a value that's not possible when the sensor
  board is connected, we can choose when to simulate sound instead.
*/
export var energyAverage = -1 // Overall loudness across all frequencies
export var maxFrequency       // Loudest detected tone with about 39 Hz accuracy

vals = array(pixelCount)
hues = array(pixelCount)

// The PI controller will work to tune the gain (the sensitivity) to achieve 
// 20% average pixel brightness
targetFill = 0.2

/*
  We'll add up all the pixels' brightnesses values in each frame and store it
  in brightnessFeedback. The difference between this (per pixel) and targetFill
  will be the error that the PI controller is attempting to eliminate.
*/
brightnessFeedback = 0   

/*
  The output of a PI controller is the movement variable, which in our case is
  the `sensitivity`. Sensitivity can be thought of as the gain applied to the
  current sound loudness. It's a coefficient found to best chase our targetFill.
  You can add "export var" in front of this to observe it react in the Vars 
  Watch. When the sound gets quieter, you can watch sensitivity rise. If it's
  always at its maximum value of 150 (ki * max), try increasing the accumulated
  error's starting value and max in makePIController().
*/
sensitivity = 0

/*
  With these coefficients, it can take up to 20 seconds to fully adjust to a
  sudden change, for example, from a long period of very loud music to silence.
  Export this to watch pic[2], the accumulated error.
*/
pic = makePIController(.05, .15, 300, 0, 1000)

// Makes a new PI Controller "object", which is 4 parameters and a state var for
// the accumulated error
function makePIController(kp, ki, start, min, max) {
  var pic = array(5)
  
  // kp is the proportional gain coefficient - the weight placed on the current 
  // difference between where we are and where we want to be (targetFill)
  pic[0] = kp

  /*
    ki is the integral gain - the weight placed on correcting a situation where
    the proportional corrective pressure isn't enough, so we want to use the
    fact that time has passed without us approaching our target to step up
    the corrective pressure.
  */
  pic[1] = ki

  /*
     pic[2] stores the error accumulator (a sum of the historical differences 
     between where we want to be and where we were then). This is an integral,
     the area under a curve. While you could certainly store historical samples
     and evict the oldest, it's simpler to just have a min and max for what the
     area under this curve could be.

     We initialize it to a starting value of 300, and keep it within 0..1000.
  */
  pic[2] = start
  pic[3] = min
  pic[4] = max
  return pic
}

/*
  Calculate a new output (the manipulated variable `sensitivity`), given
  feedback about the current error. The error is the difference between the
  current average brightness and `targetFill`, our desired setpoint.

  Notice that the error can be negative when the LEDs are fuller than desired.
  This happens when the sensitivity was in a steady state and the sound is now
  much louder.
*/
function calcPIController(pic, err) {
  // Accumulate the error, subject to a min and max
  pic[2] = clamp(pic[2] + err, pic[3], pic[4])

  // The output of our controller is the new sensitivity. 
  //   sensitivity = Kp * err + Ki * ∫err 
  // Notice that with Ki = 0.15 and a max of 1000, the output range is 0..150.
  return max(pic[0] * err + pic[1] * pic[2], .3)
}

export function beforeRender(delta) {
  sensitivity = calcPIController(pic,
                  targetFill - brightnessFeedback / pixelCount)

  // Reset the brightnessFeedback between each frame
  brightnessFeedback = 0
  
  if (energyAverage == -1) { // No sensor board is connected
    simulateSound()
  } else {                   // Load the live data from the sensor board
    _energyAverage = energyAverage
    _maxFrequency = maxFrequency
  }

  for (i = 0; i < pixelCount; i++) {
    // Decay the brightness of each pixel proportional to how much time has
    // passed as well as how loud it is right now
    vals[i] -= .0005 * delta + abs(_energyAverage * sensitivity / 5000)

    // If a pixel has faded out, reset it with a random brightness value that is
    // scaled by the detected loudness and the computed sensitivity
    if (vals[i] <= 0) {
      vals[i] = random(1) * _energyAverage * sensitivity 

      /*
        The reinitialized pixel's color will be selected from a rotating 
        pallette. The base hue cycles through the hue wheel every 4.6 seconds.
        Then, up to 20% hue variation is added based on the loudest frequency
        present. More varied sound produces more varied colors.
      */
      hues[i] = time(.07) + .2 * triangle(_maxFrequency / 1000)
    }
  }
}

export function render(index) {
  v = vals[index]
  v = v * v  // This could also go below the feedback calculation
  
  /*
    Accumulate the brightness value from this pixel into an overall sum that 
    will be averaged across all pixels. This average will be fed back into the
    PI controller so it can adjust the sensitivity continuously, trying to make
    the average v equal the targetFill of 0.2.
  */
  brightnessFeedback += clamp(v, 0, 1)

  hsv(hues[index], 1, v)
}



/*
  These functions are used if the sensor board is not detected to simulate the
  sound variables used in this pattern. This allows the pattern still be lively 
  in the sequencer when there's no sensor board connected.
  
  16th notes (sequencerSlot)       S                              S
  SB samples @40Hz (timeSlots)     T      T      T      T      T
  beforeRender() e.g.~150FPS       B B B B B B B B B B B B B B B B B
  
  We cache the semi-random simulated data at the timeSlot level.
*/

BPM = 130  // Tempo in Beats Per Minute
var measurePeriod = 4 * 60 / BPM  // Seconds per 4 beat measure
var samplesPerMeasure = ceil(measurePeriod * 40)  // SB updates at 40Hz

// These globals store the simulated versions of the sensor data
var _energyAverage = 0, _maxFrequency = 0, _maxFrequencyMagnitude = 0
var _frequencyData = array(32)

// Lookup table of frequencyData center frequencies
var freqs = array(32)
freqs[0] = 37.5; freqs[1] = 50; freqs[2] = 75; freqs[3] = 100; freqs[4] = 125; freqs[5] = 163; freqs[6] = 195; freqs[7] = 234; freqs[8] = 312; freqs[9] = 391; freqs[10] = 469; freqs[11] = 586; freqs[12] = 703; freqs[13] = 859; freqs[14] = 976; freqs[15] = 1170; freqs[16] = 1370; freqs[17] = 1560; freqs[18] = 1800; freqs[19] = 2070; freqs[20] = 2380; freqs[21] = 2730; freqs[22] = 3120; freqs[23] = 3590; freqs[24] = 4100; freqs[25] = 4650; freqs[26] = 5310; freqs[27] = 6020; freqs[28] = 6840; freqs[29] = 7770; freqs[30] = 8790; freqs[31] = 9960

var beat, beatPct, timeSlot, sequencerPos, sequencerSlot
function calcSequencerTime() {
  t1 = time(measurePeriod / 65.536)   // 0-1 every measure
  beat = floor(t1 * 4)                // 0, 1, 2, 3
  beatPct = t1 * 4 % 1                // 0-1.0 continuous for every beat
  // There are samplesPerMeasure 40Hz timeSlots in each measure
  timeSlot = floor(t1 * samplesPerMeasure)
  sequencerPos = 16 * t1              // can be fractional 0..15.999
  sequencerSlot = floor(sequencerPos) // 0-15 every measure
}

// Calculate and memoize all simulated sensor board sound data
var cachedTimeSlot = -1
function simulateSound() {
  calcSequencerTime() 
  if (timeSlot == cachedTimeSlot) return // 140FPS -> 208FPS
  
  var energyTotal = 0, maxBin = 0, maxBinEnergy = 0
  for (fBin = 0; fBin < 32; fBin++) {
    binEnergy = simulateFrequencyData(fBin)
    energyTotal += binEnergy
    if (binEnergy > maxBinEnergy) {
      maxBin = fBin; maxBinEnergy = binEnergy
    }
  }
  _energyAverage = energyTotal / 32
  _maxFrequency = binomSample(freqs[maxBin], 8)
  _maxFrequencyMagnitude = binomSample(maxBinEnergy, 8)
  cachedTimeSlot = timeSlot
}


var instrumentCount = 4
var instruments = array(instrumentCount)
instruments[0] = makeInstrument(0b1000100010001000, 1, 3, 0.01)    // kick drum
instruments[1] = makeInstrument(0b1001001010001000, 5, 2, 0.01)    // bass
instruments[2] = makeInstrument(0b1011101000011100, 10, 6, 0.01)   // lead synth
instruments[3] = makeInstrument(0b0010001100100011, 20, 13, 0.05)  // high hat

function makeInstrument(sequence, centerBin, bandwidth, magnitude) {
  inst = array(4)
  inst[0] = sequence   // 16 slot binary vector sequencer
  inst[1] = centerBin  // center freq (bin index)
  inst[2] = bandwidth  // half-bandwidth, in bins. Further bins are attenuated.
  // Max instrument magnitude, if right on the sequencer attack and centerBin
  inst[3] = magnitude    
  return inst
}

// For the current 40Hz timeSlot, simulate a _frequencyData[fBin]
function simulateFrequencyData(fBin) {
  slotProximity = 1 - sequencerPos % 1 // Directly on-beat = 1. The D in ADSR.
  var fDataBinSum = 0, binProximity = 0
  for (inst = 0; inst < instrumentCount; inst++) {
    // If this instrument is "on" in this sequencer slot
    if ((instruments[inst][0] >> (15 - sequencerSlot)) & 1) {
      // How close we are to the center frequency bin of the instrument
      binProximity = max(0, 1 - abs(fBin - instruments[inst][1]) / instruments[inst][2])
      // Add some energy to this bin that's statistically close to the
      // instrument's nominal energy magnitude, decayed and splayed across bins
      fDataBinSum += binomSample(instruments[inst][3], 3) * slotProximity * binProximity
    }
  }
  return _frequencyData[fBin] = fDataBinSum
}

/*
  Returns a sample from a binomial distribution centered around a mean. Binomial
  approaches a discrete normal distribution (a bell curve). Takes a whole number
  `concentration` that determines how close the result usually is to the mean. A
  high concentration implies low variance around the mean. concentration == 1
  means it was selected from a flat distribution within +/- 50% of the mean.
*/
function binomSample(mean, concentration) {
  sum = 0
  for (i = 0; i < concentration; i++) sum += random(1)
  return mean * (0.5 + sum / concentration)
}
