//
//  ViewController.swift
//  LearningCoreData
//
//  Created by Matheus Torres on 02/11/20.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            fatalError("Couldn't fetch \(error) || \(error.userInfo)")
        }

        tableView.reloadData()
    }

    @IBAction func addNewName(_ sender: Any) {
        let addNameAlert = UIAlertController(title: "Adicionar novo nome", message: "Adicionar um novo nome à lista", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Adicionar", style: .default) { _ in
            guard let textField = addNameAlert.textFields!.first, let nameToSave = textField.text else { return }
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        
        addNameAlert.addAction(confirmAction)
        addNameAlert.addAction(cancelAction)
        addNameAlert.addTextField()
        
        present(addNameAlert, animated: true)
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            fatalError("Couldn't save \(error) || \(error.userInfo)")
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NameCell.reuseIdentifier, for: indexPath) as? NameCell
        else { fatalError("Couldn't create the cell") }
        
        cell.nameLabel.text = people[indexPath.row].value(forKey: "name") as? String
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

