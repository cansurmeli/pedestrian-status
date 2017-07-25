//
//  EstimatePedestrianStatus.swift
//  Pedestrian Status
//
//  Created by Can on 25/07/2017.
//  Copyright © 2017 Can Sürmeli. All rights reserved.
//

import Foundation
import CoreMotion

extension StepCountVC {
	func estimatePedestrianStatus(_ acceleration: CMAcceleration) {
		// If it's the first time accelerometer data obtained,
		// get old values as zero since there was no data before.
		// Otherwise get the previous value from the cycle before.
		// This is done for the purpose of the low-pass filter.
		// It requires the previous cycle data.
		if firstAccelerometerData {
			previousXValue = 0.0
			previousYValue = 0.0
			previousZValue = 0.0

			firstAccelerometerData = false
		} else {
			previousXValue = filteredXAcceleration
			previousYValue = filteredYAcceleration
			previousZValue = filteredZAcceleration
		}

		// Retrieve the raw x-axis value and apply low-pass filter on it
		xAcceleration = acceleration.x.roundTo(roundingPrecision)
		print("Raw X: \(xAcceleration)")
		filteredXAcceleration = xAcceleration.lowPassFilter(lowPassFilterPercentage, previousValue: previousXValue).roundTo(roundingPrecision)
		print("Filtered X: \(filteredXAcceleration)")

		// Retrieve the raw y-axis value and apply low-pass filter on it
		yAcceleration = acceleration.y.roundTo(roundingPrecision)
		print("Raw Y: \(yAcceleration)")
		filteredYAcceleration = yAcceleration.lowPassFilter(lowPassFilterPercentage, previousValue: previousYValue).roundTo(roundingPrecision)
		print("Filtered Y: \(filteredYAcceleration)")

		// Retrieve the raw z-axis value and apply low-pass filter on it
		zAcceleration = acceleration.z.roundTo(roundingPrecision)
		print("Raw Z: \(zAcceleration)")
		filteredZAcceleration = zAcceleration.lowPassFilter(lowPassFilterPercentage, previousValue: previousZValue).roundTo(roundingPrecision)
		print("Filtered Z: \(filteredZAcceleration)\n")

		// EUCLIDEAN NORM CALCULATION
		// Take the squares to the low-pass filtered x-y-z axis values
		let xAccelerationSquared = (filteredXAcceleration * filteredXAcceleration).roundTo(roundingPrecision)
		let yAccelerationSquared = (filteredYAcceleration * filteredYAcceleration).roundTo(roundingPrecision)
		let zAccelerationSquared = (filteredZAcceleration * filteredZAcceleration).roundTo(roundingPrecision)

		// Calculate the Euclidean Norm of the x-y-z axis values
		accelerometerDataInEuclideanNorm = sqrt(xAccelerationSquared + yAccelerationSquared + zAccelerationSquared)

		// Significant figure setting for the Euclidean Norm
		accelerometerDataInEuclideanNorm = accelerometerDataInEuclideanNorm.roundTo(roundingPrecision)

		// EUCLIDEAN NORM VARIANCE CALCULATION
		// record 10 values
		// meaning values in a second
		// accUpdateInterval(0.1s) * 10 = 1s
		while accelerometerDataCount < 1 {
			accelerometerDataCount += 0.1

			accelerometerDataInASecond.append(accelerometerDataInEuclideanNorm)
			totalAcceleration += accelerometerDataInEuclideanNorm

			break	// required since we want to obtain data every acc cycle
			// otherwise goes to infinity
		}

		// when accelerometer values are recorded
		// interpret them
		if accelerometerDataCount >= 1 {
			accelerometerDataCount = 0	// reset for the next round

			// Calculating the variance of the Euclidian Norm of the accelerometer data
			let accelerationMean = (totalAcceleration / 10).roundTo(roundingPrecision)
			var total: Double = 0.0

			for data in accelerometerDataInASecond {
				total += ((data-accelerationMean) * (data-accelerationMean)).roundTo(roundingPrecision)
			}

			total = total.roundTo(roundingPrecision)

			let result = (total / 10).roundTo(roundingPrecision)
			print("Result: \(result)")


			if (result < staticThreshold) {
				pedestrianStatus = "Static"
			} else if ((staticThreshold <= result) && (result <= slowWalkingThreshold)) {
				pedestrianStatus = "Slow Walking"
				stepCount += 1
				print("Step Count: \(stepCount)")
				print("Magnetic Heading: \(magneticHeading)")
				print("Direction: \(currentDirection)")
			} else if (slowWalkingThreshold < result) {
				pedestrianStatus = "Fast Walking"
				stepCount += 2
				print("Step Count: \(stepCount)")
				print("Magnetic Heading: \(magneticHeading)")
				print("Direction: \(currentDirection)")
			}

			print("Pedestrian Status: \(pedestrianStatus)\n\n\n")

			// reset for the next round
			accelerometerDataInASecond = []
			totalAcceleration = 0.0
		}
	}
}
