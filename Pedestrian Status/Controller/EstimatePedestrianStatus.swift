//
//  EstimatePedestrianStatus.swift
//  Pedestrian Status
//
//  Created by Can on 25/07/2017.
//  Copyright © 2017 Can Sürmeli. All rights reserved.
//

import Foundation
import CoreMotion

extension PedestrianStatusVC {
	func estimatePedestrianStatus(_ acceleration: CMAcceleration) {
		// MARK: Accelerometer Data Retrieval
		// Retrieve the raw x-axis acceleration and apply low-pass filter on it
		xAcceleration = acceleration.x.round()
		filteredXAcceleration = xAcceleration.lowPassFilter(lowPassFilterPercentage,
		                                                    previousValue: filteredXAcceleration)

		// Retrieve the raw y-axis acceleration and apply low-pass filter on it
		yAcceleration = acceleration.y.round()
		filteredYAcceleration = yAcceleration.lowPassFilter(lowPassFilterPercentage,
		                                                    previousValue: filteredYAcceleration)

		// Retrieve the raw z-axis acceleration and apply low-pass filter on it
		zAcceleration = acceleration.z.round()
		filteredZAcceleration = zAcceleration.lowPassFilter(lowPassFilterPercentage,
		                                                    previousValue: filteredZAcceleration)

		// MARK: Euclidean Norm Calculation
		// Take the squares to the low-pass filtered x-y-z axis values
		let xAccelerationSquared = filteredXAcceleration.squared().round()
		let yAccelerationSquared = filteredYAcceleration.squared().round()
		let zAccelerationSquared = filteredZAcceleration.squared().round()

		// Calculate the Euclidean Norm of the x-y-z axis values
		let accelerometerDataInEuclideanNorm = sqrt(xAccelerationSquared + yAccelerationSquared + zAccelerationSquared).round()

		// MARK: Euclidean Norm Variance Calculation
		// record 10 consecutive euclidean norm values, that
		// is values gathered and calculated in a second since
		// the accelerometer frequency is set to 0.1 s
		while accelerometerDataInASecond.count < 10 {
			accelerometerDataInASecond.append(accelerometerDataInEuclideanNorm)
			totalAcceleration += accelerometerDataInEuclideanNorm

			break	// required since we want to obtain data every accelerometer cycle
						// otherwise goes to infinity
		}

		// when accelerometer values are recorded
		if accelerometerDataInASecond.count == 10 {
			// Calculating the variance of the Euclidian Norm of the accelerometer data
			let accelerationMean = (accelerometerDataInASecond.reduce(0, +) / Double(accelerometerDataInASecond.count)).round()
			var total: Double = 0.0

			for data in accelerometerDataInASecond {
				total += ((data-accelerationMean) * (data-accelerationMean)).round()
			}

			total = total.round()

			let result = (total / 10).round()

			if (result < PS.Constant.staticThreshold.rawValue) {
				pedestrianStatus = "Static"
			} else if ((PS.Constant.staticThreshold.rawValue <= result) &&
								(result <= PS.Constant.slowWalkingThreshold.rawValue)) {
				pedestrianStatus = "Slow Walking"
				stepCount += 1
			} else if (PS.Constant.slowWalkingThreshold.rawValue < result) {
				pedestrianStatus = "Fast Walking"
				stepCount += 2
			}

			print("Pedestrian Status: \(pedestrianStatus)\n\n\n")

			// reset for the next round
			accelerometerDataInASecond.removeAll(keepingCapacity: false)
			totalAcceleration = 0.0
		}
	}
}
