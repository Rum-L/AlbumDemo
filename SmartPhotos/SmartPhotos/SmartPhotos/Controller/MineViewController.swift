//
//  MineController.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/17.
//  Copyright © 2019 林铭杰. All rights reserved.
//
import UIKit
import RealmSwift
import SCLAlertView

class MineViewController: UIViewController {
    private var realm: Realm!
    
    @IBOutlet weak var PhotoCount: UILabel!
    
    @IBOutlet weak var AlbumsCount: UILabel!
    
    @IBOutlet weak var UserName: UILabel!
    

    @IBAction func shuaxin(_ sender: UIButton) {
        
        PhotoCount.text = "\(realm.objects(Photo.self).count)"
        AlbumsCount.text = "\(realm.objects(Album.self).count)"
    }
    
    @IBAction func feedback(_ sender: UIButton) {
        let alert = SCLAlertView()
        let txt = alert.addTextField("输入你要反馈的信息")
        alert.addButton("反馈") {
            print("Text value: \(txt.text)")
        }
        
        alert.showEdit("意见反馈", subTitle: "可以输入你想要反馈的意见或者对本应用的建议。",closeButtonTitle: "取消")
    }
    @IBAction func SignOut(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "toSignOut", sender: self)
        
        BmobUser.logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        
        PhotoCount.text = "\(realm.objects(Photo.self).count)"
        AlbumsCount.text = "\(realm.objects(Album.self).count)"
        
        let user = BmobUser.getCurrent()
        
        if user != nil {
            //对象为空时，可打开用户注册界面
            self.performSegue(withIdentifier: "toSignOut", sender: self)
        }
        
        UserName.textAlignment = .center
        let customImage: UIImageView = UIImageView.init(frame: CGRect(x: self.view.bounds.midX - 40, y: self.view.bounds.midY - 300, width: 80, height: 80))
        self.view.addSubview(customImage)
        
        customImage.setImageForName("\(user?.username ?? "Admin")", circular: true, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "AmericanTypewriter-Bold", size: 30)!, NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.init(white: 1.0, alpha: 0.5)])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
