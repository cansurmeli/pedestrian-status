//
//  PedestrianStatus.swift
//  Pedestrian Status
//
//  Created by Can on 26/07/2017.
//  Copyright © 2017 Can Sürmeli. All rights reserved.
//

import Foundation

enum PS {
	enum Constant: Double {
		case roundingPrecision = 3.0
		case staticThreshold = 0.013 // g^2
		case slowWalkingThreshold = 0.05	// g^2
		case accelerometerUpdateInterval = 0.1
	}
}
