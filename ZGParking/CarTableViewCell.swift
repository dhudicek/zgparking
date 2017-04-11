//
//  CarTableViewCell.swift
//  ZGParking
//
//  Created by Damjan Hudiček on 11/04/2017.
//  Copyright © 2017 ngajski. All rights reserved.
//

import UIKit

class CarTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var licensePlateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    public func set(name: String, licensePlate: String) {
        self.nameLabel.text = name
        self.licensePlateLabel.text = licensePlate
    }
    
}
