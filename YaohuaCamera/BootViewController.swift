//
//  BootViewController.swift
//  FunSDKDemo
//
//  Created by luhongbin on 2018/2/11.
//  Copyright © 2018年 lutec. All rights reserved.
//

import UIKit
class BootViewController: UIViewController {

    @IBOutlet weak var process: UIProgressView!
    //var timer:Timer?
    var proValue:Double!
    var i = 0
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.navigationBar.isTranslucent = false;
//        self.navigationItem.hidesBackButton = true

        //self.process.transform = CGAffineTransform(scaleX: 1.0, y: 5.0)
        self.process.progress = 0.3
        proValue = 0.3
        //Thread.sleep(forTimeInterval: 12)
        //利用计时器，每隔0.1秒调用一次（changeProgress）
        //timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(changeProgress), userInfo: nil, repeats: true)
        for i in 4...10 {
            Thread.sleep(forTimeInterval: 1.2)
            proValue =  Double(i) / 10
            print(proValue)
            self.process.setProgress((Float)(proValue), animated: true) // 重置进度条
        }
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationController?.popToRootViewController(animated: false)
     }
    // 计时器响应事件
//    @objc func changeProgress() {
//        proValue = proValue + 0.1 // 改变ProValue的值
//        if proValue > 1 {
//            print("停止使用计时器") // 停止使用计时器
//            timer?.invalidate()
//
//        } else {
//            print(proValue)
//            self.process.setProgress((Float)(proValue), animated: true) // 重置进度条
//        }
//    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 隐藏状态栏
    override var prefersStatusBarHidden : Bool {
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
