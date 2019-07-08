//
//  PhotoCollectionViewCell.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/4/13.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit
import M13Checkbox

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var uploadflag: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var checkbox: M13Checkbox! {
        didSet {
            checkbox.boxType = .circle
            checkbox.markType = .checkmark
            checkbox.boxLineWidth = 1.5
            checkbox.checkmarkLineWidth = 2.0
            checkbox.secondaryTintColor = UIColor.white
            
            checkbox.layer.shadowRadius = 2.0
            checkbox.layer.shadowOpacity = 0.4
            checkbox.layer.shadowOffset = CGSize(width: 0, height: 1)
            checkbox.layer.shadowColor = UIColor.darkGray.cgColor
            
            checkbox.stateChangeAnimation = .expand(.fill)
            checkbox.animationDuration = 0.15
            
            checkbox.isUserInteractionEnabled = false
            
            
        }
    }
    
    func editMode(value: Bool) {
        if value {
            checkbox.hideBox = false
        }
        else {
            checkbox.hideBox = true
        }
        
    }
    
    override func prepareForReuse() {
        checkbox.setCheckState(.unchecked, animated: false)
        imageView.alpha = 1.0
    }
    
    func checkPhoto() {
        guard checkbox.checkState == .unchecked else { return }
        
        checkbox.setCheckState(.checked, animated: true)
        imageView.alpha = 0.7
    }
    
    func uncheckPhoto() {
        guard checkbox.checkState == .checked else { return }
        
        checkbox.setCheckState(.unchecked, animated: true)
        imageView.alpha = 1
    }
}

