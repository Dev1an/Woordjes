//
//  Word+CoreDataProperties.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 10/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word");
    }

    @NSManaged public var value: String?

}
