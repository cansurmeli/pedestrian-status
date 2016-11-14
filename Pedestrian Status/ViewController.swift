//
//  ViewController.swift
//  Pedestrian Status
//
//  Created by Can on 17/09/15.
//  Copyright © 2015 Can Sürmeli. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

extension Double {
    mutating func roundTo(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

/*
	Raw Accelerometer Data = effects of gravity + effects of device motion
	Applying a low-pass filter to the raw accelerometer data in order to keep only
	the gravity component of the accelerometer data.
	If it was a high-pass filter, we would've kept the device motion component.
	SOURCES
		http://litech.diandian.com/post/2012-10-12/40040708346
		https://gist.github.com/kristopherjohnson/0b0442c9b261f44cf19a
*/
extension Double {
	func lowPassFilter(_ filterFactor: Double, previousValue: Double) -> Double {
		return (previousValue * filterFactor/100) + (self * (1 - filterFactor/100))
	}
}

class ViewController: UIViewController, CLLocationManagerDelegate {

	// MARK: Outlets/Variables
	@IBOutlet weak var xAccelerationLabel: UILabel!
	@IBOutlet weak var filteredXAccelerationLabel: UILabel!
	@IBOutlet weak var yAccelerationLabel: UILabel!
	@IBOutlet weak var filteredYAccelerationLabel: UILabel!
	@IBOutlet weak var zAccelerationLabel: UILabel!
	@IBOutlet weak var filteredZAccelerationLabel: UILabel!
	@IBOutlet weak var filterPercentageSlider: UISlider!
	@IBOutlet weak var filterPercentageLabel: UILabel!

	let locationManager = CLLocationManager()					// A CoreLocation Location Manager for the compass heading
	let motionManager = CMMotionManager()						// A CoreMotion Motion Manager for the accelerometer values

	let accelerometerUpdateInterval = 0.1

	var firstAccelerometerData = true							// indicates the first time accelerometer data received. about
																// low-pass filtering
	var previousXValue: Double!
	var previousYValue: Double!
	var previousZValue: Double!

	var xAcceleration: Double! {
		didSet {
			xAccelerationLabel.text = "\(xAcceleration)"
		}
	}
	var yAcceleration: Double! {
		didSet {
			yAccelerationLabel.text = "\(yAcceleration)"
		}
	}
	var zAcceleration: Double! {
		didSet {
			zAccelerationLabel.text = "\(zAcceleration)"
		}
	}

	var filteredXAcceleration: Double = 0.0 {
		didSet {
			filteredXAccelerationLabel.text = "\(filteredXAcceleration)"
		}
	}
	var filteredYAcceleration: Double = 0.0 {
		didSet {
			filteredYAccelerationLabel.text = "\(filteredYAcceleration)"
		}
	}
	var filteredZAcceleration: Double = 0.0 {
		didSet {
			filteredZAccelerationLabel.text = "\(filteredZAcceleration)"
		}
	}

	let roundingPrecision = 3
	var accelerometerDataInEuclideanNorm: Double = 0.0
	var accelerometerDataCount: Double = 0.0
	var accelerometerDataInASecond = [Double]()
	var totalAcceleration: Double = 0.0
  var lowPassFilterPercentage = 15.0 {
		didSet {
			filterPercentageLabel.text = "\(Int(lowPassFilterPercentage))%"
		}
	}
	var shouldApplyFilter = true

	var staticThreshold = 0.013								// 0.008 g^2
	let slowWalkingThreshold = 0.05							// 0.05 g^2

	@IBOutlet weak var pedestrianStatusLabel: UILabel!
	var pedestrianStatus: String! {
		didSet {
			pedestrianStatusLabel.text = pedestrianStatus
		}
	}

	@IBOutlet weak var stepCountLabel: UILabel!
	var stepCount = 0 {
		didSet {
			stepCountLabel.text = String(stepCount)
		}
	}

	var magneticHeading: Double = 0.0  {
		didSet {
			magneticHeadingLabel.text = String(magneticHeading)
		}
	}
	@IBOutlet weak var magneticHeadingLabel: UILabel!

	var currentDirection: String! {
		didSet {
			currentDirectionLabel.text = currentDirection
		}
	}
	@IBOutlet weak var currentDirectionLabel: UILabel!

	// MARK: View Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingHeading()

		motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval

		// Initiate accelerometer updates
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData:CMAccelerometerData?, error:Error?) in
            if((error) != nil) {
                print(error ?? "startAccelerometerUpdates Error")
            } else {
                self.estimatePedestrianStatus((accelerometerData?.acceleration)!)
            }
        }

    filterPercentageSlider.isContinuous = true
	}

	// MARK: CoreLocation Delagate Methods
	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			stepCount = 0
			pedestrianStatus = "restarted"
			magneticHeading = 0
		}
	}

	// Get the compass direction
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		magneticHeading = newHeading.trueHeading
        
		let diff = (newHeading.trueHeading - newHeading.magneticHeading)

		if (0.0+diff <= magneticHeading) && (magneticHeading <= 90.0+diff) {
			currentDirection = "Right"
		} else if (90.0+diff < magneticHeading) && (magneticHeading <= 180.0+diff) {
			currentDirection = "Down"
		} else if (180.0+diff < magneticHeading) && (magneticHeading <= 270.0+diff) {
			currentDirection = "Left"
		} else if (270.0+diff < magneticHeading) && (magneticHeading <= 360.0+diff) {
			currentDirection = "Up"
		}
	}

	// MARK: Supplementary Methods
	// Get the slider value for the percentage of the low-pass filter

	@IBAction func changeFilterPercentage(_ slider: UISlider) {
//    print(roundf(slider.value))
    lowPassFilterPercentage = Double(roundf(slider.value))

    print("Filter percentage changed to \(lowPassFilterPercentage)")
	}

	// A UISegmentedControl for controlling the filter percentage
	@IBAction func changeAccelerometerValueType(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0 :
			shouldApplyFilter = false
			print("Accelerometer values changed to raw.\n")
		case 1:
			shouldApplyFilter = true
			print("Accelerometer values changed to filtered.\n")
		default:
			break
		}
	}

	func estimatePedestrianStatus(_ acceleration: CMAcceleration) {
		// If it's the first time accelerometer data obtained,
		// get old values as zero since there was no data before.
		// Otherwise get the previous value from the cycle before.
		// This is done for the purpose of the low-pass filter.
		// It requires the previous cycle data.
		if firstAccelerometerData {
			previousXValue = 0.0
			previousYValue = 0.0
			previousZValue = 0.0

			firstAccelerometerData = false
		} else {
			previousXValue = filteredXAcceleration
			previousYValue = filteredYAcceleration
			previousZValue = filteredZAcceleration
		}

        // Retrieve the raw x-axis value and apply low-pass filter on it
        var x_aixs = acceleration.x
        xAcceleration = x_aixs.roundTo(roundingPrecision)
        print("Raw X: \(xAcceleration)")
        var lowPassFilter_x = xAcceleration.lowPassFilter(lowPassFilterPercentage, previousValue: previousXValue)
        filteredXAcceleration = lowPassFilter_x.roundTo(roundingPrecision)
        print("Filtered X: \(filteredXAcceleration)")
        
        // Retrieve the raw y-axis value and apply low-pass filter on it
        var y_aixs = acceleration.y
        yAcceleration = y_aixs.roundTo(roundingPrecision)
        print("Raw Y: \(yAcceleration)")
        var lowPassFilter_y = yAcceleration.lowPassFilter(lowPassFilterPercentage, previousValue: previousYValue)
        filteredYAcceleration = lowPassFilter_y.roundTo(roundingPrecision)
        print("Filtered Y: \(filteredYAcceleration)")
        
        // Retrieve the raw z-axis value and apply low-pass filter on it
        var z_aixs = acceleration.z
        zAcceleration = z_aixs.roundTo(roundingPrecision)
        print("Raw Z: \(zAcceleration)")
        var lowPassFilter_z = zAcceleration.lowPassFilter(lowPassFilterPercentage, previousValue: previousZValue)
        filteredZAcceleration = lowPassFilter_z.roundTo(roundingPrecision)
        print("Filtered Z: \(filteredZAcceleration)\n")
        
        // EUCLIDEAN NORM CALCULATION
        // Take the squares to the low-pass filtered x-y-z axis values
        var filteredXAcc = filteredXAcceleration * filteredXAcceleration
        let xAccelerationSquared = filteredXAcc.roundTo(roundingPrecision)
        var filteredYAcc = filteredYAcceleration * filteredYAcceleration
        let yAccelerationSquared = filteredYAcc.roundTo(roundingPrecision)
        var filteredZAcc = filteredZAcceleration * filteredZAcceleration
        let zAccelerationSquared = filteredZAcc.roundTo(roundingPrecision)
        
		// Calculate the Euclidean Norm of the x-y-z axis values
		accelerometerDataInEuclideanNorm = sqrt(xAccelerationSquared + yAccelerationSquared + zAccelerationSquared)

		// Significant figure setting for the Euclidean Norm
		accelerometerDataInEuclideanNorm = accelerometerDataInEuclideanNorm.roundTo(roundingPrecision)

		// EUCLIDEAN NORM VARIANCE CALCULATION
		// record 10 values
		// meaning values in a second
		// accUpdateInterval(0.1s) * 10 = 1s
		while accelerometerDataCount < 1 {
			accelerometerDataCount += 0.1

			accelerometerDataInASecond.append(accelerometerDataInEuclideanNorm)
			totalAcceleration += accelerometerDataInEuclideanNorm

			break	// required since we want to obtain data every acc cycle
					// otherwise goes to infinity
		}

		// when accelerometer values are recorded
		// interpret them
		if accelerometerDataCount >= 1 {
			accelerometerDataCount = 0	// reset for the next round

			// Calculating the variance of the Euclidian Norm of the accelerometer data
            var num = totalAcceleration / 10
			let accelerationMean = num.roundTo(roundingPrecision)
			var total: Double = 0.0

			for data in accelerometerDataInASecond {
                var div = (data-accelerationMean) * (data-accelerationMean)
				total += div.roundTo(roundingPrecision)
			}

			total = total.roundTo(roundingPrecision)
            
            var numm = total / 10
			let result = numm.roundTo(roundingPrecision)
			print("Result: \(result)")


			if (result < staticThreshold) {
				pedestrianStatus = "Static"
			} else if ((staticThreshold <= result) && (result <= slowWalkingThreshold)) {
				pedestrianStatus = "Slow Walking"
				stepCount += 1
				print("Step Count: \(stepCount)")
				print("Magnetic Heading: \(magneticHeading)")
				print("Direction: \(currentDirection)")
			} else if (slowWalkingThreshold < result) {
				pedestrianStatus = "Fast Walking"
				stepCount += 2
				print("Step Count: \(stepCount)")
				print("Magnetic Heading: \(magneticHeading)")
				print("Direction: \(currentDirection)")
			}

			print("Pedestrian Status: \(pedestrianStatus)\n\n\n")

			// reset for the next round
			accelerometerDataInASecond = []
			totalAcceleration = 0.0
		}
	}
}
