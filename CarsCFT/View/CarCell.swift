//
//  CarCell.swift
//  CarsCFT
//
//  Created by Danila Ferents on 05/10/2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import UIKit
import Kingfisher

class CarCell: UICollectionViewCell {
    //Outlets
    @IBOutlet weak var manufactureLbl: UILabel!
    @IBOutlet weak var modelLbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var imageView: RoundedImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell (car: Car)  {
        
        manufactureLbl.text = "\(car.manufacturer)"
        modelLbl.text = "Model: \(car.model)"
        bodyLbl.text = "Body: \(car.body)"
        yearLbl.text = "Year: \(String(car.year))"
        
        
        if let url = URL(string: car.imageUrl) {
            let placeholder = UIImage(named: "placeholder")
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.1))]
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
        
    }
}
