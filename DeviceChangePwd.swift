//  DeviceChangePwd.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
import UIKit
import MBProgressHUD

class DeviceChangePwd: UIViewController {

    @IBOutlet var leftBarView: UIView!

    var device:Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont(name: "HelveticaNeue-Bold", size: 17)!]
        self.navigationItem.title = NSLocalizedString("Sure_Reset", comment: "")
        self.oldpassword.placeholder = NSLocalizedString("Old_Password", comment: "")
        self.newpassword.placeholder = NSLocalizedString("New_Password", comment: "")
        self.verifypassword.placeholder = NSLocalizedString("New_Password2", comment: "")
        confirmlabel.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
       
        //左导航按钮
        let left_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
        left_negativeSpacer.width = -18.0
        let leftBar = UIBarButtonItem(customView: self.leftBarView)
        self.navigationItem.leftBarButtonItems = [left_negativeSpacer,leftBar]
    }

    @IBOutlet weak var newpassword: UITextField!
    @IBOutlet weak var verifypassword: UITextField!
    @IBOutlet weak var oldpassword: UITextField!
    @IBOutlet weak var confirmlabel: UIButton!
    
    @IBAction func confirm(_ sender: AnyObject) {
        Async(){
            let _ = (SDK.sharedSDK() as AnyObject).send("BFbU", dev: self.device?.sn)
            sleep(1)
            let _ = (SDK.sharedSDK() as AnyObject).send("BFbU", dev: self.device?.sn)
        }
        if let new=newpassword.text {
        if new.isEmpty{
            //Toast.make(context:self.view, msg: "Password can not be empty!").show()
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.label.text = NSLocalizedString("not_support_empty_passowrd", comment: "")
            hud.backgroundView.style = .solidColor
            hud.hide(animated: true, afterDelay: 2)
            
            print("Password can not be empty!")
            return
            }else{
            if let sn=device?.sn {
            if let one=device?.password {
            if let two=oldpassword.text {
                if one == two {
                    let verify=verifypassword.text
                    if new==verify {
                        (SDK.sharedSDK() as AnyObject).changePwd(sn, opwd: one, npwd: new)
                        let action = "修改密码"
                        let snid = new
                        addlog(action:action,snid:snid)
                        print("new password: \(sn),\(one)")
                        let app = UIApplication.shared.delegate as? AppDelegate
                        app?.onDeviceChange()

                        
                        if let more = self.navigationController?.viewControllers[self.navigationController!.viewControllers.index(of: self)! - 1]  as? MoreViewController {
                            more.tableView.reloadData()
                        }
                        if let app = UIApplication.shared.delegate as? AppDelegate {
                            
                            if  self.device  != nil {
                                if self.device!.sn == app.select.sn {
                                    app.main.onSelectItemChange()
                                }
                            }
                        }
                        
                    }else{
                        //Toast.make(context:self.view, msg: "Passwords does not match!").show()
                        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        hud.mode = MBProgressHUDMode.text
                        hud.label.text = NSLocalizedString("EE_AS_RESET_PWD_CODE4", comment: "")
                        hud.backgroundView.style = .solidColor
                        hud.hide(animated: true, afterDelay: 2)
                        print("Passwords does not match!")
                        return
                    }
                }else{
                    //Toast.make(context:self.view, msg: "Old Password does not match![\(one)]").show()
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.mode = MBProgressHUDMode.text
                    hud.label.text = NSLocalizedString("EE_AS_EIDIT_PWD_CODE4", comment: "")

                    hud.backgroundView.style = .solidColor
                    hud.hide(animated: true, afterDelay: 2)
                    print("[\(one)] old Passwords does not match!")
                    return
                }
            }
            }
            }

            self.navigationController?.popViewController(animated: true)
            
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackClick(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
