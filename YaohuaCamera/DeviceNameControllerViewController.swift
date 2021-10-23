//
//  DeviceNameControllerViewController.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//


import UIKit

class DeviceNameControllerViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet var leftBarView: UIView!
    @IBOutlet weak var confirmlabel: UIButton!
    
    var device:Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont(name: "HelveticaNeue-Bold", size: 17)!]
        self.navigationItem.title = NSLocalizedString("rename", comment: "")//"Camera name"
        confirmlabel.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
        //左导航按钮
        let left_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
        left_negativeSpacer.width = -18.0
        let leftBar = UIBarButtonItem(customView: self.leftBarView)
        self.navigationItem.leftBarButtonItems = [left_negativeSpacer,leftBar]

        
        let padding = UIView(frame: CGRect(x: 0,y: 0,width: 8,height: 58))
        textField.leftView = padding
        textField.leftViewMode = .always
        textField.text = device?.name
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func confirm(_ sender: AnyObject) {
        if let text = textField.text {
            device?.name = text
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
            self.navigationController?.popViewController(animated: true)
            
            
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
