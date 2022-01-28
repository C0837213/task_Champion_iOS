//
//  CategoryTVC.swift
//  task_Champion_iOS
//
//  Created by Onurcan Sever on 2022-01-25.
//

import UIKit
import CoreData

class CategoryTVC: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    public weak var delegate: HomeScreenVC?
    public var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        loadCategories()
        view.backgroundColor = .crystalWhite
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewCategory))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.updateCategories(categories: self.categories)
        delegate?.updateViews()
    }
    
    @objc private func addNewCategory() {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a Category", message: "Please name your category", preferredStyle: .alert)
        
        alert.addTextField { field in
            textField = field
        }
        
        let okAction = UIAlertAction(title: "Add", style: .default) { action in
            
            guard let text = textField.text else {
                return
            }
            
            if text.count > 1 {
                let newCategory = Category(context: self.context)
                newCategory.name = text
                self.categories.append(newCategory)
                
                self.saveData()
                self.loadCategories()
                
                self.tableView.reloadData()
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { action in
            
            self.loadCategories()
                        
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        cell.backgroundColor = .crystalWhite

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            
            self.context.delete(self.categories[indexPath.row])
            self.saveData()
            self.categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.reloadData()
            
            completion(true)
            
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { action, view, completion in
            
            var textField = UITextField()
            let alert = UIAlertController(title: "Edit Category", message: "Please enter a name to change the category name", preferredStyle: .alert)
            
            alert.addTextField { field in
                textField = field
            }
            
            textField.text = self.categories[indexPath.row].name
            
            let changeAction = UIAlertAction(title: "Edit", style: .default) { action in
                
                guard let text = textField.text else { return }
                
                self.categories[indexPath.row].name = text
                
                self.saveData()
                self.loadCategories()
                self.delegate?.updateViews()
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                
                self.loadCategories()
                
            }
            
            alert.addAction(changeAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            completion(true)
            
        }
        
        editAction.backgroundColor = .systemGray2
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        
        return configuration
        
    }
    
    private func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving context... \(error.localizedDescription)")
        }
    }
    
    private func loadCategories() {
        let request:NSFetchRequest<Category> = Category.fetchRequest()
        do {
            self.categories = try context.fetch(request)
        } catch {
            print("Error load categories ... \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }

}
