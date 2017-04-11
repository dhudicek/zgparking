//
//  SettingsViewController.swift
//  ZGParking
//
//  Created by Damjan Hudiček on 11/04/2017.
//  Copyright © 2017 ngajski. All rights reserved.
//

import UIKit
import CoreData
private let reuseIdentifier = "Cell"

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noCarsLabel: UILabel!
    
    let context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    lazy var fetchedResultsController: NSFetchedResultsController<Car> = {
        let fetchRequest: NSFetchRequest<Car> = NSFetchRequest(entityName: "Car")
        let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptors]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CarTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        initAddCarButton()
        do {
            try self.fetchedResultsController.performFetch()
        }
        catch {
            print("fetching failed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initAddCarButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton
        self.noCarsLabel.text = "Dodajte auto!"
    }
    
    func addButtonTapped() {
        let addCarViewController = AddCarViewController()
        self.navigationController?.pushViewController(addCarViewController, animated: true)
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            if (sectionInfo.numberOfObjects == 0) {
                self.hideTableView()
            }
            else{
                self.showTableView()
            }
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! CarTableViewCell
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            PersistenceService.removeCar(car: fetchedResultsController.object(at: indexPath))
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func hideTableView() {
        UIView.animate(withDuration: 0.5, animations: {
        self.tableView.alpha = 0.0
        self.noCarsLabel.alpha = 1.0})
    }
    
    private func showTableView() {
        UIView.animate(withDuration: 0.0, animations: {
        self.tableView.alpha = 1.0
        self.noCarsLabel.alpha = 0.0})
    }
    
}

extension SettingsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! CarTableViewCell
                configureCell(cell: cell, indexPath: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
    func configureCell(cell: CarTableViewCell, indexPath: IndexPath) {
        let car = fetchedResultsController.object(at: indexPath)
        if let name = car.name,
            let licensePlate = car.licensePlate {
            cell.set(name: name, licensePlate: licensePlate)
        }
    }
   
}
