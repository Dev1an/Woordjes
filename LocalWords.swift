//
//  LocalWords.swift
//  Woordjes
//
//  Created by Damiaan on 19-10-16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import CoreData
import CloudKit

// MARK: Update and Delete in local context

func insertWordWith(cloudRecord: CKRecord) -> Word {
	let managedObject = Word(cloudRecord["value"] as! String, insertInto: localContext)
	managedObject.cloudID = cloudRecord.recordID
	managedObject.creationDate = cloudRecord.creationDate ?? Date()
	return managedObject
}

func upsertWordWith(cloudRecord: CKRecord, completionHandler: ((Word)->Void)? ) {
	Word.exists(id: cloudRecord.recordID) { alreadyInLocalDatabase, word in
		if alreadyInLocalDatabase {
			DispatchQueue.main.async {
				word!.value = cloudRecord["value"] as! String
				print("Modified a word")
				completionHandler?(word!)
			}
		} else {
			DispatchQueue.main.async {
				print("➕ Added a word")
				completionHandler?(insertWordWith(cloudRecord: cloudRecord))
			}
		}
	}
}

func deleteWordWith(id: CKRecordID, completionHandler: (()->Void)? ) {
	Word.exists(id: id) { stillInContext, word in
		if stillInContext {
			print("delete \(word!.value) locally")
			DispatchQueue.main.async {
				localContext.delete(word!)
				completionHandler?()
			}
		} else {
			completionHandler?()
		}
	}
}

func deleteWordsWith(ids: [CKRecordID]) {
	let request = Word.fetchAll()
	request.predicate = predicateForRecordsWith(cloudIDs: ids)
	do {
		let words = try localContext.fetch(request)
		for word in words {
			localContext.delete(word)
		}
	} catch {
		print(error)
	}
}

// MARK: - Predicates
func predicateForRecordWith(cloudID: CKRecordID) -> NSPredicate {
	return NSPredicate(format: "cloudRecordName == %@ AND cloudRecordZoneName == %@ AND cloudRecordZoneOwnerName == %@", cloudID.recordName, cloudID.zoneID.zoneName, cloudID.zoneID.ownerName)
}
func predicateForRecordsWith(cloudIDs: [CKRecordID]) -> NSPredicate {
	return NSPredicate(format: "cloudRecordName IN %@ AND cloudRecordZoneName IN %@ AND cloudRecordZoneOwnerName IN %@", cloudIDs.map {$0.recordName}, cloudIDs.map {$0.zoneID.zoneName}, cloudIDs.map {$0.zoneID.ownerName})
}
