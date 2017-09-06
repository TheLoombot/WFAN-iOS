//
//  SongsSearchViewController.swift
//  WFAN
//
//  Created by Usman Mughal on 31/08/2017.
//  Copyright © 2017 Usman Mughal. All rights reserved.
//

import UIKit

class SongsSearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: CustomUITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    /// The instance of `AuthorizationManager` used for querying and requesting authorization status.
    var authorizationManager: AuthorizationManager!
    
    /// The instance of `AppleMusicManager` which is used to make search request calls to the Apple Music Web Services.
    let appleMusicManager = AppleMusicManager()
    
    /// The instance of `ImageCacheManager` that is used for downloading and caching album artwork images.
    let imageCacheManager = ImageCacheManager()
    
    //    /// The instance of `MusicPlayerManager` which is used for triggering the playback of a `MediaItem`.
    //    var musicPlayerManager: MusicPlayerManager!
    
    //    /// The instance of `MediaLibraryManager` which is used for adding items to the application's playlist.
    //    var mediaLibraryManager: MediaLibraryManager!
    
    /// A `DispatchQueue` used for synchornizing the setting of `mediaItems` to avoid threading issues with various `UITableView` delegate callbacks.
    var setterQueue = DispatchQueue(label: "MediaSearchTableViewController")
    
    /// The array of `MediaItem` objects that represents the list of search results.
    var mediaItems = [[MediaItem]]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextField.addSearchIcon()
        
        searchTextField.delegate = self
        searchTextField.customDelegate = self
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerAuthorizationDidUpdateNotification),
                                       name: AuthorizationManager.authorizationDidUpdateNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerAuthorizationDidUpdateNotification),
                                       name: .UIApplicationWillEnterForeground,
                                       object: nil)
        
    }
    
    deinit {
        // Remove all notification observers.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchTextField.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backButtonTap(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Table View Delegate and DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return mediaItems.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaItems[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongsListTableViewCell.identifier,
                                                       for: indexPath) as? SongsListTableViewCell else {
                                                        return UITableViewCell()
        }
        
        let mediaItem = mediaItems[indexPath.section][indexPath.row]
        cell.mediaItem = mediaItem
        
        // Image loading.
        let imageURL = mediaItem.artwork.imageURL(size: CGSize(width: 90, height: 90))
        
        if let image = imageCacheManager.cachedImage(url: imageURL) {
            // Cached: set immediately.
            
            cell.songIconImageView.image = image
            cell.songIconImageView.alpha = 1
        } else {
            // Not cached, so load then fade it in.
            cell.songIconImageView.alpha = 0
            
            imageCacheManager.fetchImage(url: imageURL, completion: { (image) in
                // Check the cell hasn't recycled while loading.
                if (cell.mediaItem?.identifier ?? "") == mediaItem.identifier {
                    cell.songIconImageView.image = image
                    UIView.animate(withDuration: 0.3) {
                        cell.songIconImageView.alpha = 1
                    }
                }
            })
        }
        
        let cloudServiceCapabilities = authorizationManager.cloudServiceCapabilities
        
        /*
         It is important to actually check if your application has the appropriate `SKCloudServiceCapability` options before enabling functionality
         related to playing back content from the Apple Music Catalog or adding items to the user's Cloud Music Library.
         */
        
        if cloudServiceCapabilities.contains(.addToCloudMusicLibrary) {
            cell.addToPlaylistButton.isEnabled = true
        } else {
            cell.addToPlaylistButton.isEnabled = false
        }
        
        if cloudServiceCapabilities.contains(.musicCatalogPlayback) {
            cell.addToPlaylistButton.isEnabled = true
        } else {
            cell.addToPlaylistButton.isEnabled = false
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75.0
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       searchTextField.resignFirstResponder()
    }
    // MARK: Notification Observing Methods
    @objc func handleAuthorizationManagerAuthorizationDidUpdateNotification() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
extension SongsSearchViewController:UITextFieldDelegate,CustomTextFieldDelegate
{
    
    func textFieldClearButtonTap() {
        setterQueue.sync {
            self.mediaItems = []
        }
    }
    
    // MARK:- Text Field Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        searchTextField.textFieldDidBeginEditing(textField)
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchTextField.textFieldDidEndEditing(textField)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if var searchString = textField.text as NSString? {
            searchString = searchString.replacingCharacters(in: range, with: string) as NSString
            
            if searchString == "" {
                self.setterQueue.sync {
                    self.mediaItems = []
                }
            } else {
                appleMusicManager.performAppleMusicCatalogSearch(with: searchString as String,
                                                                 countryCode: authorizationManager.cloudServiceStorefrontCountryCode,
                                                                 completion: { [weak self] (searchResults, error) in
                                                                    guard error == nil else {
                                                                        
                                                                        // Your application should handle these errors appropriately depending on the kind of error.
                                                                        self?.setterQueue.sync {
                                                                            self?.mediaItems = []
                                                                        }
                                                                        
                                                                        let alertController: UIAlertController
                                                                        
                                                                        guard let error = error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error else {
                                                                            
                                                                            alertController = UIAlertController(title: "Error",
                                                                                                                message: "Encountered unexpected error.",
                                                                                                                preferredStyle: .alert)
                                                                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                                                                            
                                                                            DispatchQueue.main.async {
                                                                                self?.present(alertController, animated: true, completion: nil)
                                                                            }
                                                                            
                                                                            return
                                                                        }
                                                                        
                                                                        alertController = UIAlertController(title: "Error",
                                                                                                            message: underlyingError.localizedDescription,
                                                                                                            preferredStyle: .alert)
                                                                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                                                                        
                                                                        DispatchQueue.main.async {
                                                                            self?.present(alertController, animated: true, completion: nil)
                                                                        }
                                                                        
                                                                        return
                                                                    }
                                                                    
                                                                    self?.setterQueue.sync {
                                                                        self?.mediaItems = searchResults
                                                                    }
                                                                    
                })
            }
        }
        
        return searchTextField.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        return true
    }
}
