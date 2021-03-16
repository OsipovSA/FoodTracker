//
//  Meal.swift
//  FoodTracker
//
//  Created by Sergey on 16.03.2021.
//

import UIKit

class Meal {
    //MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    
    // Mark: Initialization
    init?(name: String, photo:UIImage?, rating: Int) {
        guard !name.isEmpty else {
            return nil
        }
        
        guard (rating >= 0) && (rating<=5) else {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.rating = rating
    }
    
}
