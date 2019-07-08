//
//  RegisterViewController.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/2/13.
//  Copyright © 2019 林铭杰. All rights reserved.
//
import UIKit
import NVActivityIndicatorView
import CFNotify

class RegisterViewController: UIViewController,NVActivityIndicatorViewable,CFNotifyDelegate {
    
var titleView = ClassicView(title: "", body: "", image: nil)
    
  //Pre-linked IBOutlets
  @IBOutlet var nameTextfield: UITextField!
  @IBOutlet var passwordTextfield: UITextField!
    
    @IBAction func backButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toBack", sender: self)
    }
    
//提示框示例
//    let cyberView = CFNotifyView.cyberWith(title: "Info",
//                                               body: "Try dragging this alert around !",
//                                               theme: .info(.light)
//        var config = CFNotify.Config()
//        config.hideTime = .never
//        CFNotify.present(config: config, view: cyberView)

    override func viewDidLoad() {
    super.viewDidLoad()
        CFNotify.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  //点击文本框之外，键盘消失
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
    }
  
  
 
    
    @IBAction func registerPressed(_ sender: AnyObject) {
    
    //TODO: 点击注册按钮，退出键盘。
    nameTextfield.resignFirstResponder()
    passwordTextfield.resignFirstResponder()
    
    let size = CGSize(width: 30, height: 30)
    
    //TODO: Set up a new user on our Bomb database
    let user = BmobUser()
    //判断用户名和密码是否为空
        if nameTextfield.text == nil && passwordTextfield == nil {
            let  notHaveName = CFNotifyView.cyberWith(title: "Warning",body: "请输入用户名和密码!",theme: .warning(.light))
            let config = CFNotify.Config()
            CFNotify.present(config: config, view: notHaveName)
        }else if nameTextfield.text == nil {
            let  notHaveName = CFNotifyView.cyberWith(title: "Warning",body: "请输入用户名!",theme: .warning(.light))
            let config = CFNotify.Config()
            CFNotify.present(config: config, view: notHaveName)
        }else if passwordTextfield == nil {
            let  notHaveName = CFNotifyView.cyberWith(title: "Waring",body: "请输入密码!",theme: .warning(.light))
            let config = CFNotify.Config()
            CFNotify.present(config: config, view: notHaveName)
        }else {
            
            user.username = nameTextfield.text!
            user.password = passwordTextfield.text!
            self.startAnimating(size, message: "注册中...",type: NVActivityIndicatorType.ballRotateChase, fadeInAnimation: nil)
            user.signUpInBackground() { (isSuccessful, error) in
                if isSuccessful {
                    self.stopAnimating(nil)
                    print("注册成功")
                    //弹窗选择是否跳转
                  self.performSegue(withIdentifier: "goToMain", sender: self)
                    let  RegisterSuccess = CFNotifyView.cyberWith(title: "Success",body: "注册成功！",theme: .success(.light))
                    var config = CFNotify.Config()
                    config.hideTime = .custom(seconds: 0.5)
                    CFNotify.present(config: config, view: RegisterSuccess)
                    let  LoginInfo = CFNotifyView.cyberWith(title: "Info",body: "欢迎你，\(String(describing: user.username!)) ！",theme: .success(.light))
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        config.appearPosition = .top
                       CFNotify.present(config: config, view: LoginInfo)
                    }
                    
                    
                }else{
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.stopAnimating(nil)
                    }
                    print("注册失败，错误原因：\(error!.localizedDescription)")
                    let  RegisterFail = CFNotifyView.cyberWith(title: "Fail",body: "注册失败,错误原因：\(error!.localizedDescription)",theme: .fail(.light))
                    var config = CFNotify.Config()
                    config.appearPosition = .top
                    CFNotify.present(config: config, view: RegisterFail)
                }
            }
        }
    }
}
