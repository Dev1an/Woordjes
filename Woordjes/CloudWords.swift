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
	fetchChanges.recordChangedBlock = { record in
		if record.recordType == "Word" {
			print("\(record["value"]!)\t(\(record.creationDate!))")
			
			DispatchQueue.main.async {
				let managedObject = Word(record["value"] as! String, insertInto: dataContainer.viewContext)
				managedObject.cloudID = record.recordID.tuple
				managedObject.creationDate = record.creationDate!
			}
		}
	}
	fetchChanges.recordWithIDWasDeletedBlock = { id, string in
		print("cloud deletion \(id, string)")
		let wordToDelete = NSFetchRequest<Word>(entityName: "Word")
		wordToDelete.predicate = NSPredicate(format: "cloudRecordName == %@ AND cloudRecordZoneName == %@ AND cloudRecordZoneOwnerName == %@", id.tuple.0!, id.tuple.1!, id.tuple.2!)
		wordToDelete.fetchLimit = 1
		if let word = (try? dataContainer.viewContext.fetch(wordToDelete))?.first {
			print("delete \(word.value) locally")
			DispatchQueue.main.async {dataContainer.viewContext.delete(word)}
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
			lastWordsToken = token
		}
	}
	fetchChanges.start()
}

func add(word: String) {
	let record = CKRecord(recordType: "Word", zoneID: zoneID)
	record["value"] = word as NSString
	let managedObject = Word(record["value"] as! String, insertInto: dataContainer.viewContext)
	managedObject.cloudID = record.recordID.tuple
	privateDatabase.save(record) { record, error in
		if let error = error {
			print("❗error while saving a new word in the cloud")
			print(error)
			dataContainer.viewContext.delete(managedObject)
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
				dataContainer.viewContext.delete(word)
			}
		}
	}
}

extension CKRecordID {
	var tuple: (String?, String?, String?) {
		return (recordName, zoneID.zoneName, zoneID.ownerName)
	}
}
