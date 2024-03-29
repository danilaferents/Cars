//
//  CarCell.swift
//  CarsCFT
//
//  Created by Danila Ferents on 05/10/2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import Kingfisher

protocol DeleteCollectionViewCellDelegate {
    func deleteCell(id: String)
}
class CarCell: UICollectionViewCell {
    //Outlets
    @IBOutlet weak var manufactureLbl: UILabel!
    @IBOutlet weak var modelLbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var imageView: RoundedImageView!
    
    var delegate: DeleteCollectionViewCellDelegate!
    var id: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //Cell deletion
    //This function delegates deletion permission to delegate
    @IBAction func deleteItemClicked(_ sender: Any) {
        delegate.deleteCell(id: self.id)
    }
    
    //Configure Car cell from car value
    //This function receive delegate and implement it to Cell
    //This function also show cars information in cell
    func configureCell (car: Car, delegate: DeleteCollectionViewCellDelegate)  {
        
        self.delegate = delegate  //initialise delegate
        self.id = car.id  //remember id of a document
        
        //put values in labels
        manufactureLbl.text = "\(car.manufacturer)"
        modelLbl.text = "Model: \(car.model)"
        bodyLbl.text = "Body: \(car.body)"
        yearLbl.text = "Year: \(String(car.year))"
        
        
        //image loading
        if let url = URL(string: car.imageUrl) {
            let placeholder = UIImage(named: "placeholder")
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.1))]
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
        
    }
}
