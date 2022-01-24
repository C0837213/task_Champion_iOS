//
//  SubTaskVC.swift
//  task_Champion_iOS
//
//  Created by Philip Chau on 23/1/2022.
//

import UIKit

class SubTaskVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    var currentTask: Item?
    var categories = [Category]()
    var categoryIndex: Int?
    private var editMode: Bool = false

    @IBOutlet weak var taskNameLable: UILabel!
    @IBOutlet weak var taskDateLable: UILabel!
    @IBOutlet weak var taskDetailText: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var categoryPV: UIPickerView!
    
    //context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        taskNameLable.text = currentTask?.name
        taskDateLable.text = formatter.string(for: currentTask?.createdAt)
        taskDetailText.text = currentTask?.detail
        categoryPV.dataSource = self
        categoryPV.delegate = self
        categoryPV.selectRow(categoryIndex!, inComponent: 0, animated: true)
    }
    
    
    @IBAction func handleEditButtonOnclick(_ sender: UIButton) {
        self.editMode = !self.editMode
        if self.editMode == true {
            //UI changes
            editButton.setTitle("Save", for: .normal)
            editButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
            //enable editing
            taskDetailText.isEnabled = true
            categoryPV.isUserInteractionEnabled = true
        }
        else{
            //save data
            currentTask?.detail = taskDetailText.text
            saveData()
            //UI changes
            taskDetailText.isEnabled = false
            categoryPV.isUserInteractionEnabled = false
            editButton.setTitle("Edit", for: .normal)
            editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTask?.catFolder = categories[row]
    }
    
    
    private func saveData () {
        do {
            try context.save()
        }catch {
            print("Error saving categories.. \(error.localizedDescription)")
        }
    }

}
