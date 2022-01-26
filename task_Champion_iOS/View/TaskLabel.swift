//
//  TaskLabel.swift
//  task_Champion_iOS
//
//  Created by Onurcan Sever on 2022-01-26.
//

import UIKit

class TaskLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont.boldSystemFont(ofSize: 16)
        self.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
