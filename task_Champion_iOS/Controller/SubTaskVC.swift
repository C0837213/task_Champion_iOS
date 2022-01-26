//
//  SubTaskVC.swift
//  task_Champion_iOS
//
//  Created by Philip Chau on 23/1/2022.
//

import UIKit

class SubTaskVC: UIViewController {
    
    private let detailsLable: UILabel = {
        let detailsLable = UILabel()
        detailsLable.translatesAutoresizingMaskIntoConstraints = false
        detailsLable.text = "Task Name :"
        
        return detailsLable
    }()

    private let taskTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.backgroundColor = .systemCyan
        textField.layer.cornerRadius = 10
        textField.textColor = .white
        textField.textAlignment = .center
        textField.text = "Shopping"
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
    
    private let categoriesLable: UILabel = {
        let detailsLable = UILabel()
        detailsLable.translatesAutoresizingMaskIntoConstraints = false
        detailsLable.text = "Category :"
        
        return detailsLable
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
    
    private var editingMode: Bool = false
    var list = ["Business", "Home", "Car"]//audio demo data
    var images = ["car.circle.fill", "mic.circle"]//photo demo data
    var selectedImages = [UIImage]()
    var currentTask: Item?{
        didSet{
            taskTextField.text = currentTask?.name
            detailsTextView.text = currentTask?.detail
        }
    }
    var categories = [Category]()
    var categoryIndex: Int?
    private var editMode: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .crystalWhite
        
        title = "Shopping"
        navigationItem.rightBarButtonItem = editButtonItem
        configureButtons()
        configureDetailsLable()
        configureTaskTextField()
        configureCategoriesLable()//this is not work
        configureCategoryMenu()
        configureTextView()
        configureCollectionView()
        configureTableView()
        configureStackView()
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
    
    private func configureDetailsLable(){
        view.addSubview(detailsLable)
        NSLayoutConstraint.activate([
            detailsLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            detailsLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -300),
            detailsLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            detailsLable.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
        
    private func configureTaskTextField() {
        view.addSubview(taskTextField)
        
        NSLayoutConstraint.activate([
            taskTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            taskTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            taskTextField.leadingAnchor.constraint(equalTo: detailsLable.trailingAnchor, constant: 0),
            taskTextField.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    private func configureCategoriesLable(){
        view.addSubview(categoriesLable)
        NSLayoutConstraint.activate([
            detailsLable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            detailsLable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -200),
            detailsLable.topAnchor.constraint(equalTo: detailsLable.bottomAnchor, constant: 10),
            detailsLable.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureCategoryMenu() {
        categoryMenu.delegate = self
        categoryMenu.dataSource = self
        view.addSubview(categoryMenu)
        
        NSLayoutConstraint.activate([
            categoryMenu.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 10),
            categoryMenu.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60),
            categoryMenu.leadingAnchor.constraint(equalTo: categoriesLable.trailingAnchor, constant: 60),
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
            imageCollectionView.topAnchor.constraint(equalTo: detailsTextView.bottomAnchor, constant: 5),
            imageCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            imageCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            imageCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
        ])
    }
    
    private func configureTableView() {
        audioTableView.delegate = self
        audioTableView.dataSource = self
        audioTableView.backgroundColor = .crystalWhite
        view.addSubview(audioTableView)
        
        NSLayoutConstraint.activate([
            audioTableView.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 20),
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
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return categories[row].name
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
