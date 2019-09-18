//
//  RestaurantTableViewCell.swift
//  GetUpAndMove
//
//  Created by Daniel Evans on 2/16/19.
//  Copyright © 2019 Daniel Evans. All rights reserved.
//

import UIKit

class RestaurantTableViewCell:UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
