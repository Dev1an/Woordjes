//
//  List+CoreDataProperties.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 14/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreData

extension WordList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordList> {
        return NSFetchRequest<WordList>(entityName: "WordList");
    }

    @NSManaged public var words: NSSet?

}

// MARK: Generated accessors for words
extension WordList {

    @objc(addWordsObject:)
    @NSManaged public func addToWords(_ value: Word)

    @objc(removeWordsObject:)
    @NSManaged public func removeFromWords(_ value: Word)

    @objc(addWords:)
    @NSManaged public func addToWords(_ values: NSSet)

    @objc(removeWords:)
    @NSManaged public func removeFromWords(_ values: NSSet)

}
