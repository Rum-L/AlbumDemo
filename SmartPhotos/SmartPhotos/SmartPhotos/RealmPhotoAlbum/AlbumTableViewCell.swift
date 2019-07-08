//
//  AlbumTableViewCell.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/13.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
   
    @IBOutlet weak var thumnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumnailView.layer.cornerRadius = 5.0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        thumnailView.image = UIImage(named: "placeholder")
    }
}
