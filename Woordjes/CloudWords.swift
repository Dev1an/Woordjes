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

var cloudSyncTokenKey = "cloudSyncToken"
var cloudSyncToken: CKServerChangeToken?
var handlers = [() -> ()]()

func fetchCloudWords() {
	let fetchChanges = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], optionsByRecordZoneID: [zoneID: CKFetchRecordZoneChangesOptions()])
	fetchChanges.container = cloudContainer
	fetchChanges.fetchAllChanges = true
	fetchChanges.optionsByRecordZoneID![zoneID]!.previousServerChangeToken = cloudSyncToken
	fetchChanges.fetchRecordZoneChangesCompletionBlock = { error in
		if let error = error {
			print("❗An error occured during fetching")
			print(error)
		} else {
			appDelegate.saveContext()
		}
	}
	fetchChanges.recordChangedBlock = { record in
		switch record.recordType {
		case "Word":
			print("\(record["value"]!)\t(\(record.creationDate!))")
			
			Word.exists(id: record.recordID) { alreadyInLocalDatabase, word in
				if alreadyInLocalDatabase {
					word!.value = record["value"] as! String
				} else {
					DispatchQueue.main.async {
						let managedObject = Word(record["value"] as! String, insertInto: localContext)
						managedObject.cloudID = record.recordID.tuple
						managedObject.creationDate = record.creationDate!
					}
				}
			}
		case "WordList":
			print("A word list has been changed")
		default:
			print("record of unknown type has been changed")
		}
	}
	fetchChanges.recordWithIDWasDeletedBlock = { id, string in
		print("cloud deletion \(id, string)")
		Word.by(id: id) { word in
			print("delete \(word.value) locally")
			DispatchQueue.main.async {localContext.delete(word)}
		}
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
	fetchChanges.start()
}

func add(word: String) {
	let record = CKRecord(recordType: "Word", zoneID: zoneID)
	record["value"] = word as NSString
	record.setParent(myList)
	
	let managedObject = Word(word, insertInto: localContext)
	managedObject.cloudID = record.recordID.tuple
	managedObject.creationDate = Date()

	privateDatabase.save(record) { record, error in
		if let error = error {
			print("❗error while saving a new word in the cloud")
			print(error)
			localContext.delete(managedObject)
		} else {
			if let date = record?.creationDate { managedObject.creationDate = date }
		}
	}
}

func remove(word: Word) {
	if let name = word.cloudRecordName, let zoneName = word.cloudRecordZoneName, let zoneOwnerName = word.cloudRecordZoneOwnerName {
		let cloudID = CKRecordID(recordName: name, zoneID: CKRecordZoneID(zoneName: zoneName, ownerName: zoneOwnerName))
		privateDatabase.delete(withRecordID: cloudID) { id, error in
			if let error = error {
				print("❗error while deleting a word in the cloud")
				print(error)
			}
			DispatchQueue.main.async {
				localContext.delete(word)
			}
		}
	}
}

extension CKRecordID {
	var tuple: (String?, String?, String?) {
		return (recordName, zoneID.zoneName, zoneID.ownerName)
	}
}
