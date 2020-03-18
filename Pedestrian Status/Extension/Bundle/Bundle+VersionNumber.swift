//
//  Bundle+VersionNumber.swift
//  Pedestrian Status
//
//  Created by Can Sürmeli on 18.03.20.
//  Copyright © 2020 Can Sürmeli. All rights reserved.
//

import Foundation

extension Bundle {
	///    Retrieves the `infoDictionary` dictionary inside Bundle and
	/// returns the value accessed with the key `CFBundleShortVersionString`.
	///
	/// - Returns: the version number of the Xcode project as a whole(e.g. 1.0.3)
	class func versionNumber() -> String {
		guard let infoDictionary = Bundle.main.infoDictionary else { return "unknown" }
		guard let versionNumber = infoDictionary["CFBundleShortVersionString"] as? String else { return "unknwon" }
		
		return versionNumber
	}
}
