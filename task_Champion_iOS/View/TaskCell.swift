//
//  TaskCell.swift
//  task_Champion_iOS
//
//  Created by Onurcan Sever on 2022-01-22.
//

import UIKit

class TaskCell: UITableViewCell {
    
    public static let identifier = "TaskCell"
    
    private let taskLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightCharcoal
        
        return label
    }()
    
    private let completionView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 12.5
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(completionView)
        addSubview(taskLabel)
        backgroundColor = .crystalWhite
        
        NSLayoutConstraint.activate([
            completionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            completionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            completionView.heightAnchor.constraint(equalToConstant: 25),
            completionView.widthAnchor.constraint(equalToConstant: 25),
            
            taskLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            taskLabel.leadingAnchor.constraint(equalTo: completionView.trailingAnchor, constant: 10),
        ])
        
    }
    
    public func setData(title: String, isCompleted: Bool?) {
        self.taskLabel.text = title
    }

}
