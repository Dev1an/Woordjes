//: Playground - noun: a place where people can play

import UIKit
import CloudKit

let record = CKRecord(recordType: "Word")
let emptyWordData = NSKeyedArchiver.archivedData(withRootObject: record)
emptyWordData.base64EncodedString()
record["value"] = "hello" as NSString
let helloData = NSKeyedArchiver.archivedData(withRootObject: record)
helloData.hashValue

let anotherRecord = CKRecord(recordType: "Word", recordID: record.recordID)
let otherEmptyWord = NSKeyedArchiver.archivedData(withRootObject: anotherRecord)
otherEmptyWord.base64EncodedString()

anotherRecord["value"] = "hello" as NSString
NSKeyedArchiver.archivedData(withRootObject: record.recordID)