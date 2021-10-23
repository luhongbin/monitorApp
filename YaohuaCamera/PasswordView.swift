//
//  PasswordView.swift
//  CAM light
//
//  Created by luhongbin on 2018/7/19.
//  Copyright © 2018年 lutec. All rights reserved.
//

import UIKit
import MBProgressHUD
import PasswordTextField

class PasswordView: UIViewController {
    @IBOutlet weak var test: PasswordTextField!
    
    @IBOutlet weak var newpass: PasswordTextField!
    @IBOutlet weak var oklab: UIButton!
    @IBOutlet weak var canclelab: UIButton!
    @IBOutlet weak var titles: UILabel!
    @IBAction func okbnt(_ sender: Any) {
        if let one = test.text{
            if let two = newpass.text{
                if one == two {
                    if !(one.isEmpty) {
                        (SDK.sharedSDK() as AnyObject).changePwd(UserDefaults.standard.string(forKey: "当前sn"), opwd: "", npwd: one)
                        UserDefaults.standard.setValue(one, forKey: "新密码")
                        self.dismiss(animated: true, completion:nil)
                    } else {
                        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        hud.mode = MBProgressHUDMode.text
                        hud.label.text = NSLocalizedString("not_support_empty_passowrd", comment: "")
                        hud.backgroundView.style = .solidColor
                        hud.hide(animated: true, afterDelay: 2)
                    }
                }else{
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.mode = MBProgressHUDMode.text
                    hud.label.text = NSLocalizedString("EE_AS_RESET_PWD_CODE4", comment: "")
                    hud.backgroundView.style = .solidColor
                    hud.hide(animated: true, afterDelay: 2)
                }
            }
        }
    }
    @IBAction func canclecbnt(_ sender: Any) {
        UserDefaults.standard.setValue("bknsjnxxm923", forKey: "新密码")
        self.dismiss(animated: true, completion:nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        canclelab.setTitle(NSLocalizedString("cancel", comment: ""), for:UIControlState.normal)
        oklab.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
        titles.text = NSLocalizedString("EE_ACCOUNT_PASSWORD_IS_EMPTY", comment: "")
        test.placeholder = NSLocalizedString("Fill Password", comment: "")
        newpass.placeholder = NSLocalizedString("New_Password2", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
       /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
