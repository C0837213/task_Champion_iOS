//
//  SubTaskVC.swift
//  task_Champion_iOS
//
//  Created by Philip Chau on 23/1/2022.
//

import UIKit

class SubTaskVC: UIViewController {
    
    private let detailsLabel = TaskLabel(title: "Task name: ")
    private let categoriesLabel = TaskLabel(title: "Category: ")
    private let imagesLabel = TaskLabel(title: "Task images: ")
    private let audiosLabel = TaskLabel(title: "Task audios: ")

    private let taskTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.backgroundColor = .systemCyan
        textField.layer.cornerRadius = 10
        textField.textColor = .white
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 16)
        
        return textField
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        
        return stackView
    }()
    
    
    private let categoryMenu: UIPickerView = {
        let pickerView = UIPickerView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        return pickerView
    }()
    
    private let detailsTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 10
        textView.text = textView.text.isEmpty ? "Enter your task details here..." : textView.text
        
        return textView
    }()
    
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        layout.scrollDirection = .horizontal
        
        return collectionView

    }()
    
    private let audioTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AudioCell")
        tableView.layer.cornerRadius = 10
        
        return tableView
    }()
    
    private let importPhotoButton = ImportButton(image: "photo.circle.fill")
    private let importAudioButton = ImportButton(image: "mic.circle")
    private let takePhotoButton = ImportButton(image: "camera.circle")
    
    var list = ["Business", "Home", "Car"]//audio demo data
    var selectedImages = [UIImage]()
    
    var currentTask: Item?{
        didSet{
            taskTextField.text = currentTask?.name
            detailsTextView.text = currentTask?.detail
        }
    }
    var categories = [Category]()
    var categoryIndex: Int?
    public weak var delegate: HomeScreenVC?
    private var isAudioPlaying: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .crystalWhite
        
        title = "Display Date here"
        configureButtons()
        configureDetailsLabel()
        configureTaskTextField()
        configureCategoriesLabel()
        configureCategoryMenu()
        configureTextView()
        configureImagesLabel()
        configureCollectionView()
        configureAudiosLabel()
        configureTableView()
        configureStackView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.updateViews()
    }
    
    @objc private func importPhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func importAudioFromLibrary() {
        
    }
    
    private func configureDetailsLabel(){
        view.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            detailsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            detailsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            detailsLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    private func configureCategoriesLabel() {
        view.addSubview(categoriesLabel)
        
        NSLayoutConstraint.activate([
            categoriesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoriesLabel.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 10),
            categoriesLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureImagesLabel() {
        view.addSubview(imagesLabel)
        
        NSLayoutConstraint.activate([
            imagesLabel.topAnchor.constraint(equalTo: detailsTextView.bottomAnchor, constant: 20),
            imagesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imagesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func configureAudiosLabel() {
        view.addSubview(audiosLabel)
        
        NSLayoutConstraint.activate([
            audiosLabel.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 15),
            audiosLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            audiosLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
        
    private func configureTaskTextField() {
        view.addSubview(taskTextField)
        
        NSLayoutConstraint.activate([
            taskTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            taskTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            taskTextField.leadingAnchor.constraint(equalTo: detailsLabel.trailingAnchor, constant: 10),
            taskTextField.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    private func configureCategoryMenu() {
        categoryMenu.delegate = self
        categoryMenu.dataSource = self
        view.addSubview(categoryMenu)
        
        NSLayoutConstraint.activate([
            categoryMenu.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 10),
            categoryMenu.widthAnchor.constraint(equalTo: taskTextField.widthAnchor),
            categoryMenu.leadingAnchor.constraint(equalTo: categoriesLabel.trailingAnchor, constant: 10),
            categoryMenu.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureTextView() {
        view.addSubview(detailsTextView)
        
        NSLayoutConstraint.activate([
            detailsTextView.topAnchor.constraint(equalTo: categoryMenu.bottomAnchor, constant: 25),
            detailsTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            detailsTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            detailsTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func configureCollectionView() {
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.clipsToBounds = false
        imageCollectionView.backgroundColor = .crystalWhite
        view.addSubview(imageCollectionView)
        
        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: imagesLabel.bottomAnchor, constant: 5),
            imageCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            imageCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            imageCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.20)
        ])
    }
    
    private func configureTableView() {
        audioTableView.delegate = self
        audioTableView.dataSource = self
        audioTableView.backgroundColor = .crystalWhite
        view.addSubview(audioTableView)
        
        NSLayoutConstraint.activate([
            audioTableView.topAnchor.constraint(equalTo: audiosLabel.bottomAnchor, constant: 20),
            audioTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            audioTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
        ])
    }
    
    private func configureStackView() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: audioTableView.bottomAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 60),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        stackView.addArrangedSubview(takePhotoButton)
        stackView.addArrangedSubview(importPhotoButton)
        stackView.addArrangedSubview(importAudioButton)
    }
    
    private func configureButtons() {
        importPhotoButton.addTarget(self, action: #selector(importPhotoFromLibrary), for: .touchUpInside)
        
        importAudioButton.addTarget(self, action: #selector(importAudioFromLibrary), for: .touchUpInside)
        
    }
    

}

extension SubTaskVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTask?.catFolder = categories[row]
    }
    
}

extension SubTaskVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageCollectionView.frame.width/2, height: imageCollectionView.frame.width/2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        cell.setData(image: selectedImages[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete current selected image?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.selectedImages.remove(at: indexPath.row)
            self.imageCollectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
}

extension SubTaskVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath)
        
        cell.textLabel?.text = list[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let playAction = UIContextualAction(style: .normal, title: isAudioPlaying ? "Stop" : "Play") { action, view, completion in
            
            self.isAudioPlaying = !self.isAudioPlaying
            // Playing audio / Stop audio
            completion(true)
            
            self.audioTableView.reloadData()
            
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            
            // Deleting current audio
            
            completion(true)
        }
        
        playAction.backgroundColor = isAudioPlaying ? .systemOrange : .systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, playAction])
        
        return configuration
        
    }
    
}

extension SubTaskVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            selectedImages.append(image)
        }
        
        picker.dismiss(animated: true, completion: nil)
        imageCollectionView.reloadData()
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
