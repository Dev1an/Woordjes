//
//  LocalWords.swift
//  Woordjes
//
//  Created by Damiaan on 16-10-16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import CloudKit

let localContext = appDelegate.localContext()
let defaults = UserDefaults()

func unarchiveSavedToken() {
	if let archivedToken = defaults.object(forKey: cloudSyncTokenKey) as? Data {
		if let token = NSKeyedUnarchiver.unarchiveObject(with: archivedToken) as? CKServerChangeToken {
			cloudSyncToken = token
			print("loaded token")
			print(cloudSyncToken)
		}
	}
}
