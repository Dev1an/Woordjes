//
//  WordSaver.swift
//  Woordjes
//
//  Created by Damiaan on 16-10-16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import CloudKit

extension Word {
	public class func keyPathsForValuesAffectingSyncedValue() -> Set<String> {
		return ["value"]
	}
	
	dynamic var syncedValue: String {
		get { return value }
		set {
			let oldValue = value
			value = newValue
			if let word = cloudRecord {
				let update = CKModifyRecordsOperation(recordsToSave: [word], recordIDsToDelete: nil)
				update.database = privateDatabase
				update.savePolicy = .changedKeys
				update.modifyRecordsCompletionBlock = { addedWords, removedWords, error in
					if let error = error {
						print("❗️Error while modifying \(oldValue) to \(self.value)")
						print(error)
						DispatchQueue.main.async {
							self.value = oldValue
							print("reverted value to \(self.value)")
						}
					}
				}
				update.start()
			}
		}
	}
	
	var cloudRecord: CKRecord? {
		if let id = cloudID {
			let record = CKRecord(recordType: "Word", recordID: id)
			record["value"] = value as NSString
			return record
		}
		return nil
	}
}
