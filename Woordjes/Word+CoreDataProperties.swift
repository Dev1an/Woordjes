//
//  Word+CoreDataProperties.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 14/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

@objc public enum LocalOperation: Int16 {
	case delete = 0, insert, update, none
}

extension Word {
	
	convenience init(_ value: String, insertInto context: NSManagedObjectContext?) {
		self.init(entity: Word.entity(), insertInto: context)
		self.value = value
		self.localOperation = .none
	}

    @nonobjc public class func fetchAll() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word");
    }

	@NSManaged public var value: String
	@NSManaged public var creationDate: Date
    @NSManaged public var list: WordList?
	@NSManaged public var localOperation: LocalOperation
	@NSManaged public var cloudRecordName: String?
	@NSManaged public var cloudRecordZoneName: String?
	@NSManaged public var cloudRecordZoneOwnerName: String?
	
	public class func keyPathsForValuesAffectingCloudID() -> Set<String> {
		return ["cloudRecordName", "cloudRecordZoneName", "cloudRecordZoneOwnerName"]
	}
	
	var cloudID: CKRecordID? {
		get {
			if let name = cloudRecordName, let zone=cloudRecordZoneName, let owner = cloudRecordZoneOwnerName {
				return CKRecordID(recordName: name, zoneID: CKRecordZoneID(zoneName: zone, ownerName: owner))
			}
			return nil
		}
		set {
			cloudRecordName = newValue?.recordName
			cloudRecordZoneName = newValue?.zoneID.zoneName
			cloudRecordZoneOwnerName = newValue?.zoneID.ownerName
		}
	}
	
	class func predicateForRecordWith(cloudID: CKRecordID) -> NSPredicate {
		return NSPredicate(format: "cloudRecordName == %@ AND cloudRecordZoneName == %@ AND cloudRecordZoneOwnerName == %@", cloudID.recordName, cloudID.zoneID.zoneName, cloudID.zoneID.ownerName)
	}

	class func predicateForRecordsWith(cloudIDs: [CKRecordID]) -> NSPredicate {
		return NSPredicate(format: "cloudRecordName IN %@ AND cloudRecordZoneName IN %@ AND cloudRecordZoneOwnerName IN %@", cloudIDs.map {$0.recordName}, cloudIDs.map {$0.zoneID.zoneName}, cloudIDs.map {$0.zoneID.ownerName})
	}
}
