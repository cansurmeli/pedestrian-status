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
		// If it's the first time accelerometer data is being obtained,
		// get old values as zero since there was no data before.
		// Otherwise get the previous value from the cycle before.
		// This is done for the purpose of the low-pass filter.
		// It requires the previous cycle's data.
		if didRetrieveAccelerometerDataBefore {
			previousXValue = filteredXAcceleration
			previousYValue = filteredYAcceleration
			previousZValue = filteredZAcceleration
		} else {
			previousXValue = 0.0
			previousYValue = 0.0
			previousZValue = 0.0

			didRetrieveAccelerometerDataBefore = true
		}

		// Retrieve the raw x-axis acceleration and apply low-pass filter on it
		xAcceleration = acceleration.x.round()
		filteredXAcceleration = xAcceleration.lowPassFilter(lowPassFilterPercentage,
		                                                    previousValue: previousXValue)

		// Retrieve the raw y-axis acceleration and apply low-pass filter on it
		yAcceleration = acceleration.y.round()
		filteredYAcceleration = yAcceleration.lowPassFilter(lowPassFilterPercentage,
		                                                    previousValue: previousYValue)

		// Retrieve the raw z-axis acceleration and apply low-pass filter on it
		zAcceleration = acceleration.z.round()
		filteredZAcceleration = zAcceleration.lowPassFilter(lowPassFilterPercentage,
		                                                    previousValue: previousZValue)

		// MARK: Euclidean Norm Calculation
		// Take the squares to the low-pass filtered x-y-z axis values
		let xAccelerationSquared = filteredXAcceleration.squared().round()
		let yAccelerationSquared = filteredYAcceleration.squared().round()
		let zAccelerationSquared = filteredZAcceleration.squared().round()

		// Calculate the Euclidean Norm of the x-y-z axis values
		accelerometerDataInEuclideanNorm = sqrt(xAccelerationSquared + yAccelerationSquared + zAccelerationSquared).round()

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
		// interpret them
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
