//
//  SongsListTableViewCell.swift
//  WFAN
//
//  Created by Usman Mughal on 23/08/2017.
//  Copyright © 2017 Usman Mughal. All rights reserved.
//

import UIKit
import Firebase

class SongsListTableViewCell: UITableViewCell {
    
    static let identifier = "songTableCell"
    let firbasePlayListReference = Database.database().reference().child("Playlist")
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songDetailsLabel: UILabel!
    @IBOutlet weak var songIconImageView: UIImageView!
    @IBOutlet weak var addToPlaylistButton: UIButton!
    
    var mediaItem: MediaItem? {
        didSet {
            songNameLabel.text = mediaItem?.name ?? ""
            songDetailsLabel.text = mediaItem?.artistName ?? ""
            songIconImageView.image = nil
            
            if  let button = addToPlaylistButton {
                
                if mediaItem?.firebaseKey == nil {
                    button.isSelected = false
                } else {
                    button.isSelected = true
                }
            }
            
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func addToPlaylistButtonTap(_ sender: UIButton) {
        
        if let mItem = mediaItem {
            if let fbKey =  mItem.firebaseKey {
                firbasePlayListReference.child(fbKey).removeValue()
                mItem.firebaseKey = nil
                addToPlaylistButton.isSelected = false
            } else {
                mItem.firebaseKey = self.firbasePlayListReference.childByAutoId().key
                self.firbasePlayListReference.child(mItem.firebaseKey).setValue(mItem.getData())
                addToPlaylistButton.isSelected = true
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
