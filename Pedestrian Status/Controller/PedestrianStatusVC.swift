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
	@IBOutlet weak var stepCountLabel: UILabel!
	@IBOutlet weak var pedestrianStatusLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		PSEngine.shared.start()
		
		let dataUpdateTimer = Timer.scheduledTimer(withTimeInterval: PS.Constant.accelerometerUpdateInterval.rawValue,
														repeats: true,
														block: { _ in
															self.stepCountLabel.text = String(PSEngine.shared.pedestrian.stepCount)
															self.pedestrianStatusLabel.text = PSEngine.shared.pedestrian.status
		})
		
		dataUpdateTimer.fire()
	}
}
