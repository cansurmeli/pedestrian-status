//
//  Double+RoundToPrecision.swift
//  Pedestrian Status
//
//  Created by Can on 25/07/2017.
//  Copyright © 2017 Can Sürmeli. All rights reserved.
//

import Foundation

extension Double {
	func round(to precision: Int) -> Double {
		let divisor = pow(10.0, Double(precision))
		
		return Darwin.round(self * divisor) / divisor
	}
}
