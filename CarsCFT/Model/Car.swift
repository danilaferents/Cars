//
//  Car.swift
//  Cars
//
//  Created by Danila Ferents on 03/10/2019.
//  Copyright © 2019 Danila Ferents. All rights reserved.
//

import Foundation

//Model of a car instance
struct Car {
    var model: String //Model of a car
    var manufacturer: String  //Manufacturer of a car
    var body: String  //Car's body
    var year: Int //Year of Car's production
    var imageUrl: String  //Car's image
    var id: String  //Unique Car's id
    
    
    //Car's initialising
    init(model: String, manufacturer: String, body: String, year: Int,imageUrl: String, id: String) {
        self.model = model
        self.manufacturer = manufacturer
        self.body = body
        self.year = year
        self.imageUrl = imageUrl
        self.id = id
    }
    
    
    //Car's initialising from JSON
    init(data: [String: Any]) {
        model = data["model"] as? String ?? ""
        manufacturer = data["manufacturer"] as? String ?? ""
        body = data["body"] as? String ?? ""
        year = data["year"] as? Int ?? 2001
        imageUrl = data["imageUrl"] as? String ?? ""
        id = data["id"] as? String ?? ""
    }
    
    //Convert car into JSON
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
