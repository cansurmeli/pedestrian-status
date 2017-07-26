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

class PedestrianStatusVC: UIViewController {
	@IBOutlet weak var xAccelerationLabel: UILabel!
	@IBOutlet weak var filteredXAccelerationLabel: UILabel!
	@IBOutlet weak var yAccelerationLabel: UILabel!
	@IBOutlet weak var filteredYAccelerationLabel: UILabel!
	@IBOutlet weak var zAccelerationLabel: UILabel!
	@IBOutlet weak var filteredZAccelerationLabel: UILabel!
	@IBOutlet weak var filterPercentageSlider: UISlider!
	@IBOutlet weak var filterPercentageLabel: UILabel!

	let motionManager = CMMotionManager()
	var didRetrieveAccelerometerDataBefore = false
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

	var accelerometerDataInEuclideanNorm: Double = 0.0
	var accelerometerDataInASecond = [Double]()
	var totalAcceleration: Double = 0.0
  var lowPassFilterPercentage = 15.0 {
		didSet {
			filterPercentageLabel.text = "\(Int(lowPassFilterPercentage))%"
		}
	}

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

	override func viewDidLoad() {
		super.viewDidLoad()

		motionManager.accelerometerUpdateInterval = PS.Constant.accelerometerUpdateInterval.rawValue

		motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (accelerometerData, error) in
			guard let accelerometerData = accelerometerData else {
				print(error!)

				return
			}

			self?.estimatePedestrianStatus(accelerometerData.acceleration)
		}

    filterPercentageSlider.isContinuous = true
	}

	@IBAction func changeFilterPercentage(_ slider: UISlider) {
    lowPassFilterPercentage = Double(roundf(slider.value))
	}
}
