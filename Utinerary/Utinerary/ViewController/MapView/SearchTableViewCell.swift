//
//  SearchTableViewCell.swift
//  Utinerary
//
//  Created by Cirrena on 8/25/15.
//  Copyright (c) 2015 RHMH. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet private weak var header: UILabel!
    @IBOutlet private  weak var subHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTitle(header : String! , subHeader: String!){
        self.header.text = header
        self.subHeader.text = subHeader
        
    }
}
