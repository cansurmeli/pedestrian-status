//
//  PSEngine.swift
//  Pedestrian Status
//
//  Created by Can Sürmeli on 11.05.2018.
//  Copyright © 2018 Can Sürmeli. All rights reserved.
//

import CoreMotion

class PSEngine {
	static let shared = PSEngine()
	private let motionManager: CMMotionManager = {
		$0.accelerometerUpdateInterval = PS.Constant.accelerometerUpdateInterval.rawValue
		
		return $0
	}(CMMotionManager())
	private(set) var pedestrian = Pedestrian()
	private(set) var acceleration = Acceleration()
	private(set) var euclideanNormInASecond = [Double]()
	var lowPassFilterPercentage = 15.0
	
	// MARK: Control Functions
	func start() {
		motionManager.startAccelerometerUpdates(to: .main) { [unowned self] (accelerometerData, error) in
			guard let accelerometerData = accelerometerData
				else {
					if let error = error { print(error) }
					
					return
			}
			
			self.processAccelerationData(accelerometerData.acceleration)
		}
	}
	
	func stop() {
		motionManager.stopAccelerometerUpdates()
	}
	
	func resetStepCount() {
		pedestrian.stepCount = 0
		euclideanNormInASecond.removeAll()
	}
	
	// MARK: Engine Operations
	private func processAccelerationData(_ acceleration: CMAcceleration) {
		(self.acceleration.xRaw,
		 self.acceleration.yRaw,
		 self.acceleration.zRaw) = retrieveRawAccelerationData(from: acceleration)
		
		(self.acceleration.xFiltered,
		 self.acceleration.yFiltered,
		 self.acceleration.zFiltered) = applyLowPassFilter(self.acceleration.xRaw,
																											 self.acceleration.yRaw,
																											 self.acceleration.zRaw)
		
		let euclideanNorm = calculateEuclideanNorm(self.acceleration.xFiltered,
																							 self.acceleration.yFiltered,
																							 self.acceleration.zFiltered)
		
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
	
	private func collectEuclideanNorm(_ euclideanNorm: Double) {
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
	
	private func determinePedestrianStatusAndStepCount(from variance: Double) {
		if (variance < PS.Constant.staticThreshold.rawValue) {
			pedestrian.status = "static"
		} else if ((PS.Constant.staticThreshold.rawValue <= variance)
			&&
			(variance <= PS.Constant.slowWalkingThreshold.rawValue))
		{
			pedestrian.status = "slow Walking"
			pedestrian.stepCount += 1
		} else if (PS.Constant.slowWalkingThreshold.rawValue < variance) {
			pedestrian.status = "fast walking"
			pedestrian.stepCount += 2
		}
	}
}
