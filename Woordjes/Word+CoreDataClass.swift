//
//  Word+CoreDataClass.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 13/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

public class Word: NSManagedObject {
	class func by(id: CKRecordID, handler: (Word) -> Void) {
		exists(id: id) { if $0 { handler($1!) } }
	}
	
	class func exists(id: CKRecordID, handler: (Bool, Word?) -> Void){
		let request = NSFetchRequest<Word>(entityName: "Word")
		request.predicate = NSPredicate(format: "cloudRecordName == %@ AND cloudRecordZoneName == %@ AND cloudRecordZoneOwnerName == %@", id.tuple.0!, id.tuple.1!, id.tuple.2!)
		request.fetchLimit = 1
		request.propertiesToFetch = []
		if let words = try? dataContainer.viewContext.fetch(request) {
			if words.count > 0 {
				handler(true, words.first!)
			} else {
				handler(false, nil)
			}
		} else {
			handler(false, nil)
		}
	}
}
