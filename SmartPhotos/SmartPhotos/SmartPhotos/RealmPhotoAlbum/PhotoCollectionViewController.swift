//
//  PhotoCollectionViewController.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/13.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit
import RealmSwift
import Fusuma
import SwifterSwift
import SCLAlertView
import PKHUD
import Alamofire
import SwiftyJSON

private let reuseIdentifier = "PhotoCell"

protocol PhotoCollectionViewControllerDelegate: class {
    func changeNavigationUI(tabBar tabBarView: UIView)
}

class PhotoCollectionViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate,FusumaDelegate{
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    private var selectedPath = [IndexPath]()
    
    weak var parentController: PhotoCollectionViewControllerDelegate?
    
    private(set) var isEditMode = false
    
    lazy var editTabBar: PhotosListEditTabbar = {

        let tabBar: PhotosListEditTabbar = .fromNib()
        tabBar.delegate = self as? EditablePhotosList
        return tabBar
    }()
    
    @IBAction func editBarButton(_ sender: UIBarButtonItem) {
    
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
        editBarButton.title = isEditMode ? "Cancel".localized() : "Edit".localized()
        editBarButton.style = isEditMode ? .done : .plain
        if isEditMode {
            print("isedit")

            self.changeNavigationUI(tabBar: editTabBar)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.navigationItem.setHidesBackButton(true, animated: true)
            self.collectionView?.reloadData()
        }
        else {
            self.navigationItem.setHidesBackButton(false, animated: true)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            editTabBar.removeFromSuperview()
            self.collectionView?.reloadData()
        }
        
    }
    
    lazy var selectedPhotosCounter: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.sizeToFit()
        label.text = "tttttt"
        return label
    }()
    
    // MARK: - Properties
    var selectedAlbum: Album!
    
    private var realm: Realm!
    private var photos: Results<Photo>!
    private var token: NotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Realm init
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        // get Photo objects in selectedAlbum
        photos = selectedAlbum.photos.sorted(byKeyPath: "saveDate", ascending: false)
        // add notification block
        token = photos.observe({ (change) in
            self.collectionView?.reloadData()
        })
        navigationItem.title = selectedAlbum.title
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
            self.editTabBar.deleteButton.isEnabled = false
            self.editTabBar.moveButton.isEnabled = false
        }
        else {
            self.editTabBar.deleteButton.isEnabled = true
            self.editTabBar.moveButton.isEnabled = true
        }
        
        print(selectedPath)
            
    
//        showDeleteAlert(indexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemLength = (collectionView.frame.size.width - 15) / 3
        return CGSize(width: itemLength, height: itemLength)
    }
    
    // MARK: UIImagePickerController
    @IBAction func showImagePicker(_ sender: AnyObject) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.delegate = self
//        self.present(imagePicker, animated: true, completion: nil)
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.cropHeightRatio = 1.0
        fusuma.allowMultipleSelection = false
        fusuma.availableModes = [.library,  .camera]
        fusuma.photoSelectionLimit = 4
        fusumaSavesImage = true
        
        present(fusuma, animated: true, completion: nil)
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        switch source {
        case .camera:
            print("Image captured from Camera")
        case .library:
            print("Image selected from Camera Roll")
        default:
            print("Image selected")
        }
        
        let selectedImage = image
        let newPhoto = Photo()
        newPhoto.imageData =
            selectedImage.jpegData(compressionQuality: 0.01)!
        
        // realm write
        do {
            try realm.write {
                self.selectedAlbum.photos.append(newPhoto)
            }
        } catch {
            print("\(error)")
        }

    }
    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        switch source {
        case .camera:
            print("Called just after dismissed FusumaViewController using Camera")
        case .library:
            print("Called just after dismissed FusumaViewController using Camera Roll")
        default:
            print("Called just after dismissed FusumaViewController")
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested",
                                      message: "Saving image needs to access your photo album",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { (action) -> Void in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        })
        
        guard let vc = UIApplication.shared.delegate?.window??.rootViewController, let presented = vc.presentedViewController else {
            return
        }
        
        presented.present(alert, animated: true, completion: nil)
    }
    
    func fusumaClosed() {
        print("Called when the FusumaViewController disappeared")
    }
    
    func fusumaWillClosed() {
        print("Called when the close button is pressed")
    }

//    func showDeleteAlert(indexPath: IndexPath) {
//        let alertController = UIAlertController(title: "Delete", message: "", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteAction) in
//            // realm delete
//            do {
//                try self.realm.write {
//                    self.realm.delete(self.photos[indexPath.item])
//                }
//            } catch {
//                print("\(error)")
//            }
//        }
//        alertController.addAction(cancelAction)
//        alertController.addAction(deleteAction)
//
//        present(alertController, animated: true, completion: nil)
//    }
    
}

extension PhotoCollectionViewController: PhotoCollectionViewControllerDelegate {
    func changeNavigationUI(tabBar tabBarView: UIView) {
        
        guard let tabBarController = tabBarController else { return }
        
        tabBarController.view.addSubview(tabBarView)
        tabBarController.view.addConstraints(withFormat: "H:|[v0]|", views: tabBarView)
        tabBarController.view.addConstraints(withFormat: "V:[v0]|", views: tabBarView)
        tabBarView.heightAnchor.constraint(equalTo: tabBarController.tabBar.heightAnchor).isActive = true
    }
}

extension PhotoCollectionViewController: EditablePhotosList {
    // TODO Избавиться от objc
    @objc var isMoveButtonEnabled: Bool {
        return selectedPath.isEmpty
    }

    @objc var isDeleteButtonEnabled: Bool {
        return selectedPath.isEmpty
    }

    func onDeleteButtonTap() {
        let title = "是否删除选中的"+"\(self.selectedPath.count)"+"张照片"
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "删除", style: .destructive) { (deleteAction) in
            // realm delete
            self.selectedPath.sort() {
                 $0 < $1
            }
            
            for indexPath in self.selectedPath.reversed() {
                //face++ delete
                let parameters: Parameters = [ "api_key": "jKZvJE9Eg_pzgUp55ogBvcsIaK0sBtlw",
                                               "api_secret": "yhUTggbAMpeDhDh7Jc4vDThIDWgzHnMc",
                                               "facealbum_token": "1560279838-fac5e875-22f5-4ef8-af5d-c8a73ed5fbe4",
                                               "Image_id": "\(self.photos[indexPath.item].image_id)"
                    
                ]
                AF.request("https://api-cn.faceplusplus.com/imagepp/v1/facealbum/deleteface", method: .post, parameters: parameters).responseJSON{ response in
                    switch response.result {
                        
                    case .success(let value):
                        let swiftyJson = JSON(value)
                        print(swiftyJson)
                        //realm delete
                        do {
                            try self.realm.write {
                                //delete Token
                                for token in self.realm.objects(Token.self).filter("image_id = '\(self.photos[indexPath.item].image_id)' ") {
                                    self.realm.delete(token)
                                }
                                //delete photos
                                self.realm.delete(self.photos[indexPath.item])
                                
                            }
                             self.selectedPath.removeAll()
                        }
                        catch {
                            print("\(error)")
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                
                
            }
            
            HUD.flash(.progress,delay: 0.5)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                HUD.flash(.success,delay: 1.5)
            }
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
       
        
    }

    func onMoveButtonTap() {
        
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        
        
        let alertView = SCLAlertView()
        
        if self.selectedPath.count > 1 {
            alertView.showInfo("错误提示", subTitle: "选择的照片数量超过1张",closeButtonTitle: "重新选择")
        }
        else {
            for allalbum in realm.objects(Album.self).filter("title !=  '\(selectedAlbum.title)'") {
                alertView.addButton(allalbum.title) {
                    
                    print(allalbum.title)
                    do {
                        try self.realm.write {
                            for indexPath in self.selectedPath {
                                print(indexPath)
                                let pt = Photo()
                                pt.imageData = self.selectedAlbum.photos.reversed()[indexPath
                                    .item].imageData
                                self.realm.delete(self.selectedAlbum.photos.reversed()[indexPath
                                    .item])
                                allalbum.photos.append(pt)
                            }
                            
                            // get Photo objects in selectedAlbum
                        
                            self.selectedPath.removeAll()
                            
                                
                        }
                    } catch {
                        print("\(error)")
                    }
                    HUD.flash(.progress,delay: 0.5)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        HUD.flash(.success,delay: 1.5)
                    }
                }
            }
    
            alertView.showSuccess("移动至", subTitle: "选择你要移动到的相册",closeButtonTitle: "取消")
            
            
        }
        
        
        
       
    }
}

