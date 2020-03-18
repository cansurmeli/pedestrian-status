//
//  AboutVC.swift
//  Pedestrian Status
//
//  Created by Can Sürmeli on 17.03.20.
//  Copyright © 2020 Can Sürmeli. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {
	@IBOutlet weak var versionNumberLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		versionNumberLabel.text = Bundle.versionNumber()
	}
	
	@IBAction func dismissView(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func visitGithubProject(_ sender: Any) {
		UIApplication.shared.open(URL(string: "https://github.com/cansurmeli/pedestrian-status")!,
															options: [:],
															completionHandler: nil)
	}
}
