//
//  DetailViewController.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/18.
//  Copyright © 2019 林铭杰.  All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    private var detailTitle: String!

    class func make(detailTitle: String) -> UIViewController {
        let viewController = UIStoryboard(name: "DetailViewController", bundle: nil)
            .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.detailTitle = detailTitle
        
        
       viewController.viewDidLoad()
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = detailTitle
    }
}
