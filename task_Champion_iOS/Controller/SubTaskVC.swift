//
//  SubTaskVC.swift
//  task_Champion_iOS
//
//  Created by Philip Chau on 23/1/2022.
//

import UIKit

struct Task {
    var name: String
    var date: Date?
    var detail: String?
}

class SubTaskVC: UIViewController {
    
    var currentTask: Item? = nil

    @IBOutlet weak var taskNameLable: UILabel!
    @IBOutlet weak var taskDateLable: UILabel!
    @IBOutlet weak var taskCategoryLable: UILabel!
    @IBOutlet weak var taskDetailText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        taskNameLable.text = currentTask?.name
//        taskDateLable.text = formatter.string(for: currentTask.date)
//        taskDetailText.text = currentTask.detail
    }
    
    
    

}
