//
//  Car.swift
//  Cars
//
//  Created by Danila Ferents on 03/10/2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation

struct Car {
    var model: String
    var manufacturer: String
    var body: String
    var year: Int
    var imageUrl: String
    var id: String
    
    init(model: String, manufacturer: String, body: String, year: Int,imageUrl: String, id: String) {
        self.model = model
        self.manufacturer = manufacturer
        self.body = body
        self.year = year
        self.imageUrl = imageUrl
        self.id = id
    }
    
    init(data: [String: Any]) {
        model = data["model"] as? String ?? ""
        manufacturer = data["manufacturer"] as? String ?? ""
        body = data["body"] as? String ?? ""
        year = data["year"] as? Int ?? 2001
        imageUrl = data["imageUrl"] as? String ?? ""
        id = data["id"] as? String ?? ""
    }
    
    static func modelToData(car: Car) -> [String: Any] {
        let data = [
            "model":  car.model,
            "manufacturer": car.manufacturer,
            "body": car.body,
            "year": Int(car.year),
            "imageUrl": car.imageUrl,
            "id": car.id
        ] as [String: Any]
        return data
    }
    
}

extension Car: Equatable {
    static func ==(lhs: Car, rhs: Car)-> Bool {
        return lhs.id == rhs.id
    }
}
