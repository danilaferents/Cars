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
    
    
    //Variables
    var currCar: Car!
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
        uploadImageAndDocument()
    }
    
    //Upload new car info to Firebase
    func uploadImageAndDocument() {
        guard let image = imageView.image, let manufacturer = manufacturerTextField.text, let model = modelTextField.text, let body = bodyTextField.text, let year = yearTextField.text, manufacturer.isNotEmpty, model.isNotEmpty, body.isNotEmpty, year.isNotEmpty else {
            simpleAlert(title: "Error!", msg: "Missing necessary information!")
            self.activityIndicator.stopAnimating()
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
        }
    }
    
    func uploadDocument(url: String) {
        var docRef : DocumentReference!
        
        var car = Car.init(model: model, manufacturer: manufacturer, body: body, year: year, imageUrl: url, id: "")
        
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
