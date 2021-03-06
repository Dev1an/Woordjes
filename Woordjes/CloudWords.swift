//
//  FetchCloudWords.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 12/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import CloudKit
import CoreData
import Dispatch

let cloudContainer = CKContainer(identifier: "iCloud.com.devian.Woordjes")
let privateDatabase = cloudContainer.privateCloudDatabase

let myWordsZone = CKRecordZone(zoneName: "My word list")
let zoneID = myWordsZone.zoneID
let myList = CKRecord(recordType: "WordList", recordID: CKRecordID(recordName: "My word list", zoneID: zoneID))

func fetchCloudWords() {
	let changesGroup = DispatchGroup()
	let fetchChanges = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], optionsByRecordZoneID: [zoneID: CKFetchRecordZoneChangesOptions()])
	fetchChanges.container = cloudContainer
	fetchChanges.fetchAllChanges = true
	fetchChanges.optionsByRecordZoneID![zoneID]!.previousServerChangeToken = cloudSyncToken
	fetchChanges.fetchRecordZoneChangesCompletionBlock = { error in
		if let error = error {
			print("❗An error occured during fetching")
			print(error)
		} else {
			changesGroup.wait()
			DispatchQueue.main.async {
				appDelegate.saveContext()
			}
		}
	}
	fetchChanges.recordChangedBlock = { record in
		switch record.recordType {
		case "Word":
			print("\(record["value"]!)\t change at (\(record.creationDate!))")

			changesGroup.enter()
			upsertWordWith(cloudRecord: record) { _ in changesGroup.leave() }
		case "WordList":
			print("A word list has been changed")
		default:
			print("record of unknown type has been changed")
		}
	}
	fetchChanges.recordWithIDWasDeletedBlock = { id, string in
		print("cloud deletion \(id, string)")
		changesGroup.enter()
		deleteWordWith(id: id) { changesGroup.leave() }
	}
	fetchChanges.recordZoneFetchCompletionBlock = { id, changeToken, data, moreComing, error in
		if let error = error {
			print("❗An error occured during fetching")
			print(error)
		} else {
			print("✅ fetch completed")
			print(data)
		}
		if let token = changeToken {
			print("🔑 Received token")
			cloudSyncToken = token
		}
	}
	fetchChanges.qualityOfService = .userInteractive
	fetchChanges.start()
}

extension QualityOfService {
	var description: String {
		switch self {
		case .background:
			return "background"
		case .default:
			return "default"
		case .userInitiated:
			return "user initiated"
		case .userInteractive:
			return "user interactive"
		case .utility:
			return "utility"
		}
	}
}

func add(word: String, completionHandler: ((Word) -> Void)?) {
	let record = CKRecord(recordType: "Word", zoneID: zoneID)
	record["value"] = word as NSString
	record.setParent(myList)
	
	let insertion = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
	insertion.isLongLived = true
	insertion.database = privateDatabase
	DispatchQueue.main.async {
		let managedObject = insertWordWith(cloudRecord: record)
		managedObject.localOperation = .insert
		completionHandler?(managedObject)
		appDelegate.saveContext()
		
		insertion.modifyRecordsCompletionBlock = { insertedWordIDs, _, error in
			if let error = error {
				print("❗error while deleting a word in the cloud")
				print(error)
				DispatchQueue.main.async { localContext.delete(managedObject); appDelegate.saveContext() }
			} else {
				// todo set creation date
			}
		}

		insertion.start()
	}
}

func remove(word: Word) {
	if let cloudID = word.cloudID {
		let deletion = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [cloudID])
		print("created delete operation \(deletion.operationID)")
		deletion.isLongLived = true
		deletion.database = privateDatabase
		deletion.modifyRecordsCompletionBlock = { _, deletedWords, error in
			if let error = error {
				print("❗error while deleting a word in the cloud")
				print(error)
			} else {
				DispatchQueue.main.async {
					localContext.delete(word)
					appDelegate.saveContext()
				}
			}
		}
		DispatchQueue.main.async {
			word.localOperation = .delete
			appDelegate.saveContext()
		}
		deletion.start()
	}
}

func resumeLongLivingOperations() {
	cloudContainer.fetchAllLongLivedOperationIDs { operationIDs, error in
		if let error = error {
			print("❗error while fetching longLivingOperations")
			print(error)
		} else if let operationIDs = operationIDs {
			var i = 1
			print("\(operationIDs.count) long operations")
			for id in operationIDs {
				let j = i
				print("Fetching operation \(j) \(id)"); i += 1
				cloudContainer.fetchLongLivedOperation(withID: id) { operation, error in
					if let error = error {
						print("❗error while fetching longLivingOperation")
						print(error)
					} else {
						print("Fetched operation \(j)")
						if let wordModifications = operation as? CKModifyRecordsOperation {
							wordModifications.modifyRecordsCompletionBlock = { changedWords, removedWords, error in
								if let error = error {
									print("❗️Error while modifying records")
									print(error)
								} else {
									print("long living modification complete succesfuly")
									if let removedWords = removedWords {
										DispatchQueue.main.async { deleteWordsWith(ids: removedWords) }
									}
								}
							}
							privateDatabase.add(wordModifications)
						}
					}
				}
			}
		}
	}
}

func subscribeToWords() {
	let subscription = CKRecordZoneSubscription(zoneID: zoneID)
	let notificationInfo = CKNotificationInfo()
	notificationInfo.shouldSendContentAvailable = true
	subscription.notificationInfo = notificationInfo
	privateDatabase.save(subscription) { subscription, error in
		if let error = error {
			print("❗CloudKit subscription error")
			print(error)
		}
	}
}

// MARK: - Tokens

var cloudSyncTokenKey = "cloudSyncToken"
var cloudSyncToken: CKServerChangeToken?

let localContext = appDelegate.localContext()
let defaults = UserDefaults()

func unarchiveSavedToken() {
	if let archivedToken = defaults.object(forKey: cloudSyncTokenKey) as? Data {
		if let token = NSKeyedUnarchiver.unarchiveObject(with: archivedToken) as? CKServerChangeToken {
			cloudSyncToken = token
		}
	}
}

func saveToken() {
	if let token = cloudSyncToken {
		let archivedToken = NSKeyedArchiver.archivedData(withRootObject:  token)
		defaults.set(archivedToken, forKey: cloudSyncTokenKey)
		print("💾 Server token saved")
	}
}
