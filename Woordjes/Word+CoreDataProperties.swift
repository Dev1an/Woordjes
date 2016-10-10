//
//  Word+CoreDataProperties.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 9/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreData


extension Word {
	
	convenience init(_ value: String, insertInto context: NSManagedObjectContext?) {
		self.init(entity: Word.entity(), insertInto: context)
		self.value = value
	}

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word");
    }

    @NSManaged public var value: String

}
