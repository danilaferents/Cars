//
//  EditCarVC.swift
//  CarsCFT
//
//  Created by Danila Ferents on 06/10/2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
class EditCarVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var modeltextField: UITextField!
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
        
        manufacturerTextField.text = currCar.manufacturer
        modeltextField.text = currCar.model
        bodyTextField.text = currCar.body
        yearTextField.text = String(currCar.year)
        
        if let url = URL(string: currCar.imageUrl) {
            imageView.contentMode = .scaleAspectFill
            imageView.kf.setImage(with: url)
        }
    }
    
    @objc func imageTapped(_tap: UIGestureRecognizer) {
        launchImagePicker()
    }
    
    @IBAction func saveChangesClicked(_ sender: Any) {
        uploadImageAndDocument()
    }
    
    func uploadImageAndDocument() {
        guard let image = imageView.image, let manufacturer = manufacturerTextField.text, let model = modeltextField.text, let body = bodyTextField.text, let year = yearTextField.text, manufacturer.isNotEmpty, model.isNotEmpty, body.isNotEmpty, year.isNotEmpty else {
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
        
        docRef = Firestore.firestore().collection("Cars").document(currCar.id)
        car.id = currCar.id
        
        let data = Car.modelToData(car: car)
        docRef.setData(data) { (error) in
            if let error = error {
                self.handleError(error: error, msg: "Unable to setData")
            }
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func handleError(error: Error, msg: String) {
        debugPrint(error)
        self.simpleAlert(title: "Error", msg: msg)
        self.activityIndicator.stopAnimating()
    }
    
}
extension EditCarVC : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
}
