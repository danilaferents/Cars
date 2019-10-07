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
    
    //To make keyboard disappear
    func makeKeyboardsDisappearAttheendofediting() {
        manufacturerTextField.delegate = self
        modeltextField.delegate = self
        bodyTextField.delegate = self
        yearTextField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: view, action: #selector(UITextField.endEditing(_:)))
        self.view.addGestureRecognizer(gesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeKeyboardsDisappearAttheendofediting()
        
        //Gesture recogniser to pick images
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_tap:)))
        tap.numberOfTapsRequired = 1
        
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(tap)
        
        //Show editing information
        manufacturerTextField.text = currCar.manufacturer
        modeltextField.text = currCar.model
        bodyTextField.text = currCar.body
        yearTextField.text = String(currCar.year)
        
        //Show editing image
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
    
    //Function to save image and information about car into firebase
    func uploadImageAndDocument() {
        
        //Get information about manufacture year of a car
        guard let year = yearTextField.text, year.filter({ (char) -> Bool in
            return !char.isWhitespace && !char.isNewline
        }).isNotEmpty, Int(year) != nil, Int(year)! < 2020, Int(year)! > 1900 else {
            simpleAlert(title: "Error!", msg: "Enter a valid year!")
            self.activityIndicator.stopAnimating()
            return
        }
        
        
        //Get other important information.
        guard let image = imageView.image, let manufacturer = manufacturerTextField.text, let model = modeltextField.text, let body = bodyTextField.text, manufacturer.filter({ (char) -> Bool in
            return !char.isWhitespace && !char.isNewline
        }).isNotEmpty, model.filter({ (char) -> Bool in
            return !char.isWhitespace && !char.isNewline
        }).isNotEmpty, body.filter({ (char) -> Bool in
            return !char.isWhitespace && !char.isNewline
        }).isNotEmpty else {
            simpleAlert(title: "Error!", msg: "Missing necessary information!")
            self.activityIndicator.stopAnimating()
            return
        }
        
        //save info into class
        self.manufacturer = manufacturer
        self.model = model
        self.body = body
        self.year = Int(year)
        
        activityIndicator.startAnimating()
        
        //image data to save
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}
        
        let imageRef = Storage.storage().reference().child("carImages/\(model).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "images/jpg"
        
        //save image into firebase
        imageRef.putData(imageData, metadata: metaData) { (metadata, error) in
            
            //error handling
            if let error = error {
                self.handleError(error: error, msg: "Unable to put data.")
                return
            }
            
            //get saved image url to save it to car database
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
    
    //Function to save info about car into firebase
    func uploadDocument(url: String) {
        var docRef : DocumentReference!
        
        //Initialise Car value from received info
        var car = Car.init(model: model, manufacturer: manufacturer, body: body, year: year, imageUrl: url, id: "")
        
        docRef = Firestore.firestore().collection("Cars").document(currCar.id)
        car.id = currCar.id
        
        //Convert car into modelData
        let data = Car.modelToData(car: car)
        docRef.setData(data) { (error) in
            if let error = error {
                self.handleError(error: error, msg: "Unable to setData")
            }
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //Function for handling errors and show info about them
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

extension EditCarVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
