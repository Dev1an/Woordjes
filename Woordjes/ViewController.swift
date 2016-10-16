//
//  ViewController.swift
//  Woordjes
//
//  Created by Damiaan Dufaux on 9/10/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

	var fetchedWordsController: NSFetchedResultsController<Word>?
	
	var newScrollPosition: IndexPath?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let request = Word.fetchAll()
		request.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true)]
		fetchedWordsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: localContext, sectionNameKeyPath: nil, cacheName: nil)
		
		fetchedWordsController!.delegate = self
		
		try? fetchedWordsController?.performFetch()
		
		addScreenObservers()
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
			textField.text = "woordje"
			textField.delegate = self
		}
		
		// 3. Grab the value from the text field, add it when the user clicks OK.
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
			add(word: alert.textFields!.first!.text!)
		}))
		
		// 4. Present the alert.
		self.present(alert, animated: true, completion: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// TODO: Dispose of any resources that can be recreated.
	}
}






// MARK: - Text field delegate
extension ViewController: UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		DispatchQueue.main.async {
			textField.selectAll(nil)
		}
		return true
	}
}






// MARK: - Table view Delegate
extension ViewController {
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if let controller = fetchedWordsController {
				remove(word: controller.object(at: indexPath))
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
		print("fetched results controller will change contents")
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
