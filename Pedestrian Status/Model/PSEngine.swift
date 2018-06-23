//
//  PSEngine.swift
//  Pedestrian Status
//
//  Created by Can Sürmeli on 11.05.2018.
//  Copyright © 2018 Can Sürmeli. All rights reserved.
//

import CoreMotion

struct PSEngine {
	private(set) var stepCount = 0
	private(set) var pedestrianStatus = "Static"
	var lowPassFilterPercentage = 15.0
	private var euclideanNormInASecond = [Double]()
	
	init(initiateWith acceleration: CMAcceleration) {
		let (rawX, rawY, rawZ) = retrieveRawAccelerationData(from: acceleration)
		let (filteredX, filteredY, filteredZ) = applyLowPassFilter(rawX, rawY, rawZ)
		let euclideanNorm = calculateEuclideanNorm(filteredX, filteredY, filteredZ)
		collectEuclideanNorm(euclideanNorm)
	}
	
	private func retrieveRawAccelerationData(from acceleration: CMAcceleration) -> (Double, Double, Double) {
		let x = acceleration.x.round(to: 3)
		let y = acceleration.y.round(to: 3)
		let z = acceleration.z.round(to: 3)
		
		return (x, y, z)
	}
	
	private func applyLowPassFilter(_ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double) {
		let filteredXAcceleration = x.lowPassFilter(using: 15, with: x)
		let filteredYAcceleration = y.lowPassFilter(using: 15, with: y)
		let filteredZAcceleration = z.lowPassFilter(using: 15, with: z)
		
		return (filteredXAcceleration, filteredYAcceleration, filteredZAcceleration)
	}
	
	private func calculateEuclideanNorm(_ x: Double, _ y: Double, _ z: Double) -> Double {
		return sqrt(x.squared().round(to: 3) + y.squared().round(to: 3) + z.squared().round(to: 3)).round(to: 3)
	}
	
	private mutating func collectEuclideanNorm(_ euclideanNorm: Double) {
		guard euclideanNormInASecond.count < 10
			else {
				let variance = calculateVariance()
				euclideanNormInASecond.removeAll(keepingCapacity: false)
				determinePedestrianStatusAndStepCount(from: variance)
				
				return
		}
		
		euclideanNormInASecond.append(euclideanNorm)
	}
	
	private func calculateVariance() -> Double {
		let totalEuclideanNorm = euclideanNormInASecond.reduce(0, +)
		let euclideanNormInASecondCount = Double(euclideanNormInASecond.count)
		let euclideanNormMean = (totalEuclideanNorm / euclideanNormInASecondCount).round(to: 3)
		
		var total = 0.0
		for euclideanNorm in euclideanNormInASecond {
			total += ((euclideanNorm - euclideanNormMean) * (euclideanNorm - euclideanNormMean)).round(to: 3)
		}
		total = total.round(to: 3)
		
		return (total / euclideanNormInASecondCount).round(to: 3)
	}
	
	private mutating func determinePedestrianStatusAndStepCount(from variance: Double) {
		if (variance < PS.Constant.staticThreshold.rawValue) {
			pedestrianStatus = "Static"
		} else if ((PS.Constant.staticThreshold.rawValue <= variance)
								&&
							 (variance <= PS.Constant.slowWalkingThreshold.rawValue))
		{
			pedestrianStatus = "Slow Walking"
			stepCount += 1
		} else if (PS.Constant.slowWalkingThreshold.rawValue < variance) {
			pedestrianStatus = "Fast Walking"
			stepCount += 2
		}
		
		print(stepCount)
	}
}
