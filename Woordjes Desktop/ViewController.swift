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
	@IBOutlet weak var tableView: NSTableView!
	var managedObjectContext = localContext
	
	override func deleteBackward(_ sender: Any?) {
		remove(word: wordsArrayController.selectedObjects.first as! Word)
	}
	
	func reload(_ sender: Any?) {
		cloudSyncToken = nil
		do {
			for word in try localContext.fetch(Word.fetchAll()) {
				localContext.delete(word)
			}
		} catch {
			print(error)
		}
		fetchCloudWords()
	}
	
	func addRow(_ sender: Any?) {
		add(word: "") { word in
			self.wordsArrayController.insert(word, atArrangedObjectIndex: 0)
			self.tableView.editSelectedRowAtColumn(withIdentifier: "Word")
		}
	}
	
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		return menuItem.tag == 1 ? wordsArrayController.selectionIndexes.count > 0 : true
	}
}

extension NSTableView {
	func editSelectedRowAtColumn(withIdentifier id: String) {
		if let column = tableColumn(withIdentifier: id), !column.isHidden && selectedRowIndexes.count == 1 {
			editColumn(self.column(withIdentifier: id), row: selectedRow, with: nil, select: true)
		}
	}
}
