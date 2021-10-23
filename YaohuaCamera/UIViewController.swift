//
//  UIViewController.swift
//  FunSDKDemo
//
//  Created by lhb on 2017/11/16.
//  Copyright © 2017年 lutec. All rights reserved.
//

import UIKit

extension UIViewController{
    
    func navigation() {
        //隐藏系统的导航栏 不然点击事件受到影响
        self.navigationController?.isNavigationBarHidden=true
        
        // 创建一个导航栏
        let navBar = UINavigationBar(frame: CGRect(x:0, y:20, width:self.view.frame.size.width, height:60))
        // 导航栏背景颜色
        navBar.backgroundColor = UIColor.blue
        //这里是导航栏透明
        //navBar.shadowImage = UIImage()
        //navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // 自定义导航栏的title，用UILabel实现
        let titleLabel = UILabel(frame: CGRect(x:0,y:0,width:50,height:60))
        titleLabel.text = "LOG IN"
        titleLabel.textColor = UIColor.red
        //这里使用系统自定义的字体
        //titleLabel.font = UIFont(name: "Roboto-Medium", size: 16)
        
        // 创建导航栏组件
        let navItem = UINavigationItem()
        // 设置自定义的title
        navItem.titleView = titleLabel
        
        // 创建左侧按钮
        let leftButton = UIBarButtonItem(title: "leftButton", style: .plain, target: self, action: nil)
        leftButton.tintColor = UIColor.red
        
        // 创建右侧按钮
        let rightButton = UIBarButtonItem(title: "rightButton", style: .plain, target: self, action: nil)
        rightButton.tintColor = UIColor.red
        
        // 添加左侧、右侧按钮
        navItem.setLeftBarButton(leftButton, animated: false)
        navItem.setRightBarButton(rightButton, animated: false)
        
        navigationItem.setHidesBackButton(true, animated: false)
        // 把导航栏组件加入导航栏
        navBar.pushItem(navItem, animated: false)
        
        // 导航栏添加到view上
        self.view.addSubview(navBar)
    }
    
}

