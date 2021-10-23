//
//  ProcessViewController.swift
//  FunSDKDemo
//
//  Created by luhongbin on 2018/2/23.
//  Copyright © 2018年 lutec. All rights reserved.
//

import UIKit

class ProcessViewController: UIViewController {

    @IBOutlet weak var process: UIProgressView!
    var timer:Timer?
    var proValue = 0.3
    override func viewDidLoad() {
        super.viewDidLoad()
        self.process.transform = CGAffineTransform(scaleX: 1.0, y: 8.0)
        self.process.progress = 0.3
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isTranslucent = true;
        self.navigationItem.hidesBackButton = true
        //利用计时器，每隔0.1秒调用一次（changeProgress）
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(changeProgress), userInfo: nil, repeats: true)

    }
//     计时器响应事件
        @objc func changeProgress() {
            proValue = proValue + 0.005 // 改变ProValue的值
            if proValue > 1 { // 停止使用计时器
                timer?.invalidate()
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.navigationBar.isTranslucent = false;
                self.navigationController?.popToRootViewController(animated: false)
            } else {
                self.process.setProgress((Float)(proValue), animated: true) // 重置进度条
            }
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
