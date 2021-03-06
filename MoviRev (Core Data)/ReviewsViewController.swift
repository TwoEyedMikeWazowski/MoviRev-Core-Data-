//
//  DetailViewController.swift
//  MoviRev (Core Data)
//
//  Created by Daniel on 4/9/18.
//  Copyright © 2018 Placeholder Interactive. All rights reserved.
//

import UIKit
import CoreData

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var reviewsTableView: UITableView!
    var managedObjectContext: NSManagedObjectContext? = nil
    let cellReuseIdentifier = "reviewCell"
    var detailViewController: ReviewsViewController? = nil

    func configureView() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let movie = movie {
            self.title = "\(movie.name!)(\(movie.year))"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    var movie: Movie? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)
        let review = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withReview: review)
        return cell
    }
    
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withReview review: Review) {
        cell.textLabel!.text = "\(review.rating) STARS"
        cell.detailTextLabel!.text = review.body
    }
    
    var fetchedResultsController: NSFetchedResultsController<Review> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        NSFetchedResultsController<Review>.deleteCache(withName: "Master")
        
        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Filter for current movie
        
        let predicate = NSPredicate(format: "movie == %@", movie!)
        fetchRequest.predicate = predicate
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Review>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reviewsTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            reviewsTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            reviewsTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            reviewsTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            reviewsTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(reviewsTableView.cellForRow(at: indexPath!)!, withReview: anObject as! Review)
        case .move:
            configureCell(reviewsTableView.cellForRow(at: indexPath!)!, withReview: anObject as! Review)
            reviewsTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reviewsTableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     tableView.reloadData()
     }
     */

    @objc
    func insertNewObject(_ sender: Any) {
        let alert = UIAlertController(title: "Add New Review", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Review Rating (1 to 5)"
            textField.keyboardType = UIKeyboardType.numberPad
            
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Review Description"
            
        })
        
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let context = self.fetchedResultsController.managedObjectContext
            let newReview = Review(context: context)
            
            // If appropriate, configure the new managed object.
            newReview.timestamp = Date()
            newReview.body = alert.textFields![1].text
            newReview.rating = Int16(alert.textFields![0].text!)!
            newReview.movie = self.movie
            self.movie?.addToReviews(newReview)
            
            // Save the context.
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
        }
        alert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}

