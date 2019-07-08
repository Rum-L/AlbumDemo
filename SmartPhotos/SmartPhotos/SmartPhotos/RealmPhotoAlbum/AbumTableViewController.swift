//
//  AbumTableViewController.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/13.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

class AbumTableViewController: UITableViewController, UISearchBarDelegate {

    // MARK: - Properties
    private let reuseIdentifier = "AlbumCell"
    private var realm: Realm!
    private var albums: Results<Album>!
    
    private var token: NotificationToken!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Realm init
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        // get Album objects
        albums = realm.objects(Album.self).sorted(byKeyPath: "saveDate", ascending: false)
        // add notification block
        token = albums.observe({ (change) in
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AlbumTableViewCell
        // set album image if photo has been saved
        if let imageData = albums[indexPath.row].photos.sorted(byKeyPath: "saveDate", ascending: false).first?.imageData {
            cell.thumnailView.image = UIImage(data: imageData, scale: 0.1)
        }
        // set album title
        cell.titleLabel.text = albums[indexPath.row].title
        // set album count
        cell.countLabel.text = "共有"+String(albums[indexPath.row].photos.count)+"张"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Photos", sender: albums[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // realm delete
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (deleteAction, indexPath) in
            do {
                try self.realm.write {
                    
                    self.realm.delete(self.albums[indexPath.row])
                }
            } catch {
                print("\(error)")
            }
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (editAction, indexPath) in
            self.alertForAlbumTitle(albumToBeUpdated: self.albums[indexPath.row])
        }
        return [deleteAction, editAction]
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let photoCollectionView = segue.destination as! PhotoCollectionViewController
        photoCollectionView.selectedAlbum = sender as! Album
        
        print((sender as! Album).title)
    }
    
    @IBAction func PullAlbum(_ sender: UIBarButtonItem) {
        
            let parameters: Parameters = [ "api_key": "jKZvJE9Eg_pzgUp55ogBvcsIaK0sBtlw",
                                           "api_secret": "yhUTggbAMpeDhDh7Jc4vDThIDWgzHnMc",
                                           "facealbum_token": "1560279838-fac5e875-22f5-4ef8-af5d-c8a73ed5fbe4"
                        
                
            ]
            AF.request("https://api-cn.faceplusplus.com/imagepp/v1/facealbum/getalbumdetail", method: .post, parameters: parameters).responseJSON{ response in
                switch response.result {
                    
                case .success(let value):
                    let swiftyJson = JSON(value)
                    if swiftyJson["faces"].array?.count ?? 0 > 0 {
                        for i in 0..<swiftyJson["faces"].array!.count {
                            let facetoken = swiftyJson["faces"][i]["face_token"].stringValue
                            let token = self.realm.objects(Token.self).filter("face_token = '\(facetoken)'")
                            for t in token {
                                do {
                                    try self.realm.write {
                                        t.group_id = swiftyJson["faces"][i]["group_id"].stringValue
                                    }
                                } catch {
                                    print("\(error)")
                                }
                            }
                        }
                    }
                    
                    //创建相册
                    do {
                        try self.realm.write {
                            
                            var groupids = [String]()
                            for id in self.realm.objects(Token.self) {
                                let tokenalbum = Album()
                                //判断相册是否创建
                                if groupids.contains("\(id.group_id)") {
                                    for album in self.realm.objects(Album.self).filter("title = '相册\(id.group_id)'") {
                                        for photo in self.realm.objects(Photo.self).filter("image_id = '\(id.image_id)'") {
                                            album.photos.append(photo)
                                        }
                                    }
                                    
                                }
                                else {
                                    let item = self.realm.objects(Album.self).filter("title = '相册\(id.group_id)'")
                                    if item.count > 0 {
                                        print("已经存在同名相册")
                                    }
                                    else {
                                        tokenalbum.title = "相册" + "\(id.group_id)"
                                        self.realm.add(tokenalbum)
                                    }
                                    
                                    //将照片添加至相册中
                                    for photo in self.realm.objects(Photo.self).filter("image_id = '\(id.image_id)'") {
                                        tokenalbum.photos.append(photo)
                                    }
                                    groupids.append("\(id.group_id)")
                                }
                            }
                            for unalbum in self.realm.objects(Album.self).filter("title = '相册0'") {
                                unalbum.title = "未分类"
                            }
                            
                            
                        }
                    } catch {
                        print("\(error)")
                    }
                    print(swiftyJson)
                case .failure(let error):
                    print(error)
                }
            }

        
    }
    // MARK: - User Action
    @IBAction func addNewAlbum(_ sender: UIBarButtonItem) {
        alertForAlbumTitle(albumToBeUpdated: nil)
    }
    
    // Realm add and update
    func alertForAlbumTitle(albumToBeUpdated: Album?) {
        let alertController = UIAlertController(title: "Album", message: "Insert Album Title", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            if albumToBeUpdated != nil {
                textField.text = albumToBeUpdated?.title
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            let inputTitle = alertController.textFields?.first?.text
            if albumToBeUpdated != nil {
                // update album
                // use primary-key
                // let album = ["uuid": albumToBeUpdated?.uuid, "title": inputTitle]
                do {
                    try self.realm.write {
                        albumToBeUpdated?.title = inputTitle!
                        // when use primary-key
                        // self.startRealm.create(Album.self, value: album, update: true)
                    }
                } catch {
                    print("/(error")
                }
            } else {
                // add new album
                let newAlbum = Album()
                newAlbum.title = inputTitle!
                do {
                    try self.realm.write {
                        self.realm.add(newAlbum)
                    }
                } catch {
                    print("\(error)")
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
    
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Realm Filter
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty
        {
            albums = realm.objects(Album.self).filter("title contains[c] %@", searchText).sorted(byKeyPath: "saveDate", ascending: false)
        }
        else
        {
            albums = realm.objects(Album.self).sorted(byKeyPath: "saveDate", ascending: false)
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
