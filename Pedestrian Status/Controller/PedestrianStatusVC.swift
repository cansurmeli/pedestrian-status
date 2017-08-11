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

	var filteredXAcceleration = 0.0 {
		didSet {
			filteredXAccelerationLabel.text = "\(filteredXAcceleration)"
		}
	}
	var filteredYAcceleration = 0.0 {
		didSet {
			filteredYAccelerationLabel.text = "\(filteredYAcceleration)"
		}
	}
	var filteredZAcceleration = 0.0 {
		didSet {
			filteredZAccelerationLabel.text = "\(filteredZAcceleration)"
		}
	}

	var accelerometerDataInASecond = [Double]()
	var totalAcceleration = 0.0
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

		motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
			guard let accelerometerData = data
				else {
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
