//
//  PreferencesController.swift
//  Woordjes
//
//  Created by Damiaan on 17-10-16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Cocoa

class PreferencesController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
	@IBAction func resetDatabase(_ sender: AnyObject) {
		cloudSyncToken = nil
		localContext.reset()
		fetchCloudWords()
	}
}