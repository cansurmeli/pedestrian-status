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
	private let motionManager = CMMotionManager()
	private var psEngine: PSEngine!
	@IBOutlet weak var stepCountLabel: UILabel!
	@IBOutlet weak var pedestrianStatusLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		motionManager.accelerometerUpdateInterval = PS.Constant.accelerometerUpdateInterval.rawValue
		motionManager.startAccelerometerUpdates(to: .main) { [unowned self] (accelerometerData, error) in
			guard let accelerometerData = accelerometerData
				else {
					print(error!)

					return
				}
			
			self.psEngine = PSEngine(initiateWith: accelerometerData.acceleration)
			self.pedestrianStatusLabel.text = self.psEngine.pedestrianStatus
			self.stepCountLabel.text = String(self.psEngine.stepCount)
		}
	}
}
