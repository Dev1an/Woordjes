//
//  ViewController.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 9/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import UIKit
import CoreData

var screenConnectionObserver, screenDisconnectionObserver: NSObjectProtocol?

func addObservers() {
	print("adding observers")
	screenConnectionObserver = notificationCenter.addObserver(forName: NSNotification.Name.UIScreenDidConnect, object: nil, queue: OperationQueue.main) { notification in
		createWindow(forExternalScreen: notification.object as! UIScreen)
	}
	screenDisconnectionObserver = notificationCenter.addObserver(forName: NSNotification.Name.UIScreenDidDisconnect, object: nil, queue: OperationQueue.main) { _ in
		externalWindow?.isHidden = true
		fullScreenLabel = nil
	}
}

class ViewController: UITableViewController {

	var fetchedWordsController: NSFetchedResultsController<Word>?
	
	var newScrollPosition: IndexPath?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let request = NSFetchRequest<Word>(entityName: "Word")
		request.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true)]
		fetchedWordsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		
		fetchedWordsController!.delegate = self
		
		try? fetchedWordsController?.performFetch()
		
		addObservers()
	}
	
	func configureCell(_ cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let fetchedWordsController = fetchedWordsController {
			let woord = fetchedWordsController.object(at: indexPath)
			cell.textLabel?.text = woord.value
		}
	}
		
	@IBAction func addWord(_ sender: AnyObject) {
		//1. Create the alert controller.
		let alert = UIAlertController(title: "Nieuw woord", message: "Voeg een nieuw woord toe", preferredStyle: .alert)

		//2. Add the text field. You can configure it however you need.
		alert.addTextField { (textField) in
			textField.text = "Some default text."
		}
		
		// 3. Grab the value from the text field, and print it when the user clicks OK.
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
			Word(alert.textFields!.first!.text!, insertInto: dataContainer.viewContext)
			appDelegate.saveContext()
		}))
		
		// 4. Present the alert.
		self.present(alert, animated: true, completion: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// TODO: Dispose of any resources that can be recreated.
	}
}





// MARK: - Table view Delegate
extension ViewController {
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if let controller = fetchedWordsController {
				dataContainer.viewContext.delete(controller.object(at: indexPath))
				appDelegate.saveContext()
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		fullScreenLabel?.text = fetchedWordsController?.object(at: indexPath).value
	}
}





// MARK: - Data source
extension ViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedWordsController?.sections?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sections = fetchedWordsController?.sections else {
			return 0
		}
		return sections[section].numberOfObjects
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "word")
			else {
				return UITableViewCell(style: .default, reuseIdentifier: nil)
		}
		configureCell(cell, forRowAt: indexPath)
		return cell
	}
}





// MARK: - Fetched results controller
extension ViewController: NSFetchedResultsControllerDelegate {
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
		case .delete:
			tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
		default:
			break
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			tableView.insertRows(at: [newIndexPath!], with: .automatic)
			newScrollPosition = newIndexPath
		case .delete:
			tableView.deleteRows(at: [indexPath!], with: .automatic)
		case .update:
			configureCell(tableView.cellForRow(at: indexPath!)!, forRowAt: indexPath!)
		case .move:
			tableView.moveRow(at: indexPath!, to: newIndexPath!)
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
		if let position = newScrollPosition {
			tableView.scrollToRow(at: position, at: .none, animated: true)
			newScrollPosition = nil
		}
	}
}
