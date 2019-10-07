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
    @IBOutlet weak var backImage: UIImageView!
    
    
    //Variables
//    var currCar: Car!
    var manufacturer: String!
    var model: String!
    var body: String!
    var year: Int!
    
    //Function to make keyboard disappear while pressing Enter or another part of a view
    func makeKeyboardsDisappearAttheendofediting() {
        
        manufacturerTextField.delegate = self
        modelTextField.delegate = self
        bodyTextField.delegate = self
        yearTextField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: view, action: #selector(UITextField.endEditing(_:)))
        self.view.addGestureRecognizer(gesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeKeyboardsDisappearAttheendofediting()
        
        //Gesture recogniser for launchPicker
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
        
        //receive year of Cars manufacture
        guard let year = yearTextField.text, year.filter({ (char) -> Bool in
            return !char.isWhitespace && !char.isNewline
        }).isNotEmpty, Int(year) != nil, Int(year)! < 2020, Int(year)! > 1900 else {
            simpleAlert(title: "Error!", msg: "Enter a valid year!")
            self.activityIndicator.stopAnimating()
            addCarBtn.isEnabled = true
            return
        }
        
        //receive other information about Car
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
        
        //Save information to  class
        self.manufacturer = manufacturer
        self.model = model
        self.body = body
        self.year = Int(year)
        
        activityIndicator.startAnimating()
        
        //save image
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}
        
        //get reference where to save image
        let imageRef = Storage.storage().reference().child("carImages/\(model).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "images/jpg"
        
        //save image
        imageRef.putData(imageData, metadata: metaData) { (metadata, error) in
            //handle errors
            if let error = error {
                self.handleError(error: error, msg: "Unable to put data!")
                return
            }
            
            //get saved image url
            imageRef.downloadURL { (url, error) in
                 if let error = error {
                    self.handleError(error: error, msg: "Unable to download Url!")
                    }
                               
                guard let url = url else {return}
                //save all information about car
                self.uploadDocument(url: url.absoluteString)
            }
            self.activityIndicator.stopAnimating()
            self.addCarBtn.isEnabled = true
        }
    }
    
    //Function to save information about car
    func uploadDocument(url: String) {
        
        var docRef : DocumentReference!
        
        //Initialise car value
        var car = Car.init(model: self.model, manufacturer: self.manufacturer, body: self.body, year: self.year, imageUrl: url, id: "")
        
        //Get reference where to save information about car
        docRef = Firestore.firestore().collection("Cars").document()
        car.id = docRef.documentID
        
        //Data to save in firebase
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

extension AddCarVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
