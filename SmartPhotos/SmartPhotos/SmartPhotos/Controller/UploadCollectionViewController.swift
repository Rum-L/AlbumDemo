//
//  UploadController.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/17.
//  Copyright © 2019 林铭杰. All rights reserved.


import UIKit
import RealmSwift
import SwifterSwift
import Alamofire
import PKHUD
import SwiftyJSON

private let reuseIdentifier = "PhotoCell"

protocol UploadCollectionViewControllerDelegate: class {
    func changeNavigationUI(tabBar tabBarView: UIView)
}

class UploadCollectionViewController: UICollectionViewController,
UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    private var selectedPath = [IndexPath]()
    
    weak var parentController: UploadCollectionViewControllerDelegate?
    
    private(set) var isEditMode = false
    
    lazy var editTabBar: UploadListEditTabbar = {
        
        let tabBar: UploadListEditTabbar = .fromNib()
        tabBar.delegate = self as? EditableUploadList
        return tabBar
        
    }()
    
    @IBAction func uploadBarButton(_ sender: UIBarButtonItem) {
        
        selectedPath.removeAll()
        changeEditMode()
        
    }
    
    func changeEditMode() {
        
        if isEditMode {
            isEditMode = false
        }
        else {
            isEditMode = true
        }
        print(isEditMode)
        let editBarButton = self.navigationItem.rightBarButtonItem!
        editBarButton.title = isEditMode ? "取消".localized() : "上传/生成相册".localized()
        editBarButton.style = isEditMode ? .done : .plain
        if isEditMode {
            print("isedit")
            
            self.changeNavigationUI(tabBar: editTabBar)
            self.collectionView?.reloadData()
        }
        else {
            
            editTabBar.removeFromSuperview()
            self.collectionView?.reloadData()
        }
        
    }
    

    // MARK: - Properties
    private var realm: Realm!
    private var photos: Results<Photo>!
    private var token: NotificationToken!
    private var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Realm init
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        // get Photo objects in selectedAlbum
        photos = realm.objects(Photo.self)
        // add notification block
        
        for i in photos {
            images.append(UIImage(data: i.imageData) ?? UIImage())
        }
        token = photos.observe({ (change) in
            self.collectionView?.reloadData()
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        // set saved image
        if let image = UIImage(data: photos[indexPath.item].imageData) {
            cell.imageView.image = image
        }
        if !isEditMode {
            cell.checkbox.hideBox = true
        }
        else {
            cell.checkbox.hideBox = false
        }
        
        let query:BmobQuery = BmobQuery(className: "Photos")
        query.whereKey("PhotoUUID", equalTo: "\(photos[indexPath.item].uuid)")
        query.countObjectsInBackground { (count, error) in
            if count == 0 {
               cell.uploadflag.isHidden = true
            }
            else {
                cell.uploadflag.isHidden = false
            }
        }
        
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        if isEditMode {
            //编辑模式下才添加坐标
            if selectedPath.contains(indexPath) {
                selectedPath.removeAll(indexPath)
            }
            else {
                selectedPath.append(indexPath)
            }
            
            cell.editMode(value: isEditMode)
            switch cell.checkbox.checkState {
                
            case .unchecked:
                cell.checkPhoto()
            case .checked:
                cell.uncheckPhoto()
            default: break
            }
        }
        
        if selectedPath.isEmpty {
            self.editTabBar.createButton.isEnabled = false
            self.editTabBar.uploadButton.isEnabled = false
        }
        else {
            self.editTabBar.createButton.isEnabled = true
            self.editTabBar.uploadButton.isEnabled = true
        }
        
        print(selectedPath)
        
        
        //        showDeleteAlert(indexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemLength = (collectionView.frame.size.width - 15) / 4
        return CGSize(width: itemLength, height: itemLength)
    }
    
    func create() {
        
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        
        
        let createPhotos = realm.objects(Photo.self)
        for indexPath in selectedPath {
            
            //添加照片
            let parameters: Parameters = [ "api_key": "jKZvJE9Eg_pzgUp55ogBvcsIaK0sBtlw",
                                           "api_secret": "yhUTggbAMpeDhDh7Jc4vDThIDWgzHnMc",
                                           "facealbum_token": "1560279838-fac5e875-22f5-4ef8-af5d-c8a73ed5fbe4",
                                           "image_base64": createPhotos[indexPath.item].imageData.base64EncodedString()
                
            ]
            
            AF.request("https://api-cn.faceplusplus.com/imagepp/v1/facealbum/addimage", method: .post, parameters: parameters).responseJSON { response in
                switch response.result {

                    case .success(let value):
                        let swiftyJson = JSON(value)
                        if swiftyJson["faces"].array?.count ?? 0 > 0 {
                            for i in 0..<swiftyJson["faces"].array!.count {
                                //new Token
                                let newToken = Token()
                                newToken.face_token = swiftyJson["faces"][i]["face_token"].stringValue
                                newToken.image_id = swiftyJson["image_id"].stringValue
                                //realm write
                                do {
                                    try self.realm.write {
                                        createPhotos[indexPath.item].image_id = swiftyJson["image_id"].stringValue
                                        let rs = self.realm.objects(Token.self).filter("face_token = '\(newToken.face_token)' ")
                                        
                                        if  rs.count > 0  {
                                            print("已经存在")
                                        }
                                        else {
                                            if !newToken.face_token.isEmpty {
                                                self.realm.add(newToken)
                                            }
                                        }
                                        
                                    }
                                } catch {
                                    print("\(error)")
                                }
                            }
                            
                        }
                        else {
                            //new Token
                            let newToken = Token()
                            newToken.face_token = swiftyJson["faces"][0]["face_token"].stringValue
                            newToken.image_id = swiftyJson["image_id"].stringValue
                            //realm write
                            do {
                                try self.realm.write {
                                    createPhotos[indexPath.item].image_id = swiftyJson["image_id"].stringValue
                                    self.realm.add(newToken)
                                }
                            } catch {
                                print("\(error)")
                            }
                        }
                        //聚类人脸
                        let parameters1: Parameters = [ "api_key": "jKZvJE9Eg_pzgUp55ogBvcsIaK0sBtlw",
                                                        "api_secret": "yhUTggbAMpeDhDh7Jc4vDThIDWgzHnMc",
                                                        "facealbum_token": "1560279838-fac5e875-22f5-4ef8-af5d-c8a73ed5fbe4"
                            
                        ]
                        AF.request("https://api-cn.faceplusplus.com/imagepp/v1/facealbum/groupface", method: .post, parameters: parameters1).responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                let swiftyJson = JSON(value)
                                print(swiftyJson["task_id"])
                                print(swiftyJson)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    //查询聚类结果
                                    let parameters2: Parameters = [ "api_key": "jKZvJE9Eg_pzgUp55ogBvcsIaK0sBtlw",
                                                                    "api_secret": "yhUTggbAMpeDhDh7Jc4vDThIDWgzHnMc",
                                                                    "task_id": "\(swiftyJson["task_id"].stringValue)"
                                        
                                    ]
                                    AF.request("https://api-cn.faceplusplus.com/imagepp/v1/facealbum/groupfacetaskquery", method: .post, parameters: parameters2).responseJSON { response in
                                        switch response.result {
                                            
                                        case .success(let value):
                                            let swiftyJson = JSON(value)
                                            print(swiftyJson["group_result"])
                                            if swiftyJson["group_result"].array?.count ?? 0 > 0 {
                                                
                                                for i in 0..<swiftyJson["group_result"].array!.count {
                                                    
                                                    //realm write
                                                    do {
                                                        try self.realm.write {
                                                            for token in self.realm.objects(Token.self).filter("face_token = '\(swiftyJson["group_result"][i]["face_token"].stringValue)'") {
                                                                
                                                                token.group_id = "\(swiftyJson["group_result"][i]["group_id"].stringValue)"
                                                            }
                                                        }
                                                    } catch {
                                                        print("\(error)")
                                                    }
                                                }
                                            }
                                            else {
                                                
                                                //realm write
                                                do {
                                                    try self.realm.write {
                                                        for token in self.realm.objects(Token.self).filter("face_token = '\(swiftyJson["group_result"][0]["face_token"].stringValue)'") {
                                                            
                                                            token.group_id = "\(swiftyJson["group_result"][0]["group_id"].stringValue)"
                                                        }
                                                    }
                                                } catch {
                                                    print("\(error)")
                                                }
                                            }
                                            
                                            print(swiftyJson)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                        print(swiftyJson)
                    case .failure(let error):
                        print(error)
                    }
                }
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                print("next")
            }
        }
        selectedPath.removeAll()
        
    }

    
    func upload(){
    
        let photo:BmobObject = BmobObject(className: "Photos")
        
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        
        let uploadPhotos = realm.objects(Photo.self)
        for indexPath in selectedPath {
            
            let query:BmobQuery = BmobQuery(className: "Photos")
            query.whereKey("PhotoUUID", equalTo: "\(uploadPhotos[indexPath.item].uuid)")
            query.countObjectsInBackground { (count, error) in
                if count == 0 {
                    photo.setObject(uploadPhotos[indexPath.item].uuid, forKey: "PhotoUUID")
                    photo.setObject(uploadPhotos[indexPath.item].imageData, forKey: "PhotoData")
                    
                    photo.saveInBackground { (isSuccessful, error) in
                        if error != nil{
                            print("error is \(error!.localizedDescription)")
                        }else{
                            print("上传成功")
                        }
                    }
                }
                else {
                    print("This photo is exist!")
                }
            }
            let obj = BmobObject(className: "PhotoFile")!
            let  file = BmobFile(fileName: "\(uploadPhotos[indexPath.item].uuid)"+".jpg", withFileData: uploadPhotos[indexPath.item].imageData)!
            
            file.saveInBackground { [weak file] (isSuccessful, error) in
                if isSuccessful {
                    //如果文件保存成功，则把文件添加到file列
                    let weakFile = file
                    obj.setObject(weakFile, forKey: "file")
                    obj.setObject(uploadPhotos[indexPath.item].uuid, forKey: "uuid")
                    obj.saveInBackground(resultBlock: { (success, err) in
                        if err != nil {
                            print("save \(String(describing: error))")
                        }
                    })
                }else{
                    print("upload \(String(describing: error))")
                }
            }
        }
        
        HUD.flash(.progress,delay: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            HUD.flash(.success,delay: 1.5)
            
            self.collectionView?.reloadData()
        }
        
        
        selectedPath.removeAll()
        
    
    }
}

extension UploadCollectionViewController: UploadCollectionViewControllerDelegate {
    func changeNavigationUI(tabBar tabBarView: UIView) {
        
        guard let tabBarController = tabBarController else { return }
        
        tabBarController.view.addSubview(tabBarView)
        tabBarController.view.addConstraints(withFormat: "H:|[v0]|", views: tabBarView)
        tabBarController.view.addConstraints(withFormat: "V:[v0]|", views: tabBarView)
        tabBarView.heightAnchor.constraint(equalTo: tabBarController.tabBar.heightAnchor).isActive = true
    }
}



extension UploadCollectionViewController: EditableUploadList {
    // TODO Избавиться от objc
    @objc var isUploadButtonEnabled: Bool {
        return selectedPath.isEmpty
    }
    
    @objc var isCreateButtonEnabled: Bool {
        return selectedPath.isEmpty
    }
    
    func onCreateButtonTap() {
        self.create()
    }
    
    func onUploadButtonTap() {
        self.upload()
        
    }
}


