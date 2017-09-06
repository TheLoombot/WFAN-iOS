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
//    var songListArray: [Dictionary<String, AnyObject>] = []
    /// The array of `MediaItem` objects that represents the list of search results.
    var mediaItems = [MediaItem]() {
        didSet {
            DispatchQueue.main.async {
                self.songsListTableView.reloadData()
            }
        }
    }
    /// The instance of `ImageCacheManager` that is used for downloading and caching album artwork images.
    let imageCacheManager = ImageCacheManager()
    
    var authorizationManager: AuthorizationManager!
    
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
            
            let songObject = snapshot.value as! [String: Any]
            let mediaItem = MediaItem(data: songObject)
            self.mediaItems.append(mediaItem)
            
            self.songsListTableView.reloadData()
            
            let songToPlay = self.mediaItems.first!
            self.songNameLabel.text = songToPlay.name
            self.songDetailLabel.text = songToPlay.artistName
            
            // Image loading.
            let imageURL = songToPlay.artwork.imageURL(size: CGSize(width: 300, height: 300))
            
             self.setSongIcon(imageView: self.songIconImageView, imageURL: imageURL)
            
            self.emptyView.isHidden = true
            
            self.adjustHieghtOfAllViews()
            }
        
        firbasePlayListReference.observe(.childRemoved) { (snapshot: DataSnapshot) in
            
            let songDic = snapshot.value as! [String: Any]
            self.mediaItems.remove(at: self.mediaItems.index(where: { $0.firebaseKey as String == songDic["firebaseKey"] as! String})!)
            self.songsListTableView.reloadData()
            
            if self.mediaItems.count > 0 {
                let songToPlay = self.mediaItems.first!
                self.songNameLabel.text = songToPlay.name
                self.songDetailLabel.text = songToPlay.artistName
                // Image loading.
                let imageURL = songToPlay.artwork.imageURL(size: CGSize(width: 300, height: 300))
                
                self.setSongIcon(imageView: self.songIconImageView, imageURL: imageURL)
                
                self.emptyView.isHidden = true
            } else {
                self.emptyView.isHidden = false
                self.playStopButton.isSelected = false
                
                self.firebaseDJsListReference.removeValue()
            }
            
            self.adjustHieghtOfAllViews()
        }
        
        firebaseDJsListReference.queryOrderedByKey().observe(.childAdded) { (snapshot: DataSnapshot) in
            
            self.skipButton.isEnabled = false
            self.playStopButton.isSelected = false
            
            let dJDic = snapshot.value as! [String: String]
            self.djListArray.append(dJDic)
            self.djListTableView.reloadData()
            
            for dj in self.djListArray {
                if dj["DJName"] == self.currentDJName {
                    self.playStopButton.isSelected = true
                    break
                }
            }
            
            let leadDJ = self.djListArray.first
            self.dJNameLabel.text = leadDJ?["DJName"]
            if self.currentDJName == leadDJ?["DJName"]
            {
                self.skipButton.isEnabled = true
            }
            
             self.adjustHieghtOfAllViews()
        }
        
        firebaseDJsListReference.observe(.childRemoved) { (snapshot: DataSnapshot) in
            
            self.skipButton.isEnabled = false
            self.playStopButton.isSelected = false
            
            let dJDic = snapshot.value as! [String: String]
            self.djListArray.remove(at: self.djListArray.index(where: {$0 == dJDic})!)
            self.djListTableView.reloadData()
            
            for dj in self.djListArray {
                if dj["DJName"] == self.currentDJName {
                    self.playStopButton.isSelected = true
                    break
                }
            }
            
            if self.djListArray.count > 0{
                let leadDJ = self.djListArray.first
                self.dJNameLabel.text = leadDJ?["DJName"]
                if self.currentDJName == leadDJ?["DJName"]{
                    self.skipButton.isEnabled = true
                }
                
            }
            else
            {
                self.dJNameLabel.text = ""
            }
            
             self.adjustHieghtOfAllViews()
        }
        
    }
    func setSongIcon(imageView:UIImageView, imageURL:URL)
    {
        if let image = self.imageCacheManager.cachedImage(url: imageURL) {
            // Cached: set immediately.
            imageView.image = image
            imageView.alpha = 1
            
        } else {
            
            // Not cached, so load then fade it in.
            imageView.alpha = 0
            self.imageCacheManager.fetchImage(url: imageURL, completion: { (image) in
                // Check the cell hasn't recycled while loading.
                imageView.image = image
                UIView.animate(withDuration: 0.3) {
                    imageView.alpha = 1
                }
            })
        }
    }
    func adjustHieghtOfAllViews()
    {
        songsListTableViewHeightConstraint.constant = CGFloat(75 * (mediaItems.count - 1))
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
        var dic: [String: String] = ["DJName":self.currentDJName]
        
        for dj in self.djListArray {
            if dj["DJName"] == self.currentDJName {
               dic = dj
                break
            }
        }
        
        if (self.djListArray.contains {$0 == dic})
        {
            firebaseDJsListReference.child(dic["dJId"]!).removeValue()
            self.playStopButton.isSelected = false
        }
        else
        {
            let key = firbasePlayListReference.childByAutoId().key
            dic["dJId"] = key
             firebaseDJsListReference.child(key).setValue(dic)
            self.playStopButton.isSelected = true
        }
        
    }
    
    @IBAction func skipButtonTap(_ sender: UIButton) {
        
        if mediaItems.count > 0
        {
            let item = mediaItems.first
            firbasePlayListReference.child((item?.firebaseKey)!).removeValue()
        }
    }
    
    @IBAction func addToPlayListButtonTap(_ sender: UIButton) {
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let songsSearchViewController  = storyboard.instantiateViewController(withIdentifier: "SongsSearchViewController") as! SongsSearchViewController
        
        songsSearchViewController.authorizationManager = self.authorizationManager
        self.present(songsSearchViewController, animated: true, completion: nil)
    }
    
    // MARK:- Table View Delegate and DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 101
        {
            return mediaItems.count - 1
        }
        else
        {
            return djListArray.count - 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 101
        {
            guard let songsListTableViewCell = tableView.dequeueReusableCell(withIdentifier: SongsListTableViewCell.identifier,
                                                           for: indexPath) as? SongsListTableViewCell else {
                                                            return UITableViewCell()
            }
            
            let mediaItem = mediaItems[indexPath.row + 1]
            songsListTableViewCell.mediaItem = mediaItem
            
            // Image loading.
            let imageURL = mediaItem.artwork.imageURL(size: CGSize(width: 90, height: 90))
            
            self.setSongIcon(imageView: songsListTableViewCell.songIconImageView, imageURL: imageURL)
            
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
