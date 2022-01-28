//
//  SortButton.swift
//  task_Champion_iOS
//
//  Created by Onurcan Sever on 2022-01-28.
//

import UIKit

class SortButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        backgroundColor = .systemCyan
        layer.cornerRadius = 10
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
