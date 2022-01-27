//
//  CategoryCell.swift
//  task_Champion_iOS
//
//  Created by Onurcan Sever on 2022-01-22.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    public static let identifier = "CategoryCell"
    
    override var isSelected: Bool {
        didSet {
            self.layer.shadowColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.black.cgColor
        }
    }
    
    private lazy var taskLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = " tasks"
        
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .lightCharcoal
        progressView.progressTintColor = .systemCyan
            
        return progressView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCellLayout()
        configureTaskLabel()
        configureCategoryLabel()
        configureProgressView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configureTaskLabel() {
        contentView.addSubview(taskLabel)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            taskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: taskLabel.trailingAnchor),
        ])
    }
    
    private func configureCategoryLabel() {
        contentView.addSubview(categoryLabel)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 10),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureProgressView() {
        contentView.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func configureCellLayout() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.layer.shadowColor = UIColor.black.cgColor

        self.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
    }
    
    public func setData(itemCounter: Int, name: String, progress: Int) {
        self.taskLabel.text = String(itemCounter)
        self.categoryLabel.text = name
        
        if progress > 0 {
            self.progressView.progress = Float(progress) / Float(itemCounter)
        }
        else {
            self.progressView.progress = 0.0
        }
        
    }
}

