//
//  UIView.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/13.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit

extension UIView {

    public class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }

}
