//
//  ViewController.swift
//  FunSDKDemo
//
//  Created by lhb on 2017/12/11.
//  Copyright © 2017年 lutec. All rights reserved.
//

import UIKit
import MBProgressHUD

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //播放启动画面动画
        launchAnimation()
    }
    
    //播放启动画面动画
    private func launchAnimation() {
        //获取启动视图
        let vc = UIStoryboard(name: "LaunchScreen", bundle: nil)
            .instantiateViewController(withIdentifier: "launch")
        let launchview = vc.view!
        let delegate = UIApplication.shared.delegate
        delegate?.window!!.addSubview(launchview)
        // 添加到父视图
        //初始化对话框，置于当前的View当中
                let hud = MBProgressHUD.showAdded(to: launchview, animated: true)
                hud.label.text = NSLocalizedString("DownLoad", comment: "")//"Loading"
                hud.mode = .indeterminate
                hud.label.textColor = UIColor.red
                hud.hide(animated: true, afterDelay: 200)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

