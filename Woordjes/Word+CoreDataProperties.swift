//
//  Word+CoreDataProperties.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 14/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreData

extension Word {
	
	convenience init(_ value: String, insertInto context: NSManagedObjectContext?) {
		self.init(entity: Word.entity(), insertInto: context)
		self.value = value
	}

    @nonobjc public class func fetchAll() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word");
    }

	@NSManaged public var value: String
	@NSManaged public var creationDate: Date
    @NSManaged public var cloudRecordName: String?
    @NSManaged public var cloudRecordZoneName: String?
    @NSManaged public var cloudRecordZoneOwnerName: String?
    @NSManaged public var list: WordList?

	var cloudID: (String?, String?, String?) {
		get {
			return (cloudRecordName, cloudRecordZoneName, cloudRecordZoneOwnerName)
		}
		set {
			cloudRecordName = newValue.0
			cloudRecordZoneName = newValue.1
			cloudRecordZoneOwnerName = newValue.2
		}
	}

}
