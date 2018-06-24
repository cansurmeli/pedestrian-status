//
//  ViewController.swift
//  Pedestrian Status
//
//  Created by Can on 17/09/15.
//  Copyright © 2015 Can Sürmeli. All rights reserved.
//

import UIKit
import CoreMotion

class PedestrianStatusVC: UIViewController {
	private let motionManager = CMMotionManager()
	private var psEngine = PSEngine()
	@IBOutlet weak var stepCountLabel: UILabel!
	@IBOutlet weak var pedestrianStatusLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		motionManager.accelerometerUpdateInterval = PS.Constant.accelerometerUpdateInterval.rawValue
		motionManager.startAccelerometerUpdates(to: .main) { [unowned self] (accelerometerData, error) in
			
			guard let accelerometerData = accelerometerData
				else {
					if let error = error { print(error) }

					return
				}
			
			self.psEngine.feedAccelerationData(accelerometerData.acceleration)
			self.pedestrianStatusLabel.text = self.psEngine.pedestrianStatus
			self.stepCountLabel.text = String(self.psEngine.stepCount)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		motionManager.stopAccelerometerUpdates()
	}
}
