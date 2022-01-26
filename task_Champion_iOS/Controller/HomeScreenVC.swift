//
//  HomeScreenVC.swift
//  task_Champion_iOS
//
//  Created by Onurcan Sever on 2022-01-21.
//

import UIKit
import CoreData

class HomeScreenVC: UIViewController {
    
    private var categories = [Category]()
    private var currentCategory: Category? = nil
    private var items = [Item]()
    private var selectedIndex: Int = 0
    private var currentTask: Item? = nil
    
    //context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
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
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        return stackView
    }()
    
    private let sortByTaskButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sort by Task (A - Z)", for: .normal)
        button.backgroundColor = .systemCyan
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(sortByTask), for: .touchUpInside)
        
        return button
    }()
    
    private let sortByDateButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sort by Date", for: .normal)
        button.backgroundColor = .systemCyan
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(sortByDate), for: .touchUpInside)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        loadCategories()
        insertData()
        configureNavigationBar()
        configureCollectionView()
        configureSearchBar()
        configureStackView()
        configureTableView()
        configureAddTaskButton()
    }
    
    
    
    // MARK: - Selectors
    @objc private func displayCategories() {
        
    }
    
    @objc private func addNewItem() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new task", message: "Please enter the name of the task", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            
            let newItem = Item(context: self.context)
            newItem.name = textField.text!
            newItem.catFolder = self.currentCategory!
            self.items.append(newItem)
            self.saveData()
            
            DispatchQueue.main.async {
                self.tasksTableView.reloadData()
                self.categoryCollectionView.reloadData()
                self.categoryCollectionView.selectItem(at: IndexPath(row: self.selectedIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            }
            
            self.loadItems()
            
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
    
    @objc private func sortByTask() {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        loadItems(with: nil, by: [sortDescriptor])
        
        self.tasksTableView.reloadData()
    }
    
    @objc private func sortByDate() {
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        loadItems(with: nil, by: [sortDescriptor])
        
        self.tasksTableView.reloadData()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
            
        self.view.frame.origin.y = 100 - keyboardSize.height
    }
        
    @objc private func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    public func updateViews() {
        self.categoryCollectionView.reloadData()
        self.tasksTableView.reloadData()
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
            tasksTableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            tasksTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            tasksTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            tasksTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    private func configureSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 20
        searchBar.backgroundColor = .crystalWhite
                
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureAddTaskButton() {
        view.addSubview(addTaskButton)
        addTaskButton.addTarget(self, action: #selector(addNewItem), for: .touchUpInside)
        
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

    private func configureStackView() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        stackView.addArrangedSubview(sortByTaskButton)
        stackView.addArrangedSubview(sortByDateButton)
    }
    
    
    // MARK: - Dummy Test Data
    private func insertData() {
        if(categories.count == 0) {
        let categories1 = Category(context: context)
        categories1.name = "Business"
        self.categories.append(categories1)
        
        let newItem1 = Item(context: context)
        newItem1.name = "Testing"
        newItem1.catFolder = categories1
        self.items.append(newItem1)
        
        let newItem2 = Item(context: context)
        newItem2.name = "Bsa"
        newItem2.catFolder = categories1
        self.items.append(newItem2)
        
        let categories2 = Category(context: context)
        categories2.name = "Home"
        self.categories.append(categories2)
        
        let newItem3 = Item(context: context)
        newItem3.name = "Cleaning"
        newItem3.catFolder = categories2
        self.items.append(newItem3)
        
        let newItem4 = Item(context: context)
        newItem4.name = "Cooking"
        newItem4.catFolder = categories2
        self.items.append(newItem4)
        
        let newItem5 = Item(context: context)
        newItem5.name = "Shopping"
        newItem5.catFolder = categories2
        self.items.append(newItem5)
        
        self.saveData()
        self.loadCategories()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let subTaskVc = segue.destination as! SubTaskVC
        subTaskVc.currentTask = self.currentTask
        subTaskVc.categoryIndex = self.selectedIndex
        subTaskVc.categories = self.categories
        subTaskVc.delegate = self
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
        
        
        let text = categories[indexPath.row].items?.count ?? 0
        let name = categories[indexPath.row].name ?? ""
        
        cell.setData(text:text, name: name)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentCategory = categories[indexPath.row]
        self.loadItems()
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
        return categories[selectedIndex].items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell else { return UITableViewCell() }
         let title = items[indexPath.row].name ?? ""
        cell.setData(title: title, isCompleted: nil)

        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(items[indexPath.row])
            saveData()
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.categoryCollectionView.reloadData()
            categoryCollectionView.selectItem(at: IndexPath(row: selectedIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTask = self.items[indexPath.row]
        performSegue(withIdentifier: "reviewTaskDetails", sender: self)
    }

    //MARK: - CoreDate Methods
    private func loadCategories() {
        let request:NSFetchRequest<Category> = Category.fetchRequest()
        do {
            self.categories = try context.fetch(request)
            if (categories.count>0) {
                self.currentCategory = categories[0]
                self.loadItems()
            }
        } catch {
            print("Error load categories ... \(error.localizedDescription)")
        }
    }
    
    private func saveData () {
        do {
            try context.save()
        }catch {
            print("Error saving categories.. \(error.localizedDescription)")
        }
    }
    
    private func loadItems(with predicate: NSPredicate? = nil, by sort: [NSSortDescriptor]? = nil) {
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        let itemPredicate = NSPredicate(format: "catFolder.name=%@", currentCategory!.name!)
        
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [itemPredicate, predicate])
        }
        else {
            request.predicate = itemPredicate
        }
        
        request.sortDescriptors = sort
        
        do {
            self.items = try context.fetch(request)
        } catch {
            print("Error load items ... \(error.localizedDescription)")
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

extension Item {
    override public func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "createdAt")
    }
}


