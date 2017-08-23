//
//  DJListTableViewCell.swift
//  WFAN
//
//  Created by Usman Mughal on 23/08/2017.
//  Copyright © 2017 Usman Mughal. All rights reserved.
//

import UIKit

class DJListTableViewCell: UITableViewCell {
    @IBOutlet weak var djNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
