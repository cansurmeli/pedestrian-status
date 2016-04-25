//
//  StatusViewController.swift
//  Pedestrian Status
//
//  Created by Can on 07/11/15.
//  Copyright © 2015 Can Sürmeli. All rights reserved.
//

import UIKit

class StatusViewController: ViewController {

	@IBOutlet weak var pedestrianStatusLabel: UILabel!
	var pedestrianDynamic: String!

	override func viewDidLoad() {
		pedestrianStatusLabel.text = pedestrianDynamic
	}

}
