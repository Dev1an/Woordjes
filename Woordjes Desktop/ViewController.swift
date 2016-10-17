//
//  ViewController.swift
//  Woordjes Desktop
//
//  Created by Damiaan Dufaux on 10/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Cocoa

class DesktopViewController: NSViewController {

	@IBOutlet var wordsArrayController: NSArrayController!
	var managedObjectContext = localContext
	
	override func deleteBackward(_ sender: Any?) {
		remove(word: wordsArrayController.selectedObjects.first as! Word)
	}
	
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		return wordsArrayController.selectionIndexes.count > 0
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

