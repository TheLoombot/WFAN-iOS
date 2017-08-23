//
//  SongsListTableViewCell.swift
//  WFAN
//
//  Created by Usman Mughal on 23/08/2017.
//  Copyright © 2017 Usman Mughal. All rights reserved.
//

import UIKit

class SongsListTableViewCell: UITableViewCell {
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songDetailsLabel: UILabel!
    @IBOutlet weak var songIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
