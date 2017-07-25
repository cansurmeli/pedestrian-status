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

class StepCountVC: UIViewController {
	@IBOutlet weak var xAccelerationLabel: UILabel!
	@IBOutlet weak var filteredXAccelerationLabel: UILabel!
	@IBOutlet weak var yAccelerationLabel: UILabel!
	@IBOutlet weak var filteredYAccelerationLabel: UILabel!
	@IBOutlet weak var zAccelerationLabel: UILabel!
	@IBOutlet weak var filteredZAccelerationLabel: UILabel!
	@IBOutlet weak var filterPercentageSlider: UISlider!
	@IBOutlet weak var filterPercentageLabel: UILabel!

	let locationManager = CLLocationManager()
	let motionManager = CMMotionManager()
	let accelerometerUpdateInterval = 0.1
	var firstAccelerometerData = true
	var previousXValue: Double!
	var previousYValue: Double!
	var previousZValue: Double!

	var xAcceleration: Double! {
		didSet {
			xAccelerationLabel.text = "\(xAcceleration!)"
		}
	}
	var yAcceleration: Double! {
		didSet {
			yAccelerationLabel.text = "\(yAcceleration!)"
		}
	}
	var zAcceleration: Double! {
		didSet {
			zAccelerationLabel.text = "\(zAcceleration!)"
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

	var staticThreshold = 0.013 // g^2
	let slowWalkingThreshold = 0.05	// g^2

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

	var magneticHeading: CLLocationDirection! {
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
		motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (accelerometerData: CMAccelerometerData?, error: Error?) in
			if((error) != nil) {
				print(error ?? "Unknown error")
			} else {
				self?.estimatePedestrianStatus((accelerometerData?.acceleration)!)
			}
		}

    filterPercentageSlider.isContinuous = true
	}

	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			stepCount = 0
			pedestrianStatus = "restarted"
			magneticHeading = 0
		}
	}

	// MARK: Supplementary Methods
	// Get the slider value for the percentage of the low-pass filter
	@IBAction func changeFilterPercentage(_ slider: UISlider) {
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
}
