//
//  MainScreenViewController.swift
//  WFAN
//
//  Created by Usman Mughal on 22/08/2017.
//  Copyright © 2017 Usman Mughal. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var emptyView: UIView!
    
    var currentDJName: String!
    var djListArray:[String] = []
    var songListArray: [Dictionary<String, String>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        djListArray.append("Slim Albert")
        dJNameLabel.text = "Joseph Mother"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Button Actions
    @IBAction func playStopButtonTap(_ sender: UIButton) {
        if sender.isSelected
        {
            sender.isSelected = false
        }
        else
        {
            sender.isSelected = true
        }
        
        if !self.djListArray.contains(self.currentDJName)
        {
            self.djListArray.append(self.currentDJName)
            self.djListTableView.reloadData()
        }
        else
        {
            self.djListArray.remove(at: self.djListArray.index(of: self.currentDJName)!)
            self.djListTableView.reloadData()
        }
    }
    
    @IBAction func skipButtonTap(_ sender: UIButton) {
        
        if songListArray.count > 0
        {
            let dic = songListArray.first
            songNameLabel.text = dic?["SongName"]
            songDetailLabel.text = dic?["ArtistName"]
            songIconImageView.image = UIImage(named: (dic?["icon"])!)
            songListArray.removeFirst()
            songsListTableView.reloadData()
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
                let dic = ["SongName":songName, "ArtistName":artistName, "icon":"song2"]
                
                if !self.emptyView.isHidden
                {
                    self.songNameLabel.text = dic["SongName"]!
                    self.songDetailLabel.text = dic["ArtistName"]!
                    self.songIconImageView.image = UIImage(named: (dic["icon"])!!)
                    self.emptyView.isHidden = true
                    return
                }
                
                self.songListArray.append(dic as! [String : String])
                self.songsListTableView.reloadData()
            }
            
            //compare the current password and do action here
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
            return songListArray.count
        }
        else
        {
            return djListArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 101
        {
            let songsListTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "songTableCell", for: indexPath) as! SongsListTableViewCell
            
            let dic  = songListArray[indexPath.row]
            
            songsListTableViewCell.songNameLabel.text = dic["SongName"]
            songsListTableViewCell.songDetailsLabel.text = dic["ArtistName"]
            songsListTableViewCell.songIconImageView.image = UIImage(named: dic["icon"]!)
            
            return songsListTableViewCell
        }
        else
        {
            let dJListTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "dJTableCell", for: indexPath) as! DJListTableViewCell
            dJListTableViewCell.djNameLabel.text = djListArray[indexPath.row]
            return dJListTableViewCell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 101 {
            return songsListTableView.frame.size.height
        }
        else
        {
            return 80.0
        }
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
