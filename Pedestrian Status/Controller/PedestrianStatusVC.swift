//
//  ViewController.swift
//  Pedestrian Status
//
//  Created by Can on 17/09/15.
//  Copyright © 2015 Can Sürmeli. All rights reserved.
//

import UIKit
import CoreMotion

final class PedestrianStatusVC: UIViewController {
	private let motionManager = CMMotionManager()
	private var psEngine = PSEngine() {
		didSet {
			guard let stepCountLabel = stepCountLabel,
						let pedestrianStatusLabel = pedestrianStatusLabel
				else { return }
			
			stepCountLabel.text = String(psEngine.stepCount)
			pedestrianStatusLabel.text = psEngine.pedestrianStatus
		}
	}
	@IBOutlet weak var stepCountLabel: UILabel!
	@IBOutlet weak var pedestrianStatusLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		motionManager.accelerometerUpdateInterval = PS.Constant.accelerometerUpdateInterval.rawValue
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		motionManager.startAccelerometerUpdates(to: .main) { [unowned self] (accelerometerData, error) in
			guard let accelerometerData = accelerometerData
				else {
					if let error = error { print(error) }
					
					return
			}
			
			self.psEngine.feedAccelerationData(accelerometerData.acceleration)
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		motionManager.stopAccelerometerUpdates()
	}
}
