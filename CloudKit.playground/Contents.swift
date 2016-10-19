//: Playground - noun: a place where people can play

import CloudKit
import CoreData

let deer = CKRecord(recordType: "Word")
//deer["value"] = "A" as NSString
//let recordId2 = CKRecordID(recordName: deer.recordID.recordName, zoneID: CKRecordZoneID(zoneName: deer.recordID.zoneID.zoneName, ownerName: deer.recordID.zoneID.ownerName))
//let recordId3 = CKRecordID(recordName: deer.recordID.recordName, zoneID: CKRecordZoneID(zoneName: deer.recordID.zoneID.zoneName, ownerName: deer.recordID.zoneID.ownerName))
//


deer.recordID
deer.recordID.copy(with: nil)