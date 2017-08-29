//
//  MainScreenViewController.swift
//  WFAN
//
//  Created by Usman Mughal on 22/08/2017.
//  Copyright © 2017 Usman Mughal. All rights reserved.
//

import UIKit

import Firebase

class MainScreenViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var songIconImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songDetailLabel: UILabel!
    @IBOutlet weak var playStopButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var addToPlayListButton: UIButton!
    @IBOutlet weak var songsListTableView: UITableView!
    @IBOutlet weak var djListTableView: UITableView!
    @IBOutlet weak var dJNameLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var emptyView: UIView!
    
    // Height Constraint Of Table Views
    @IBOutlet weak var dJListTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var songsListTableViewHeightConstraint: NSLayoutConstraint!
    
    var currentDJName: String!
    var djListArray:[Dictionary<String, String>] = []
    var songListArray: [Dictionary<String, String>] = []
    
    let firbasePlayListReference = Database.database().reference().child("Playlist")
    
    let firebaseDJsListReference = Database.database().reference().child("DJList")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dJNameLabel.text = ""
        self.emptyView.isHidden = false
        self.observerFbDatabaseChanges()
    }
    override func viewDidAppear(_ animated: Bool) {
         adjustHieghtOfAllViews()
    }
    
    func observerFbDatabaseChanges()
    {
        firbasePlayListReference.queryOrderedByKey().observe(.childAdded) { (snapshot: DataSnapshot) in
            
            let songDic = snapshot.value as! [String: String]
            // Append Song Added to Playlist
            self.songListArray.append(songDic )
            self.songsListTableView.reloadData()
            
            let songToPlay = self.songListArray.first!
            self.songNameLabel.text = songToPlay["SongName"]!
            self.songDetailLabel.text = songToPlay["ArtistName"]!
            self.songIconImageView.image = UIImage(named: (songToPlay["icon"])!)
            
            self.emptyView.isHidden = true
            
            self.adjustHieghtOfAllViews()
        }
        
        firbasePlayListReference.observe(.childRemoved) { (snapshot: DataSnapshot) in
            
            let songDic = snapshot.value as! [String: String]
            
            self.songListArray.remove(at: self.songListArray.index(where: { $0 == songDic})!)
            
            self.songsListTableView.reloadData()
            
            if self.songListArray.count > 0
            {
                let songToPlay = self.songListArray.first!
                self.songNameLabel.text = songToPlay["SongName"]!
                self.songDetailLabel.text = songToPlay["ArtistName"]!
                self.songIconImageView.image = UIImage(named: (songToPlay["icon"])!)
                self.emptyView.isHidden = true
            }
            else
            {
                self.emptyView.isHidden = false
                self.playStopButton.isSelected = false
                
                self.firebaseDJsListReference.removeValue()
            }
            
            self.adjustHieghtOfAllViews()
        }
        
        
        firebaseDJsListReference.observe(.childAdded) { (snapshot: DataSnapshot) in
            
             self.skipButton.isEnabled = false
            self.playStopButton.isSelected = false
            
            let dJDic = snapshot.value as! [String: String]
            
            self.djListArray.append(dJDic)
            
            self.djListTableView.reloadData()
            
            let leadDJ = self.djListArray.first
            
            self.dJNameLabel.text = leadDJ?["DJName"]
            
            if self.currentDJName == leadDJ?["DJName"]
            {
                self.skipButton.isEnabled = true
                 self.playStopButton.isSelected = true
            }
            
             self.adjustHieghtOfAllViews()
        }
        
        firebaseDJsListReference.observe(.childRemoved) { (snapshot: DataSnapshot) in
            
            self.skipButton.isEnabled = false
            self.playStopButton.isSelected = false
            
            let dJDic = snapshot.value as! [String: String]
            
            self.djListArray.remove(at: self.djListArray.index(where: {$0 == dJDic})!)
            
            self.djListTableView.reloadData()
            
            if self.djListArray.count > 0
            {
                let leadDJ = self.djListArray.first
                
                self.dJNameLabel.text = leadDJ?["DJName"]
                
                if self.currentDJName == leadDJ?["DJName"]
                {
                    self.skipButton.isEnabled = true
                    self.playStopButton.isSelected = true
                }
                
            }
            else
            {
                self.dJNameLabel.text = ""
            }
            
             self.adjustHieghtOfAllViews()
        }
        
    }
    
    func adjustHieghtOfAllViews()
    {
        songsListTableViewHeightConstraint.constant = CGFloat(75 * (songListArray.count - 1))
        dJListTableViewHeightConstraint.constant = CGFloat(75 * djListArray.count)
        backgroundView.layoutIfNeeded()
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = true
        
        backgroundView.frame.size.height =  djListTableView.frame.origin.y + CGFloat(75 * djListArray.count)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Button Actions
    @IBAction func playStopButtonTap(_ sender: UIButton) {
        let dic: [String: String] = ["DJName":self.currentDJName]
        if (self.djListArray.contains {$0 == dic})
        {
            firebaseDJsListReference.child(self.currentDJName).removeValue()
        }
        else
        {
             firebaseDJsListReference.child(self.currentDJName).setValue(dic)
        }
        
    }
    
    @IBAction func skipButtonTap(_ sender: UIButton) {
        
        if songListArray.count > 0
        {
            let dic = songListArray.first
            firbasePlayListReference.child((dic?["songId"])!).removeValue()
        }
    }
    
    @IBAction func addToPlayListButtonTap(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Alert", message: "Enter Song", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Enter song name"
        })
        
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Enter song artist name"
        })
        
        let confirmAction = UIAlertAction(title: "Done", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            
            let songName = alertController.textFields?[0].text
            let artistName = alertController.textFields?[1].text
            
            if songName != "" && artistName != ""
            {
                let key = self.firebaseDJsListReference.childByAutoId().key
                let dic = ["SongName":songName, "ArtistName":artistName, "icon":"song2", "songId":key]
                
                self.firbasePlayListReference.child(key).setValue(dic)
                
            }
            
        })
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            print("Canelled")
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: {})
    }
    
    // MARK:- Table View Delegate and DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 101
        {
            return songListArray.count - 1
        }
        else
        {
            return djListArray.count - 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 101
        {
            let songsListTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "songTableCell", for: indexPath) as! SongsListTableViewCell
            
            let dic  = songListArray[indexPath.row + 1]
            
            songsListTableViewCell.songNameLabel.text = dic["SongName"]
            songsListTableViewCell.songDetailsLabel.text = dic["ArtistName"]
            songsListTableViewCell.songIconImageView.image = UIImage(named: dic["icon"]!)
            
            return songsListTableViewCell
        }
        else
        {
            let dJListTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "dJTableCell", for: indexPath) as! DJListTableViewCell
            
            let dic  = djListArray[indexPath.row + 1]
            
            dJListTableViewCell.djNameLabel.text = dic["DJName"]
            
            return dJListTableViewCell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75.0
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
