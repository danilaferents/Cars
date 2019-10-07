//
//  Extensions.swift
//  CarsCFT
//
//  Created by Danila Ferents on 06/10/2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation
import UIKit

//extension for conveniece: check if string is empty
extension String {
    var isNotEmpty: Bool {  //initialisation of computed value
        return !isEmpty
    }
}

//extension for error handling
extension UIViewController {
    func simpleAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
