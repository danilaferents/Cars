//
//  AddCarVC.swift
//  CarsCFT
//
//  Created by Danila Ferents on 05/10/2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class AddCarVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addCarBtn: UIButton!
    
    
    //Variables
//    var currCar: Car!
    var manufacturer: String!
    var model: String!
    var body: String!
    var year: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_tap:)))
        tap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(tap)
        
        

    }
    
    //Image picker
    @objc func imageTapped(_tap: UIGestureRecognizer) {
        launchImagePicker()
    }
    
    //Add car button clicked
    @IBAction func addCarClicked(_ sender: Any) {
        addCarBtn.isEnabled = false
        uploadImageAndDocument()
    }
    
    //Upload new car info to Firebase
    func uploadImageAndDocument() {
        
        guard let year = yearTextField.text, year.filter({ (char) -> Bool in
            return !char.isWhitespace && !char.isNewline
        }).isNotEmpty, Int(year) != nil, Int(year)! < 2020, Int(year)! > 1900 else {
            simpleAlert(title: "Error!", msg: "Enter a valid year!")
            self.activityIndicator.stopAnimating()
            return
        }
        
        guard let image = imageView.image, let manufacturer = manufacturerTextField.text, let model = modelTextField.text, let body = bodyTextField.text,  manufacturer.filter({ (char) -> Bool in
            return !char.isWhitespace && !char.isNewline
        }).isNotEmpty, model.filter({ (char) -> Bool in
            return !char.isWhitespace && !char.isNewline
        }).isNotEmpty, body.filter({ (char) -> Bool in
            return !char.isWhitespace && !char.isNewline
        }).isNotEmpty else {
            simpleAlert(title: "Error!", msg: "Missing necessary information!")
            self.activityIndicator.stopAnimating()
            addCarBtn.isEnabled = true
            return
        }
        
        self.manufacturer = manufacturer
        self.model = model
        self.body = body
        self.year = Int(year)
        
        activityIndicator.startAnimating()
        
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}
        
        let imageRef = Storage.storage().reference().child("carImages/\(model).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "images/jpg"
        
        imageRef.putData(imageData, metadata: metaData) { (metadata, error) in
            if let error = error {
                self.handleError(error: error, msg: "Unable to put data.")
                return
            }
            
            imageRef.downloadURL { (url, error) in
                 if let error = error {
                    self.handleError(error: error, msg: "Unable to donload Url.")
                    }
                               
                guard let url = url else {return}
                self.uploadDocument(url: url.absoluteString)
            }
            self.activityIndicator.stopAnimating()
            self.addCarBtn.isEnabled = true
        }
    }
    
    func uploadDocument(url: String) {
        var docRef : DocumentReference!
        year = (year == nil) ? 2000 : year
        var car = Car.init(model: self.model, manufacturer: self.manufacturer, body: self.body, year: self.year, imageUrl: url, id: "")
        
        docRef = Firestore.firestore().collection("Cars").document()
        car.id = docRef.documentID
        
        let data = Car.modelToData(car: car)
        docRef.setData(data) { (error) in
            if let error = error {
                self.handleError(error: error, msg: "Unable to setData")
            }
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddCarVC : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func launchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleError(error: Error, msg: String) {
        debugPrint(error)
        self.simpleAlert(title: "Error", msg: msg)
        self.activityIndicator.stopAnimating()
    }
}
