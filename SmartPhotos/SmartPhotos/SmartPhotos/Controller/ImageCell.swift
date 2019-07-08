//
//  ImageCell.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/4/15.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
        }
    }

    func configure(image: UIImage) {
        imageView.image = image
    }
}
