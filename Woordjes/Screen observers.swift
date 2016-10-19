//
//  Screen observers.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 12/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import UIKit

var screenConnectionObserver, screenDisconnectionObserver: NSObjectProtocol?

func addScreenObservers() {
	screenConnectionObserver = notificationCenter.addObserver(forName: NSNotification.Name.UIScreenDidConnect, object: nil, queue: OperationQueue.main) { notification in
		createWindow(forExternalScreen: notification.object as! UIScreen)
	}
	screenDisconnectionObserver = notificationCenter.addObserver(forName: NSNotification.Name.UIScreenDidDisconnect, object: nil, queue: OperationQueue.main) { _ in
		externalWindow?.isHidden = true
		fullScreenLabel = nil
	}
}

func createWindow(forExternalScreen screen: UIScreen) {
	externalWindow = UIWindow(frame: screen.bounds)
	externalWindow!.screen = screen
	
	externalWindow!.rootViewController = ExternalView(nibName: "ExternalView", bundle: nil)
	externalWindow!.windowLevel = UIWindowLevelNormal
	externalWindow!.isHidden = false
}
