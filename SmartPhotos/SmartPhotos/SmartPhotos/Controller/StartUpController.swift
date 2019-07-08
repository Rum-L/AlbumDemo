//
//  StartUpController.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/23.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit

class StartUpController :UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    func showAppScreen() {
        print("跳转成功！")
        performSegue(withIdentifier: "goToStart", sender: self)
    }
}
