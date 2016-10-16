//
//  Subscription.swift
//  Woordjes
//
//  Created by Damiaan on 16-10-16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import CloudKit

func subscribeToWords() {
	let subscription = CKRecordZoneSubscription(zoneID: zoneID)
	let notificationInfo = CKNotificationInfo()
	notificationInfo.shouldBadge = true
	notificationInfo.alertLocalizationKey = "Nieuwe woorden"
	subscription.notificationInfo = notificationInfo
	privateDatabase.save(subscription) { subscription, error in
		if let error = error {
			print("❗CloudKit subscription error")
			print(error)
		}
	}
}

func saveToken() {
	if let token = cloudSyncToken {
		print(cloudSyncToken)
		let archivedToken = NSKeyedArchiver.archivedData(withRootObject:  token)
		defaults.set(archivedToken, forKey: cloudSyncTokenKey)
	}
}
