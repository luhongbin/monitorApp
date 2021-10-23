//
//  ViewController.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
import UIKit
import MBProgressHUD
import Foundation
import PasswordTextField
import SnapKit
import PopupDialog

class MainController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,MainViewCellDelegate{
    //导航栏
    @IBOutlet var nav: UIView!
    @IBOutlet weak var nav_img_right: UIImageView!
    @IBOutlet weak var nav_img_left: UIImageView!
    @IBOutlet weak var nav_pc: UIPageControl!
    @IBOutlet weak var nav_title: UILabel!
    //导航按钮
    @IBOutlet var button_left: UIView!
    @IBOutlet var button_left_container: UIView!
    @IBOutlet var button_right: UIButton!
    @IBOutlet var button_right_container: UIView!
    @IBOutlet var list: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var app: AppDelegate!
    var cells:[String:MainViewCell]!
    var hud:MBProgressHUD?
    var willScrollTo:String?
    var orientation  = UIDeviceOrientation.portrait
    
    override func viewDidLoad() {  //MARK:生命周期
        orientation = UIDevice.current.orientation
        app = UIApplication.shared.delegate as! AppDelegate
        cells = [String:MainViewCell]()
        
        navication_init() //导航栏
        flowLayout.itemSize = CGSize(width: ScreenWidth,height: ScreenHeight-( iPhonex ? 88:64 ) )
        list.setCollectionViewLayout(flowLayout, animated: true)
        if app.devices.isEmpty {
            self.navigationController?.pushViewController(NewCameraController(nibName:"NewCameraController",bundle: nil), animated: false)
        }
    }
    
    func willScroll(_ sn:String) {
        willScrollTo = sn
    }
    override func viewDidAppear(_ animated: Bool) {
        if let sn = willScrollTo {
            scrollTo(sn)
            willScrollTo = nil
        }
    }
     override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onConnectSuccess(_:)), name: NSNotification.Name(rawValue: RET_CONNECT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onLoading(_:)), name: NSNotification.Name(rawValue: RET_LOADING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onPlayResult(_:)), name: NSNotification.Name(rawValue: RET_PLAY), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onShotResult(_:)), name: NSNotification.Name(rawValue: RET_SHOT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onRecordResult(_:)), name: NSNotification.Name(rawValue: RET_RECORD), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onSoundDBResult(_:)), name: NSNotification.Name(rawValue: RET_DB), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onCacheResult(_:)), name: NSNotification.Name(rawValue: RET_CACHE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onDisconnect(_:)), name: NSNotification.Name(rawValue: RET_DISCONNECT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onUerLocked(_:)), name: NSNotification.Name(rawValue: RET_USER_LOCKED), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onTimer(_:)), name: NSNotification.Name(rawValue: RET_TIMER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onConfigResutl(_:)), name: NSNotification.Name(rawValue: RET_CONFIG), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onEndResult(_:)), name: NSNotification.Name(rawValue: RET_END), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onOfflineResult(_:)), name: NSNotification.Name(rawValue: RET_OFFLINE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onFindResult(_:)), name: NSNotification.Name(rawValue: RET_FIND), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onPasswordError(_:)), name: NSNotification.Name(rawValue: RET_PWD_ERROR), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onMCLinkResult(_:)), name: NSNotification.Name(rawValue: RET_MC_LINK), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onTimeOut(_:)), name: NSNotification.Name(rawValue: RET_TIME_OUT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onHomePress(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onPlayRet1(_:)), name: NSNotification.Name(rawValue: RET_PLAY_1), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onPasswordChange(_:)), name: NSNotification.Name(rawValue: RET_PWD_CHANGE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onDebug(_:)), name: NSNotification.Name(rawValue: RET_DEBUG), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onConnecting(_:)), name: NSNotification.Name(rawValue: RET_CONNECT_START), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onSearching(_:)), name: NSNotification.Name(rawValue: RET_SEARCHING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onDSS(_:)), name: NSNotification.Name(rawValue: RET_DSS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onRPS(_:)), name: NSNotification.Name(rawValue: RET_RPS), object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications() // 检测设备方向
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.onOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        if nav.superview == nil{
            self.navigationController?.navigationBar.addSubview(nav)
            nav.center.x = (self.navigationController?.navigationBar.center)!.x
        }
        if app.devices.isEmpty {
            app.select = nil
            self.navigationController?.pushViewController(NewCameraController(nibName:"NewCameraController",bundle: nil), animated: false)
        }else{
            if app.select == nil {
                scrollTo(app.devices.first!.sn)
            }else{
                onSelectItemChange()
                let cell = self.cells[app.select.sn]
                cell?.refreshStatus()
            }
//            let GetMyLocation = MyLocation()
//            self.view.addSubview(GetMyLocation)
        }
    }
    

    @objc func onHomePress(_ notification:Notification){
        for cell in cells  {
            cell.1.screen.disconnect()
            cell.1.onStop()
            MBProgressHUD.hide(for: cell.1.screenContainer, animated: true)
        }
    }
    @objc func  onDebug(_ notification:Notification){
        //        Toast.make(self.view, msg: "\(notification.object as! Int)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        if nav.superview != nil{
            self.nav.removeFromSuperview()
        }
        for cell in cells {
            cell.1.screen.stop()
            cell.1.onStop()
            MBProgressHUD.hide(for: cell.1.screenContainer, animated: true)
        }
    }
    
    func scrollTo(_ sn:String){
        self.list.reloadData()
        self.nav_pc.numberOfPages = self.app.devices.count
        if let index = app.devices.map({$0.sn}).index(of: sn) {
            onPageChange(self.nav_pc.currentPage, newValue: index)
            list.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionViewScrollPosition(), animated: false)
        }
    }
    
    @objc func onOrientationChange(){
        let current = UIDevice.current.orientation // 获取当前设备方向
        if current == UIDeviceOrientation.faceUp || orientation == UIDeviceOrientation.faceDown || orientation == UIDeviceOrientation.unknown {// 如果手机硬件屏幕朝上或者屏幕朝下或者未知
            self.orientation = current
            return
        }
        if let cell = cells[app.devices[self.nav_pc.currentPage].sn] {
        switch  current {
        case .portrait,.portraitUpsideDown: //屏幕竖直,home键在下面 屏幕竖直,home键在上面
            if orientation.isLandscape{
                //if let cell = cells[app.devices[self.nav_pc.currentPage].sn]{
                    self.navigationController?.navigationBar.isHidden = false
                    UIApplication.shared.isStatusBarHidden = false
                    flowLayout.itemSize = CGSize(width: ScreenWidth,height: ScreenHeight-( iPhonex ? 88:64 ))
                    list.setCollectionViewLayout(flowLayout, animated: true)
                    cell.screen.transform = CGAffineTransform(scaleX: 1, y: 1)
                    cell.removeGestureRecognizerFromView(cell.screen)
                    UIView.animate(withDuration: 0.3,animations: {
                        cell.screenContainer.transform = CGAffineTransform.identity
                        cell.screenContainer.translatesAutoresizingMaskIntoConstraints = false
                        cell.screen.translatesAutoresizingMaskIntoConstraints = false
                        cell.screenContainer.bounds = CGRect(x: 0, y: 0, width: SW, height: SH)

                        cell.screen.bounds = cell.screenContainer.bounds
                        cell.resetPlayButtonStatus()
                        
                        cell.progressLandScape?.removeFromSuperview()
                        cell.indicatorLandScape?.removeFromSuperview()
                        
                        },completion:{a in
                            cell.timeSelectionBar?.isHidden = !cell.switchButton.isSelected
                    })
                    list.isScrollEnabled = true
                //}
            }
        case .landscapeLeft,.landscapeRight: //屏幕水平,home键在左
           if orientation.isPortrait {
                //if let cell = cells[app.devices[self.nav_pc.currentPage].sn] {
                    if !cell.onTalk{
                        self.navigationController?.navigationBar.isHidden = true
                        UIApplication.shared.isStatusBarHidden = true
                        flowLayout.itemSize = CGSize(width:ScreenWidth,height: ScreenHeight)
                        list.setCollectionViewLayout(flowLayout, animated: true)//全屏显示

                        cell.timeSelectionBar?.isHidden = true
                        cell.screen.transform = CGAffineTransform(scaleX: 1, y: 1) // 旋转动画

                        cell.addGestureRecognizerToView(cell.screen)//添加手势跟踪
                        UIView.animate(withDuration: 0.3,animations: {  //开始旋转
                        cell.screenContainer.translatesAutoresizingMaskIntoConstraints = true
                        cell.screen.translatesAutoresizingMaskIntoConstraints = true
                        cell.screenContainer.frame = CGRect(x: 0, y: 0,width: ScreenHeight,height: ScreenWidth)
                        cell.screen.frame = cell.screenContainer.frame
                        cell.screenContainer.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2)
                        cell.screenContainer.transform = CGAffineTransform(rotationAngle: CGFloat(current == .landscapeLeft ? Double.pi / 2 : -Double.pi / 2))// 旋转角度
                        cell.resetPlayButtonStatus()
                        if cell.switchButton.isSelected {
                            if cell.progressLandScape == nil {
                                cell.progressLandScape = ProgressView(frame: CGRect(x: ScreenHeight/2, y: ScreenWidth - ScreenWidth*0.1,width: ScreenHeight*3,height: ScreenWidth*0.1))
                                cell.progressLandScape?.alpha = 1
                                cell.progressLandScape!.addGestureRecognizer(UIPanGestureRecognizer(target: cell, action: #selector(MainViewCell.onLandScapeProgressPan(_:))))
                                cell.progressLandScape!.reset(cell.progressBar.start, end: cell.progressBar.end, files: cell.progressBar.files)
                                cell.indicatorLandScape = UIImageView(frame: CGRect(x: 0, y: 0,width:iPad ? 22:12,height:iPad ? 44:22))
                                cell.indicatorLandScape?.image = UIImage(named: "pointer_icon")
                                cell.indicatorLandScape?.center = CGPoint(x: ScreenHeight/2, y: ScreenWidth - ScreenWidth*0.05)
                                }
                                cell.screenContainer.addSubview(cell.progressLandScape!)
                                cell.screenContainer.addSubview(cell.indicatorLandScape!)
                            }
                            },completion: nil)
                        list.isScrollEnabled = false

                    }
                //}
            }
        default:break
        }
        if (current != .faceUp && current != .faceDown) {
            self.orientation = current
        }
    }
    }
    //MARK:CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return app.devices.count;
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let device = app.devices[indexPath.row]
        let cell:MainViewCell!
        if let c = cells[device.sn]{
            cell = c
        }else{
            //self.automaticallyAdjustsScrollViewInsets=false  //为解决list编译报错加的，其实是用注释掉@解决的。

            collectionView.register(UINib(nibName: "MainViewCell", bundle: nil), forCellWithReuseIdentifier: device.sn)
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: device.sn, for: indexPath) as! MainViewCell
            cell.load(device)
            cell.delegate = self;
            cells[device.sn] = cell
        }
        return cell
    }
    var timerDelay:Task?
    func onTouchup(_ cell: MainViewCell, progress: CGFloat) {
        if progress >= 0 && progress < 1  {
            //            timerDelay?(cancel: true)
            //            timerDelay = delay(1){
            //                Main(){
            if cell.screen.isPlaying() {
                cell.onPlay()
                cell.screen.seek(Int32(cell.progressBar.timelong * Double(progress) + cell.progressBar.startlong))
            }else{
                cell.onPlay()
                let start = Calendar.current.dateComponents(in: TimeZone.autoupdatingCurrent, from: Date(timeIntervalSince1970: cell.progressBar.timelong * Double(progress) + Double(cell.progressBar.startlong)))
                cell.screen.replay(start, end: cell.progressBar.end)
            }
        }
    }
    @objc func onPlayRet1(_ notification:Notification){
        if app.select.sn == notification.object as! String{
            if let cell = cells[app.select.sn]{
                cell.screen.play(1)
            }
        }
    }
    
    @objc func onPasswordChange(_ notification:Notification){
        if let sn = notification.object as? String {
            if let cell = cells[sn] {
                cell.device.password = cell.screen.newwPwd;
                cell.screen.load(cell.device.sn, pwd: cell.device.password)
                app.onDeviceChange()
            }
        }
    }
    
    func onPlayButtonClick(_ cell: MainViewCell) {
        if !cell.playButton.isSelected {
            cell.onPlay()
            if !cell.switchButton.isSelected {
                print("高清：\(String(describing: cell.hdsd.currentTitle))")
//                let action = "连灯状态"
//                let snid = "connect"
                //addlog(action:action,snid:snid)
                Thread.sleep(forTimeInterval: 0.02)

                if cell.hdsd.currentTitle==NSLocalizedString("live_btn_hd", comment: "") {
                    cell.screen.play(0)
                }else{
                    cell.screen.play(1)
                }
            }else{
                cell.screen.replay(cell.progressBar.start, end: cell.progressBar.end)
            }
            //NotificationCenter.default.addObserver(self, selector: #selector(MainController.onConfigResutl(_:)), name: NSNotification.Name(rawValue: RET_CONFIG), object: nil)
            //let _ = (SDK.sharedSDK() as AnyObject).send("BFbU", dev: self.app.select.sn)
        }else{
            cell.onStop()
            cell.screen.pause(1);
            //self.list.isScrollEnabled = true
            //这两句以前是注释的
            //MBProgressHUD.hide(for: cell.screenContainer, animated: true)
        }
    }
    
    func onSwitchButtonClick(_ cell: MainViewCell){
        cell.screen.stop()
        cell.onStop()
        list.isScrollEnabled = true
    }
    //MARK:ScrollView
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let newPage = Int(offset/ScreenWidth)
        if self.nav_pc.currentPage != newPage {
            onPageChange(self.nav_pc.currentPage, newValue: newPage)
        }
    }
    var action = ""
    func onPageChange(_ oldValue:Int,newValue:Int){
        self.nav_pc.currentPage = newValue
        if let lastCell = cells[app.devices[oldValue].sn] {
            lastCell.onStop()
            lastCell.screen.disconnect()
        }
        app.select = app.devices[newValue]
        let sn = self.app.select.sn
        action = "报警级别"
        getlog(sn:sn,action:action)
        action = "报警方式"
        getlog(sn:sn,action:action)

        onSelectItemChange()
    }
    var getresult = ""
    func getlog(sn:String,action:String) { //放在这个位置原因，异步huo q
        let sn = sn
        let action = action
        let soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><getsnid xmlns='http://www.w3schools.com/xml/'><sn>\(sn)</sn><action>\(action)</action></getsnid></soap12:Body></soap12:Envelope>"
            let msgLength = String(describing: soapMessage.count)
            let url = URL(string: "http://www.umenb.com:3211/lutec/services/MyService")!
            let request = NSMutableURLRequest(url: url)
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue(msgLength, forHTTPHeaderField: "Content-Length")
            request.httpMethod = "POST"
            request.httpBody = soapMessage.data(using: String.Encoding.utf8, allowLossyConversion: false)
            let session = URLSession.shared
        
            let task =  session.dataTask(with: request as URLRequest) { (data, resp, error) in
                guard error == nil && data != nil else{ // && data != nil
                    print("connection error or data is nill")
                let url2 = URL(string: "http://192.168.0.2/lutec/services/MyService")!
        
                let request = NSMutableURLRequest(url: url2)
                request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.addValue(msgLength, forHTTPHeaderField: "Content-Length")
                request.addValue("SOAPAction",forHTTPHeaderField:"http://192.168.0.2/lutec/services/MyService")
                request.httpMethod = "POST"
                request.httpBody = soapMessage.data(using: String.Encoding.utf8, allowLossyConversion: false)
                let task =  session.dataTask(with: request as URLRequest) { (data, resp, error) in
                    guard error == nil && data != nil else{ // && data != nil
                        return
                    }
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    self.getresult =  (dataString?.substring(with: NSMakeRange(289, 1)))!
                    if action == "报警级别" {
                        if self.getresult == "1" || self.getresult == "4" || self.getresult == "7" || self.getresult == "0" || self.getresult == "2" {
                            if  self.getresult == "0" {
                                self.getresult = "1"
                            }
                            if  self.getresult == "2" {
                                self.getresult = "7"
                            }
                            self.app.select.il = Int(self.getresult)!
                            self.app.onDeviceChange()
                        }
                        self.onSelectItemChange()
                    }
                    if action == "报警方式" {
                        if self.getresult == "a" || self.getresult == "b" || self.getresult == "z" {
                            if self.getresult == "a" && self.app.select.alarm == .ON {
                                self.app.select.alarm = .DEFAULT
                            }
                            if self.getresult == "b" &&  self.app.select.alarm != .ON {
                                self.app.select.alarm = .ON
                            }
                            if self.getresult == "z" && self.app.select.alarm == .ON {
                                self.app.select.alarm = .OFF
                            }
                            self.app.onDeviceChange()
                            Thread.sleep(forTimeInterval: 0.02)

                            let _ = (SDK.sharedSDK() as AnyObject).send("BFbU", dev: self.app.select.sn)
                        }
                    }
                    if action == "连灯状态" {
                        let userDefaults = UserDefaults.standard
                        userDefaults.setValue(self.getresult, forKey: action)
                        userDefaults.synchronize()
                    }
                    return
                }
                task.resume()
                return
            }
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                self.getresult =  (dataString?.substring(with: NSMakeRange(289, 1)))!
                if action == "报警级别" {
                    if self.getresult == "1" || self.getresult == "4" || self.getresult == "7" || self.getresult == "0" || self.getresult == "2" {
                        if  self.getresult == "0" {
                            self.getresult = "1"
                        }
                        if  self.getresult == "2" {
                            self.getresult = "7"
                        }
                        self.app.select.il = Int(self.getresult)!
                        self.app.onDeviceChange()
                    }
                }
                if action == "报警方式" {
                    if self.getresult == "a" || self.getresult == "b" || self.getresult == "z" {
                        if self.getresult == "a" && self.app.select.alarm == .ON {
                            self.app.select.alarm = .DEFAULT
                        }
                        if self.getresult == "b" &&  self.app.select.alarm != .ON {
                            self.app.select.alarm = .ON
                        }
                        if self.getresult == "z" && self.app.select.alarm == .ON {
                            self.app.select.alarm = .OFF
                        }
                        self.app.onDeviceChange()
                    }
                }
                if action == "连灯状态" {
                    let userDefaults = UserDefaults.standard
                    userDefaults.setValue(self.getresult, forKey: action)
                    userDefaults.synchronize()
            }
            return
        }
        task.resume()
    }

    func onSelectItemChange(){
        DispatchQueue.main.async { // Correct
            self.nav_title.text = self.app.select.name
            //self.button_right.setImage(UIImage(named: "ic_middle_small"), for: UIControlState())
        }
     }

    func navication_init(){ //MARK:导航栏初始化
        //self.navigationController?.navigationBar.barTintColor = UIColor(hex: 0xF07800) //修改导航栏背景色
        if iPhonex {
            //self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_topbgx"), for: .any, barMetrics: .default)//背景

        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_topbg"), for: .any, barMetrics: .default)//背景
        }
        // 2.定义右边的按钮
 //        self.navigationItem.rightBarButtonItems = UIBarButtonItem(image: UIImage(named:"ic_middle_small"),style:UIBarButtonItemStyle.plain,target:self,action:#selector(MainController.rightAction))       // let rightBtn = UIButton()
//        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        spacer.width = 1
//

        //添加左导航按钮
        let leftSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
        leftSpace.width = -18.0
        let a = UIBarButtonItem(customView: self.button_left_container)
        self.navigationItem.leftBarButtonItems = [leftSpace,a]
        self.button_left.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.onLeftButtonClick(_:))))
        //设置右导航按钮
//        let rightSpace = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
//        rightSpace.width = -18.0
//        let b = UIBarButtonItem.init(customView: self.button_right_container)
//        self.navigationItem.rightBarButtonItems = [rightSpace,b]
//        self.button_right.addTarget(self, action: #selector(MainController.rightAction), for: UIControlEvents.touchUpInside)
//        self.button_right.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainController.onRightButtonClick(_:))))
//
//        let titleTap = UITapGestureRecognizer(target: self, action: #selector(MainController.onTitleClick))
//        self.nav_title.addGestureRecognizer(titleTap)
//
        let rightBtn = UIButton.init(frame:CGRect(x: 0, y: 0, width: 44, height: 44))
        rightBtn.addTarget(self, action: #selector(MainController.rightAction), for: UIControlEvents.touchUpInside)
        rightBtn.setImage(UIImage(named: "ic_middle_small"), for: UIControlState.normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView:rightBtn)
        rightBtn.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        rightBtn.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        //        if iPad {
//            rightBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 0, 0)
//
//        }else{
//            rightBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 20, 0, -12)
//
//        }
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(MainController.onTitleClick))
        self.nav_title.addGestureRecognizer(titleTap)
    }
    
    @objc func onTitleClick(){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        if let popoverController = alert.popoverPresentationController { //ipad使用，不加ipad上会崩溃
            popoverController.sourceView = self.nav
            popoverController.sourceRect = self.nav.bounds
        }
        let actionRename = UIAlertAction(title: NSLocalizedString("rename", comment: ""), style: .default){ action in
            let renameAlert = UIAlertController(title: NSLocalizedString("rename", comment: ""), message: nil, preferredStyle: .alert)
            renameAlert.addTextField(configurationHandler: nil)
            renameAlert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { handle in
                if let name = renameAlert.textFields![0].text{
                    self.app.select.name = name
                    self.nav_title.text = self.app.select.name
                    (SDK.sharedSDK() as AnyObject).setAlarm(self.app.select.alarm != AlarmMode.OFF, sn: self.app.select.sn, name: self.app.select.name)

                    self.app.onDeviceChange()
                }
            }))
            
            renameAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            self.present(renameAlert, animated: true, completion: nil)
            //            if let cell = self.cells[self.app.select.sn] {
            //                cell.screen.cpwd()
            //            }
        }
        alert.addAction(actionRename)

        let actionCancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func onLeftButtonClick(_ tap:UITapGestureRecognizer){//MARK:点击事件
        self.navigationController?.pushViewController(NewCameraController(nibName: "NewCameraController",bundle: nil), animated: true)
    }

    @objc func onRightButtonClick(_ tap:UITapGestureRecognizer){
        if self.app.select.mode == .Test {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .text
            hud.label.text = NSLocalizedString("please_change_the_mode_setting", comment: "")//"Please change the MODE setting"
            hud.label.textColor = UIColor.init(hex: 0x770B2F)
            hud.hide(animated: true, afterDelay: 2)
        }else{
            self.navigationController?.pushViewController(InductionSettingController(nibName: "InductionSettingController",bundle: nil), animated: true)
        }
    }
       @objc private func rightAction(){
            if self.app.select.mode == .Test {
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .text
                hud.label.text = NSLocalizedString("please_change_the_mode_setting", comment: "")//"Please change the MODE setting"
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
            }else{

                self.navigationController?.pushViewController(InductionSettingController(nibName: "InductionSettingController",bundle: nil), animated: true)
            }
        }
    @IBAction func buttonright(_ sender: Any) {
        if self.app.select.mode == .Test {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .text
            hud.label.text = NSLocalizedString("please_change_the_mode_setting", comment: "")//"Please change the MODE setting"
            hud.label.textColor = UIColor.init(hex: 0x770B2F)
            hud.hide(animated: true, afterDelay: 2)
        }else{
            self.navigationController?.pushViewController(InductionSettingController(nibName: "InductionSettingController",bundle: nil), animated: true)
        }
    }
    @objc func onLoading(_ notification:Notification){
        if let sn = notification.object as? String  {
            if let cell = cells[sn] {
                MBProgressHUD.hide(for: cell.screenContainer, animated: true)
                let hud = MBProgressHUD.showAdded(to: cell.screenContainer, animated: true)
                hud.label.text = NSLocalizedString("DownLoad", comment: "")//"Loading"
                hud.mode = .indeterminate
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
                cell.onPlay()
            }
        }
    }
    
    @objc func onConnectSuccess(_ notification:Notification){//MARK:SDK回调
        print("k碍事回去")
        if let sn = notification.object as? String  {
            if let cell = cells[sn] {
                Async(){
                    let _ = (SDK.sharedSDK() as AnyObject).send("BFbU", dev: self.app.select.sn)
                    Thread.sleep(forTimeInterval: 0.02)
                    let _ = (SDK.sharedSDK() as AnyObject).send("BFbU", dev: self.app.select.sn)
                }
//                if cell.device.password.isEmpty {
//                   //if  (SDK.sharedSDK() as AnyObject).searchsn(sn)==true {
//                        UserDefaults.standard.setValue(cell.device.sn, forKey: "当前sn")
//                    
//                        let okVC = PasswordView(nibName: "PasswordView", bundle: nil)
//                        let popup = PopupDialog(viewController: okVC,gestureDismissal: false)
//                        self.present(popup, animated: true, completion: nil)
//                        if !(UserDefaults.standard.string(forKey: "新密码") == "bknsjnxxm923") {
//                            cell.screen.newwPwd = UserDefaults.standard.string(forKey: "新密码")
//                        }
//                    //}
//                }
//            }
//        }
//    }
                if cell.device.password.isEmpty {
                    Thread.sleep(forTimeInterval: 0.02)
                    //if  (SDK.sharedSDK() as AnyObject).searchsn(sn)==true {
                    let alertPassword = UIAlertController(title: NSLocalizedString("warning", comment: ""), message: NSLocalizedString("EE_ACCOUNT_PASSWORD_IS_EMPTY", comment: ""), preferredStyle: .alert)
                    alertPassword.addTextField(){ txt in
                        let txt = PasswordTextField()
                        txt.placeholder = NSLocalizedString("New_Password", comment: "")
                        txt.imageTintColor = UIColor.red
                        txt.setSecureMode(false)
                    }
                    alertPassword.addTextField(){ txt2 in
                        let txt2 = PasswordTextField()
                        txt2.placeholder = NSLocalizedString("New_Password2", comment: "")
                        txt2.imageTintColor = UIColor.red
                        txt2.setSecureMode(false)
                    }
                    alertPassword.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { action in
                        if let one = alertPassword.textFields![0].text{
                            if let two = alertPassword.textFields![1].text{
                                if one == two {
                                    if !(cell.device.password == one) {
                                        cell.screen.newwPwd = one
                                        Thread.sleep(forTimeInterval: 0.2)

                                        (SDK.sharedSDK() as AnyObject).changePwd(cell.device.sn, opwd: cell.device.password, npwd: one)
//                                        let action = "修改密码"
//                                        let snid = one
//                                        addlog(action:action,snid:snid)
//                                        sleep(2)

                                    }
                                }else{
                                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                                    hud.mode = MBProgressHUDMode.text
                                    hud.label.text = NSLocalizedString("EE_AS_RESET_PWD_CODE4", comment: "")
                                    hud.backgroundView.style = .solidColor
                                    hud.hide(animated: true, afterDelay: 2)
                                }
                            }
                        }else{
                           // Toast.make(context:self.view, msg: "Password can not be empty!").show()
                            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                            hud.mode = MBProgressHUDMode.text
                            hud.label.text = NSLocalizedString("not_support_empty_passowrd", comment: "")
                            hud.backgroundView.style = .solidColor
                            hud.hide(animated: true, afterDelay: 2)
                        }
                     }))

                    alertPassword.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .destructive, handler: { action in

                    }))
                     self.present(alertPassword, animated: true, completion: nil)
                }
                    }}}
    //}

    @objc func onPasswordError(_ notification:Notification){
        if let sn = notification.object as? String  {
            if let cell = cells[sn] {
                if cell.device.password.isEmpty{
                    cell.onStop()
                    
                    if orientation.isPortrait {
                        self.list.isScrollEnabled = true
                    }
                    let alertPassword = UIAlertController(title: NSLocalizedString("Error_Warning", comment: ""), message: NSLocalizedString("EE_DVR_ACCOUNT_PWD_NOT_VALID", comment: ""), preferredStyle: .alert)
//                    alertPassword.addTextFieldWithConfigurationHandler({ (txt: PasswordTextField!) -> Void in
                    alertPassword.addTextField(){ txt in
                        //let txt = PasswordTextField()
                        txt.placeholder = NSLocalizedString("Password", comment: "")//"input your password"
                        //txt.imageTintColor = UIColor.red
                        //txt.setSecureMode(false)
                    } 
                    alertPassword.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { action in
                        for device in self.app.devices {
                            if device.sn == sn {
                                if let pwd = alertPassword.textFields![0].text{
                                    device.password = pwd
                                    cell.screen.load(device.sn, pwd: device.password)
                                    cell.screen.connect()
                                    cell.onPlay()
                                    self.app.onDeviceChange()
                                }
                            }
                        }
                    }))
                    
                    alertPassword.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { action in
                    }))
                    self.present(alertPassword, animated: true, completion: nil)
                }else{
                    cell.device.password = ""
                    cell.screen.load(cell.device.sn, pwd: cell.device.password)
                    app.onDeviceChange()
                    cell.screen.connect()
                }
            }
        }
    }
    
    @objc func onPlayResult(_ notification:Notification){
        if let sn = notification.object as? String {
            if let cell = cells[sn] {
                MBProgressHUD.hide(for: cell.screenContainer, animated: true)
                cell.screen.sound(!cell.soundButton.isSelected)
                cell.screen.autoType();
            }
        }
        if orientation.isPortrait {
            self.list.isScrollEnabled = true
        }
    }
    @objc func onShotResult(_ notification:Notification){
        let success = notification.object as! Bool
        if success {
            //Toast.make(context:self.view, msg: "Please check the photo album").show()
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.label.text = NSLocalizedString("please_check_the_photo_album", comment: "")
            hud.backgroundView.style = .solidColor
            hud.hide(animated: true, afterDelay: 2)
        }else{
            //Toast.make(context:self.view, msg: "Failed").show()
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.label.text = NSLocalizedString("Failed", comment: "")
            hud.backgroundView.style = .solidColor
            hud.hide(animated: true, afterDelay: 2)
        }
    }
    @objc func onRecordResult(_ notification:Notification){
        Main(){
            let success = notification.object as! Bool
            if success {
                //Toast.make(context:self.view, msg: "Please check the photo album").show()
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = MBProgressHUDMode.text
                hud.label.text = NSLocalizedString("please_check_the_photo_album", comment: "")
                hud.backgroundView.style = .solidColor
                hud.hide(animated: true, afterDelay: 2)
            }else{
                //Toast.make(context:self.view, msg: "Failed").show()
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = MBProgressHUDMode.text
                hud.label.text = NSLocalizedString("failed", comment: "")
                hud.backgroundView.style = .solidColor
                hud.hide(animated: true, afterDelay: 2)
            }
        }
    }
    @objc func onSoundDBResult(_ notification:Notification){
        Main(){
            let cell = self.cells[self.app.devices[self.nav_pc.currentPage].sn]
            cell?.voiceProgress.progress(notification.object as! CGFloat)
        }
    }
    
    @objc func onTimer(_ notification:Notification){
        Main(){
            let cell = self.cells[self.app.devices[self.nav_pc.currentPage].sn]
            let time = notification.object as! Double
            if time > 0{
                cell?.updateProgress(time)
            }
        }
    }
    @objc func onEndResult(_ notification:Notification){
        if let sn = (notification.object as? String) {
            if let cell = cells[sn] {
                cell.onStop()
            }
        }
    }
    @objc func onConfigResutl(_ notification:Notification){
        if let cmd = (notification.object as? String){
            if cmd.count == 12 && cmd.first == "B" && cmd.last == "U" {
                let config = cmd.map({String($0)})
                app.select.distance = config[1]
                app.select.hld = config[2]
                app.select.lux = config[3]
                if let mode = LampMode(rawValue: config[4]) {
                    app.select.mode = mode
                }
                app.select.indicator  = config[5]
                app.select.lowlight = config[6]
                app.select.highlight = config[7]
                app.select.lld = config[8]
                //app.select.alarm = AlarmMode(rawValue: config[9])!
                if let level = Level(rawValue: config[10]) {
                    app.select.level = level
                }

                //print("八景\(config[9]))")
//                if config[9] == "b" {
//                    app.select.alarm=AlarmMode(rawValue: "ON")!
//                }else{
//                    if app.select.alarm == .ON {
//                        self.app.select.alarm=AlarmMode(rawValue: "DEFAULT")!
//                    }
//                }
               // print("mode:\(app.select.mode) and \(app.select.alarm)=String(describing: \(String(describing: AlarmMode(rawValue: config[9]))))")

                app.onDeviceChange()
                let cell = self.cells[app.select.sn]
                cell?.lastSyncTime = Date().timeIntervalSince1970
                cell?.refreshStatus()
                onSelectItemChange()
            }
        }
    }
    
    @objc func onConnecting(_ notification:Notification){
        if let sn = notification.object as? String {
            if let cell = cells[sn] {
                MBProgressHUD.hide(for: cell.screenContainer, animated: true)
                let hud = MBProgressHUD.showAdded(to: cell.screenContainer, animated: true)
                hud.label.text = NSLocalizedString("connect", comment: "")
                hud.mode = .indeterminate
                hud.hide(animated: true, afterDelay: 2)
            }
        }
    }
    
    @objc func onSearching(_ notification:Notification){
        if let sn = notification.object as? String {
            if let cell = cells[sn] {
                MBProgressHUD.hide(for: cell.screenContainer, animated: true)
                let hud = MBProgressHUD.showAdded(to: cell.screenContainer, animated: true)
                hud.label.text = NSLocalizedString("Searching", comment: "")
                hud.mode = .indeterminate
                hud.hide(animated: true, afterDelay: 2)
            }
        }
    }
    
    @objc func onCacheResult(_ notification:Notification){
        if let sn = notification.object as? String {
            if let cell = cells[sn] {
                MBProgressHUD.hide(for: cell.screenContainer, animated: true)
                let hud = MBProgressHUD.showAdded(to: cell.screenContainer, animated: true)
                hud.label.text = NSLocalizedString("Buffering", comment: "")
                hud.mode = .indeterminate
                //hud.hide(animated: true, afterDelay: 2)
                print("Buffering")
            }
        }
    }
    @objc func onOfflineResult(_ notification:Notification){
        if let sn = notification.object as? String {
            if let cell = cells[sn] {
                cell.onStop()
                cell.screen.disconnect()
                self.list.isScrollEnabled = true
                cell.liveLabel.text=NSLocalizedString("Offline", comment: "")
                MBProgressHUD.hide(for: cell.screenContainer, animated: true)
                let hud = MBProgressHUD.showAdded(to: cell.screenContainer, animated: true)
                hud.label.text = NSLocalizedString("Offline", comment: "")
                hud.mode = .indeterminate
                Thread.sleep(forTimeInterval: 0.02)
                let action = "连灯状态"
                let snid = "Offline"
                addlog(action:action,snid:snid)
                
//                let hud = MBProgressHUD.showAdded(to: cell.screenContainer, animated: true)
//                hud.label.text = NSLocalizedString("Offline", comment: "")
//                hud.mode = .text
//                hud.label.textColor = UIColor.init(hex: 0x770B2F)
//                //hud.hide(true, afterDelay: 2)
//                hud.hide(animated: true, afterDelay: 2)
            }
        }
    }
    
    @objc func onDisconnect(_ notification:Notification){
        if let sn = notification.object as? String{
            if let cell = self.cells[sn] {
                cell.onStop()
                
                let hud = MBProgressHUD.showAdded(to: cell.screenContainer, animated: true)
                hud.label.text = NSLocalizedString("disconnect", comment: "")
                hud.mode = .text
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
                let action = "连灯状态"
                let snid = "disconnect"
                addlog(action:action,snid:snid)
            }
        }
    }
    @objc func onMCLinkResult(_ notification:Notification){

    }
    func onDevupdateResult(_ notification:Notification){
        
    }
    @objc func onTimeOut(_ notification:Notification){
        if let sn = notification.object as? String {
            if let cell = cells[sn] {
                cell.onStop()
                cell.screen.disconnect()
                self.list.isScrollEnabled = true
                let hud = MBProgressHUD.showAdded(to: cell.screenContainer, animated: true)
                hud.label.text = NSLocalizedString("EE_DVR_SDK_TIMEOUT", comment: "")
                hud.mode = .text
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
                let action = "连灯状态"
                let snid = "TimeOut"
                addlog(action:action,snid:snid)
            }
        }
    }
    @objc func onUerLocked(_ notification:Notification){
        if let sn = notification.object as? String {
            if let cell = cells[sn] {
                cell.onStop()
                cell.screen.disconnect()
                self.list.isScrollEnabled = true
                let hud = MBProgressHUD.showAdded(to: cell.screenContainer, animated: true)
                hud.label.text = NSLocalizedString("EE_DVR_USER_LOCKED", comment: "")
                hud.mode = .text
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
                let action = "连灯状态"
                let snid = "UserLocked"
                addlog(action:action,snid:snid)
            }
        }
    }
    @objc func onDSS(_ notification:Notification){
        let action = "连接方式"
        let snid = "DSS"
        addlog(action:action,snid:snid)
        
    }
    @objc func onRPS(_ notification:Notification){
        let action = "连接"
        let snid = "RPS"
        addlog(action:action,snid:snid)
    }
    @objc func onFindResult(_ notification:Notification){
        if let sn = notification.object as? String {
            if let cell = cells[sn] {
                //cell.screen.stop()
                //cell.onStop()
                cell.refresh(true)
            }
        }
    }
}

