//
//  Double+Round.swift
//  Pedestrian Status
//
//  Created by Can on 26/07/2017.
//  Copyright © 2017 Can Sürmeli. All rights reserved.
//

import Foundation

extension Double {
	func round() -> Double {
		return roundTo(Int(PS.Constant.roundingPrecision.rawValue))
	}
}
