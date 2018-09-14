//
//  DetailVC.swift
//  Pedestrian Status
//
//  Created by Can Sürmeli on 26.08.2018.
//  Copyright © 2018 Can Sürmeli. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
	@IBOutlet weak var stepCountLabel: UILabel!
	@IBOutlet weak var pedestrianStatusLabel: UILabel!
	
	@IBOutlet weak var accelerationXRawLabel: UILabel!
	@IBOutlet weak var accelerationYRawLabel: UILabel!
	@IBOutlet weak var accelerationZRawLabel: UILabel!
	
	@IBOutlet weak var accelerationXFilteredLabel: UILabel!
	@IBOutlet weak var accelerationYFilteredLabel: UILabel!
	@IBOutlet weak var accelerationZFilteredLabel: UILabel!
	
	@IBOutlet weak var euclideanNormLabel: UILabel!
	@IBOutlet weak var varianceLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let dataUpdateTimer = Timer.scheduledTimer(withTimeInterval: PS.Constant.accelerometerUpdateInterval.rawValue,
																							 repeats: true,
																							 block: { _ in
																								self.stepCountLabel.text = String(PSEngine.shared.pedestrian.stepCount)
																								self.pedestrianStatusLabel.text = PSEngine.shared.pedestrian.status
																								
																								self.accelerationXRawLabel.text = String(PSEngine.shared.acceleration.xRaw)
																								self.accelerationXFilteredLabel.text = String(PSEngine.shared.acceleration.xFiltered)
																								
																								self.accelerationYRawLabel.text = String(PSEngine.shared.acceleration.yRaw)
																								self.accelerationYFilteredLabel.text = String(PSEngine.shared.acceleration.yFiltered)
																								
																								self.accelerationZRawLabel.text = String(PSEngine.shared.acceleration.zRaw)
																								self.accelerationZFilteredLabel.text = String(PSEngine.shared.acceleration.zFiltered)
																								
																								
		})
		
		dataUpdateTimer.fire()
	}
}

