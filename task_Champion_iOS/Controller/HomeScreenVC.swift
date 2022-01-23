//
//  HomeScreenVC.swift
//  task_Champion_iOS
//
//  Created by Onurcan Sever on 2022-01-21.
//

import UIKit

struct Category {
    var name: String
    var items: [Item]
}

struct Item {
    var name: String
}

class HomeScreenVC: UIViewController {
    
    private var categories = [Category]()
    private var currentCategory: Category? = nil
    private var selectedIndex: Int = 0
    
    private let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        layout.scrollDirection = .horizontal
        
        return collectionView

    }()
            
    private let tasksTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        
        return searchBar
    }()
    
    private let addTaskButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemCyan
        button.layer.cornerRadius = 25
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageView?.tintColor = .white
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        dummyTestData()
        configureNavigationBar()
        configureCollectionView()
        configureTableView()
        configureSearchBar()
        configureAddTaskButton()
    }
    
    // MARK: - Selectors
    @objc private func displayCategories() {
        
    }
    
    @objc private func addNewTask() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new task", message: "Please enter the name of the task", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            
            let newItem = Item(name: textField.text!)
            self.categories[self.selectedIndex].items.append(newItem)
            
            DispatchQueue.main.async {
                self.tasksTableView.reloadData()
                self.categoryCollectionView.reloadData()
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Task name"
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UI Configuration Methods
extension HomeScreenVC {
    
    private func configureCollectionView() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.clipsToBounds = false
        categoryCollectionView.backgroundColor = .crystalWhite
        categoryCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        view.addSubview(categoryCollectionView)
        
        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            categoryCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
        ])
    }
    
    private func configureTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.backgroundColor = .crystalWhite
        tasksTableView.layer.cornerRadius = 20
        view.addSubview(tasksTableView)
        
        NSLayoutConstraint.activate([
            tasksTableView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 10),
            tasksTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            tasksTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            tasksTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["Sort by Task (A-Z)", "Sort by Date"]
        searchBar.layer.cornerRadius = 20
        searchBar.backgroundColor = .crystalWhite
        self.tasksTableView.tableHeaderView = searchBar
    }
    
    private func configureAddTaskButton() {
        view.addSubview(addTaskButton)
        addTaskButton.addTarget(self, action: #selector(addNewTask), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            addTaskButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addTaskButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addTaskButton.widthAnchor.constraint(equalToConstant: 50),
            addTaskButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureNavigationBar() {
        view.backgroundColor = .crystalWhite
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "book.circle"), style: .plain, target: self, action: #selector(displayCategories))
        rightBarButton.tintColor = .systemBlue
        
        navigationItem.rightBarButtonItem = rightBarButton
        self.title = "Welcome!"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

        
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
            
        self.view.frame.origin.y = 0 - keyboardSize.height
    }
        
    @objc private func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    // MARK: - Dummy Test Data
    private func dummyTestData() {
        categories.append(Category(name: "Business", items: [Item(name: "Testing"), Item(name: "Bsa")]))
        categories.append(Category(name: "Home", items: [Item(name: "Cleaning"), Item(name: "Cooking"), Item(name: "Shopping")]))
        
        currentCategory = categories[0]
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout & UICollectionViewDataSource
extension HomeScreenVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: categoryCollectionView.frame.width/2, height: categoryCollectionView.frame.width/2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
        
        cell.setData(category: categories[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentCategory = categories[indexPath.row]
        selectedIndex = indexPath.row
        self.tasksTableView.reloadData()
        
    }
    
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension HomeScreenVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories[selectedIndex].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell else { return UITableViewCell() }
        
        cell.setData(title: categories[selectedIndex].items[indexPath.row].name, isCompleted: nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete")
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension HomeScreenVC: UISearchBarDelegate {
    
}


extension UIColor {
    static let crystalWhite = UIColor(red: 233/255, green: 236/255, blue: 244/255, alpha: 1)
    static let lightCharcoal = UIColor(red: 36/255, green: 44/255, blue: 75/255, alpha: 1)
}
