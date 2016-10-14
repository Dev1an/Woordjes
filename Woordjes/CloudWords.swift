//
//  FetchCloudWords.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 12/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import CloudKit

let cloudContainer = CKContainer.default()
let privateDatabase = cloudContainer.privateCloudDatabase

let myWordsZone = CKRecordZone(zoneName: "My word list")
let zoneID = myWordsZone.zoneID
var lastWordsToken: CKServerChangeToken?
var handlers = [() -> ()]()

func fetchCloudWords() {
	let fetchChanges = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], optionsByRecordZoneID: [zoneID: CKFetchRecordZoneChangesOptions()])
	fetchChanges.fetchAllChanges = true
	fetchChanges.optionsByRecordZoneID![zoneID]!.previousServerChangeToken = lastWordsToken
	fetchChanges.fetchRecordZoneChangesCompletionBlock = { error in
		if let error = error {
			print("❗An error occured during fetching")
			print(error)
		} else {
			print("process record zone changes")
		}
	}
	fetchChanges.recordChangedBlock = { word in
		print(word["value"]!)
		let managedObject = Word(word["value"] as! String, insertInto: dataContainer.viewContext)
		managedObject.cloudRecordID = NSKeyedArchiver.archivedData(withRootObject: word.recordID)
	}
	fetchChanges.recordWithIDWasDeletedBlock = { id, string in
		print("deletion \(string)")
//		dataContainer.viewContext.delete(word)
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
			print("received token")
			lastWordsToken = token
		}
	}
	fetchChanges.start()
}

func add(word: String) {
	let record = CKRecord(recordType: "Word", zoneID: zoneID)
	record["value"] = word as NSString
	let managedObject = Word(record["value"] as! String, insertInto: dataContainer.viewContext)
	managedObject.cloudRecordID = NSKeyedArchiver.archivedData(withRootObject: record.recordID)
	privateDatabase.save(record) { record, error in
		if let error = error {
			print("❗error while saving a new word in the cloud")
			print(error)
			dataContainer.viewContext.delete(managedObject)
		}
	}
}

func delete(word: Word) {
	if let archivedCloudID = word.cloudRecordID {
		let cloudID = NSKeyedUnarchiver.unarchiveObject(with: archivedCloudID) as! CKRecordID
		privateDatabase.delete(withRecordID: cloudID) { id, error in
			if let error = error {
				print("❗error while deleting a word in the cloud")
				print(error)
			}
		}
	}
}
