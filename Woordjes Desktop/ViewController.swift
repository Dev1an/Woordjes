//
//  ViewController.swift
//  Woordjes Desktop
//
//  Created by Damiaan Dufaux on 10/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Cocoa

class DesktopViewController: NSViewController {

	var managedObjectContext = localContext
	
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

