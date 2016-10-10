//
//  ExternalView.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 10/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import UIKit

var fullScreenLabel: UILabel?

class ExternalView: UIViewController {
	@IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
		fullScreenLabel = label
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
