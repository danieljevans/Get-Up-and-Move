//
//  RestaurantList.swift
//  GetUpAndMove
//
//  Created by Daniel Evans on 2/16/19.
//  Copyright © 2019 Daniel Evans. All rights reserved.
//

import Foundation

class RestaurantList
{
    var restaurantList:[DisplayRestaurant] = []
    
    init()
    {
        
    }
}

class DisplayRestaurant
{
    var name:String?
    var rating:Double?
    var lat:Double?
    var long:Double?

    init(_ newName:String, _ newRating:Double, _ lat:Double, _ long:Double)
    {
        self.name = newName
        self.rating = newRating
        self.lat = lat
        self.long = long
    }
}
