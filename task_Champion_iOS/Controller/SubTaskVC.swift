//
//  SubTaskVC.swift
//  task_Champion_iOS
//
//  Created by Philip Chau on 23/1/2022.
//

import UIKit
import AVFoundation
import UniformTypeIdentifiers
import MobileCoreServices

class SubTaskVC: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
    
    private func setCurrentTask() {
        taskTextField.text = currentTask?.name
        detailsTextView.text = currentTask?.detail
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        title = "Created at: \(formatter.string(from: (currentTask?.createdAt ?? Date()))) "
        let objects = currentTask!.photos!
        if objects.count > 0 {
            for object in objects {
                do {
                    let unarchivedObj = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSData.self, from: object)! as Data
                    photos.append(unarchivedObj)
                } catch {
                    print("Cannot unarchive the data \(error)")
                }
            }
        }
        
    }
    
    private let importPhotoButton = ImportButton(image: "photo.circle.fill")
    private let takePhotoButton = ImportButton(image: "camera.circle")
    private let recordAudioButton = ImportButton(image: "mic.circle")
    private let importAudioFileButton = ImportButton(image: "speaker.circle")
    
    var recordingSession: AVAudioSession!
    
    var recorder: AVAudioRecorder!
    var player =  AVAudioPlayer ()

    

    var selectedImages = [UIImage]()
    private var audioFileName = ""
    var currentTask: Item?
    var categories = [Category]()
    var categoryIndex: Int?
    public weak var delegate: HomeScreenVC?
    private var isAudioPlaying: Bool = false
    var photos: [Data] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .crystalWhite
        navigationController?.navigationBar.largeTitleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 16)]

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

        recordingSession = AVAudioSession.sharedInstance()
        categoryMenu.selectRow(categoryIndex!, inComponent: 0, animated: true)
        setCurrentTask()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentTask?.name = taskTextField.text
        currentTask?.detail = detailsTextView.text
        saveData()
        delegate?.updateViews()
        delegate?.updateSelectedIndex(aCategory: currentTask?.catFolder)
        isAudioPlaying = false
    }
    
    @objc private func importPhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func recordingVoice() {
        if recorder == nil {
            self.initialseRecording()
            print("initialse")
        } else {
            self.finishRecording(success: true)
        }
    }
    
    @objc private func importAudioFile() {
        self.importAudFile()
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
        stackView.addArrangedSubview(recordAudioButton)
        stackView.addArrangedSubview(importAudioFileButton)
    }
    
    private func configureButtons() {
        importPhotoButton.addTarget(self, action: #selector(importPhotoFromLibrary), for: .touchUpInside)
        
        recordAudioButton.addTarget(self, action: #selector(recordingVoice), for: .touchUpInside)
        
        importAudioFileButton.addTarget(self, action: #selector(importAudioFile), for: .touchUpInside)
        
    }
    
    private func saveData () {
        do {
            try context.save()
        }catch {
            print("Error saving categories.. \(error.localizedDescription)")
        }
    }

}
//MARK: Category Picker Delegate
extension SubTaskVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        if currentTask?.isCompleted == true {
            pickerView.isUserInteractionEnabled = false
            return
        }
        
        currentTask?.catFolder = categories[row]
    }
    
}

//MARK: Image Collection View Delegate
extension SubTaskVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageCollectionView.frame.width/2, height: imageCollectionView.frame.width/2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else { return UICollectionViewCell() }

        
        cell.setData(image: UIImage(data: (photos[indexPath.row]) as Data))
        
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


//MARK: - Audio Table Delegate
extension SubTaskVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTask!.audios?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath)
        
        cell.textLabel?.text = "Audio File "  + String(indexPath.row + 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.isAudioPlaying == false) {
           self.playSound((self.currentTask?.audios![indexPath.row])!)
       } else {
           self.player.stop()
       }

       self.isAudioPlaying = !self.isAudioPlaying

       self.audioTableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            
            // Deleting current audio
            self.currentTask?.audios?.remove(at: indexPath.row)
            
            self.audioTableView.reloadData()
            completion(true)
        }
        

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
        
    }
    
}


//MARK: - Image Picker Delegate
extension SubTaskVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            selectedImages.append(image)

            for img in selectedImages{
                let data : NSData = NSData(data: img.pngData()!)
                do {
                    let coreDataObject = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
                    photos.append(coreDataObject)
                }catch{
                    print("Can't archive data \(error)")
                }
            }
            self.currentTask?.photos = photos
            self.saveData()
        }
        
        picker.dismiss(animated: true, completion: nil)
        imageCollectionView.reloadData()
        }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: - Doc Picker Delegate
extension SubTaskVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {return}
        let asset = AVURLAsset(url: url)
        guard asset.isComposable else {
            let alert = UIAlertController(title: "Error", message: "Your music is Not Composibble", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            return
        }
        // TODO: - sync with core data
        print(asset.url, "documentPicker")
        if self.currentTask?.audios == nil {
            self.currentTask?.audios = []
        }
        self.currentTask?.audios?.append(asset.url)
        
        self.audioTableView.reloadData()
    }
    
    private func importAudFile() {
        let supportedTypes: [UTType] = [UTType.audio]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
}

extension SubTaskVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isAudioPlaying = false
        self.audioTableView.reloadData()
    }
    private func playSound (_ URL: URL) {
        do {
            let sound = try AVAudioPlayer.init(contentsOf: URL)
            self.player = sound
            sound.numberOfLoops = 0
            sound.prepareToPlay()
            sound.play()
            
        }catch {
            print ("Error in play the sound file")
        }
    }
}

//MARK: Recording Delegete
extension SubTaskVC: AVAudioRecorderDelegate {

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func getRecordingURL(_ fileName : String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    private func startRec() {
        audioFileName = "recording" + UUID().uuidString + ".m4a"
        let audioURL = getRecordingURL(audioFileName)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: settings)
            recorder.delegate = self
            recorder.record()
            recordAudioButton.tintColor = .red
            print("start recording")
        } catch {
            print("Error in recording \(error.localizedDescription)")
        }
    }
    
    private func loadFailUI() {
        let alert = UIAlertController(title: "Error", message: "No permission for using mic", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
    
    private func initialseRecording() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRec()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }
    
    private func finishRecording(success: Bool) {
            recorder?.stop()
            recorder = nil
        if !success {
            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording; please try again.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
        } else {
            UIView.animateKeyframes(withDuration: 2, delay: 0, options: [], animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1){
                    self.recordAudioButton.tintColor = .green
                }
                UIView.addKeyframe(withRelativeStartTime: 1, relativeDuration: 1){
                    self.recordAudioButton.tintColor = .lightCharcoal
                }
            }, completion: nil)
            print("finishRecording")
            if self.currentTask?.audios == nil {
                self.currentTask?.audios = []
            }
            self.currentTask?.audios?.append(getRecordingURL(audioFileName))
            self.audioTableView.reloadData()
        }
    }
}
