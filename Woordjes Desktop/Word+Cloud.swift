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
			if let record = cloudRecord {
				
				privateDatabase.save(record) { record, error in
					if let error = error {
						print("❗error while saving a new word in the cloud")
						print(error)
						self.value = oldValue
					}
				}
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
