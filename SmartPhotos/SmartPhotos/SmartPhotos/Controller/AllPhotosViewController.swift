//
//  AllPhotosViewController.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/6/4.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit
import Serrata
import RealmSwift

final class AllPhotosViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
            collectionView.delegate = self as UICollectionViewDelegate
        
            collectionView.dataSource = self as UICollectionViewDataSource
        }
    }

    @IBOutlet weak private var flowLayout: UICollectionViewFlowLayout! {
        didSet {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 1
            flowLayout.minimumInteritemSpacing = 1
        }
    }
    

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
        
        
        photos = realm.objects(Photo.self)

//        for i in 0...29 {
//            images.append(UIImage(named: "image\(i).jpg") ?? UIImage())
//        }
        for i in photos {
            images.append(UIImage(data: i.imageData) ?? UIImage())
        }
   
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        
        
        photos = realm.objects(Photo.self)
        
        images.removeAll()		
        
        for i in photos {
            images.append(UIImage(data: i.imageData) ?? UIImage())
        }
        
        collectionView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension AllPhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ImageCell else {
            return
        }
        
        let slideLeafs: [SlideLeaf] = images.enumerated().map { SlideLeaf(image: $0.1,
                                                                          title: "第\($0.0)张",
            caption: "图片详情:暂无内容。") }
        
        let slideImageViewController = SlideLeafViewController.make(leafs: slideLeafs,
                                                                    startIndex: indexPath.row,
                                                                    fromImageView: selectedCell.imageView)
        
        slideImageViewController.delegate = self
        present(slideImageViewController, animated: true, completion: nil)
    }
}

extension AllPhotosViewController: SlideLeafViewControllerDelegate {
    
    func tapImageDetailView(slideLeaf: SlideLeaf, pageIndex: Int) {
        print(pageIndex)
        print(slideLeaf)
        
        let viewController = DetailViewController.make(detailTitle: slideLeaf.title)
        navigationController?.show(viewController, sender: nil)
    }
    
    func longPressImageView(slideLeafViewController: SlideLeafViewController, slideLeaf: SlideLeaf, pageIndex: Int) {
        print(slideLeafViewController)
        print(slideLeaf)
        print(pageIndex)
    }
    
    func slideLeafViewControllerDismissed(slideLeaf: SlideLeaf, pageIndex: Int) {
        print(slideLeaf)
        print(pageIndex)
        
        let indexPath = IndexPath(row: pageIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

extension AllPhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.configure(image: images[indexPath.row])
        return cell
    }
}

extension AllPhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isPortraint = UIApplication.shared.statusBarOrientation.isPortrait
    
        let itemSide: CGFloat = isPortraint ? (collectionView.bounds.width - 1) / 2 : (collectionView.bounds.width - 2) / 3
        return CGSize(width: itemSide, height: itemSide)
    }
}

