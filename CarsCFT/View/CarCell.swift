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
        
        manufactureLbl.text = car.manufacturer
        modelLbl.text = car.model
        bodyLbl.text = car.body
        yearLbl.text = String(car.year)
        
        
        if let url = URL(string: car.imageUrl) {
            imageView.kf.setImage(with: url)
        }
        
    }
}
