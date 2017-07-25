//
//  LocationManagerDelegate.swift
//  Pedestrian Status
//
//  Created by Can on 25/07/2017.
//  Copyright © 2017 Can Sürmeli. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension StepCountVC: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		magneticHeading = newHeading.trueHeading

		let diff = (newHeading.trueHeading - newHeading.magneticHeading)

		if (0.0+diff <= magneticHeading) && (magneticHeading <= 90.0+diff) {
			currentDirection = "Right"
		} else if (90.0+diff < magneticHeading) && (magneticHeading <= 180.0+diff) {
			currentDirection = "Down"
		} else if (180.0+diff < magneticHeading) && (magneticHeading <= 270.0+diff) {
			currentDirection = "Left"
		} else if (270.0+diff < magneticHeading) && (magneticHeading <= 360.0+diff) {
			currentDirection = "Up"
		}
	}
}
