//
//  LogInViewController.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/2/13.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import CFNotify
import TransitionButton

class LogInViewController: CustomTransitionViewController,NVActivityIndicatorViewable {
  
  //Textfields pre-linked with IBOutlets
  @IBOutlet var nameTextfield: UITextField!
  @IBOutlet var passwordTextfield: UITextField!
  
    @IBAction func RegisterButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToRegister", sender: self)
    }
    @IBAction func dismissViewController(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToStart", sender: self)
    }
   
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    nameTextfield.resignFirstResponder()
    passwordTextfield.resignFirstResponder()
  }

  @IBAction func logInPressed(_ sender: AnyObject) {
    let size = CGSize(width: 30, height: 30)
    
    //TODO: 点击登录按钮，退出键盘。
    nameTextfield.resignFirstResponder()
    passwordTextfield.resignFirstResponder()
    
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
        startAnimating(size, message: "登录中……",type: NVActivityIndicatorType.ballRotateChase, fadeInAnimation: nil)
       //Bmob后端云登录
        BmobUser.loginWithUsername(inBackground: nameTextfield.text!, password: passwordTextfield.text!) { (user, error) in
        if error != nil {
            
            self.stopAnimating(nil)
            print(error!.localizedDescription)
            let  LoginFail = CFNotifyView.cyberWith(title: "Fail",body: "登录失败,错误原因：\(error!.localizedDescription)",theme: .fail(.light))
            var config = CFNotify.Config()
            config.appearPosition = .top
            CFNotify.present(config: config, view: LoginFail)
        }else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.stopAnimating(nil)
            }
            print("登陆成功")
            self.performSegue(withIdentifier: "goToChat", sender: self)
            let  LoginSuccess = CFNotifyView.cyberWith(title: "Success",body: "登录成功",theme: .success(.light))
            var config = CFNotify.Config()
            config.hideTime = .custom(seconds: 0.5)
            CFNotify.present(config: config, view: LoginSuccess)
            let  LoginInfo = CFNotifyView.cyberWith(title: "Info",body: "欢迎回来，\(String(describing: self.nameTextfield.text!)) ！",theme: .success(.light))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                config.appearPosition = .top
                CFNotify.present(config: config, view: LoginInfo)
            }
            }
        }
    }
  }
}  
