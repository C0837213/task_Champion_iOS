//
//  CategoryTVC.swift
//  task_Champion_iOS
//
//  Created by Onurcan Sever on 2022-01-25.
//

import UIKit
/*
class CategoryTVC: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default , handler: {
            _ in
            let alert = UIAlertController(title: "Edit Item", message: "Edit Category", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text=item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: {[weak self] _ in
                guard let field = alert.textFields?.first,let newName = field.text, !newName .isEmpty else{
                    return
                }
                self?.updateItem(item: item, newName: newName)
            }))
            self.present(alert,animated: true)
        
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler:{ [weak self]_ in
       
            self?.deleteItem(item: item)
        } ))
        present(sheet,animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name

        return cell
    }
    


}

*/
