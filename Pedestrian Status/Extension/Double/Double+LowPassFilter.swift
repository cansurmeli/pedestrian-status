//
//  Double+LowPassFilter.swift
//  Pedestrian Status
//
//  Created by Can on 25/07/2017.
//  Copyright © 2017 Can Sürmeli. All rights reserved.
//

import Foundation

/*
Raw Accelerometer Data = effects of gravity + effects of device motion
Applying a low-pass filter to the raw accelerometer data in order to keep only
the gravity component of the accelerometer data.
If it was a high-pass filter, we would've kept the device motion component.
SOURCES
http://litech.diandian.com/post/2012-10-12/40040708346
https://gist.github.com/kristopherjohnson/0b0442c9b261f44cf19a
*/
extension Double {
	func lowPassFilter(using filterFactor: Double, with previousValue: Double) -> Double {
		let firstSection = previousValue * filterFactor / 100
		let secondSection = (self * (1 - filterFactor / 100))

		return (firstSection + secondSection).round(to: 3)
	}
}
