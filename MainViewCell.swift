//
//  MainViewCell.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//


import UIKit

let SH = (ScreenHeight-64) * 225/603
let SW = ScreenWidth * 359/375
import MBProgressHUD

class MainViewCell: UICollectionViewCell ,TimeSelectionBarDelegate,TimeSelectCollectonDelegate,UIActionSheetDelegate {
    @IBOutlet weak var voiceProgress: GreenProgress!
    @IBOutlet weak var screen: DisplayView!
    @IBOutlet weak var screenContainer: UIView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var timeline: UIView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var progressBar: ProgressView!
    @IBOutlet weak var width_progressBar: NSLayoutConstraint!
    
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var progressX: NSLayoutConstraint!
    var delegate:MainViewCellDelegate?
    var playButton:UIButton!
    var progressLandScape:ProgressView?
    var indicatorLandScape:UIImageView?
    var timeSelectionBar:TimeSelectionBar?
    var timeSelectCollectonView:TimeSelectCollectonView?
    //    var speedButton:UIButton?
    
    
    @IBOutlet weak var alarmButton: UIImageView!
    @IBOutlet weak var alarmButtonX: NSLayoutConstraint!
    @IBOutlet weak var alarmSettingView: UIView!
    
    @IBOutlet weak var lampButton: UIImageView!
    @IBOutlet weak var lampButtonX: NSLayoutConstraint!
    @IBOutlet weak var lampSettingView: UIView!
    @IBOutlet weak var holdToTalk: UILabel!
    var app:AppDelegate!
    let playButtonWidth:CGFloat = iPad ? 96:72
    var onTalk = false;
    var timerDelay:Task?
    
    
    @IBAction func onTalkDown(_ sender: UIButton) {
        timerDelay = delay(0.5){
            self.screen.talk(true)
            self.screen.sound(false)
        }
        if !self.soundButton.isSelected {
            self.soundButton.isSelected = true
            self.soundChange = true
        }
        holdToTalk.text = "RELEASE TO LISTEN"
        onTalk = true;
    }
    
    var lastSyncTime:TimeInterval = 0
    var soundChange = false
    @IBAction func onTalkUp(_ sender: UIButton) {
        timerDelay?(true)
        screen.talk(false)
        holdToTalk.text = "HOLD TO TALK"
        if soundChange {
            self.soundButton.isSelected = false
            screen.sound(true)
            self.soundChange = false
        }
        onTalk = false;
    }
    
    var endTime:DateComponents?
    var startTime:DateComponents?
    var calendar:Calendar!
    
    
    // 添加所有的手势
    func addGestureRecognizerToView(_ view:UIView){
        // 旋转手势
        //        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateView:")
        //        view.addGestureRecognizer(rotationGestureRecognizer)
        // 缩放手势
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(MainViewCell.pinchView(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
        //        let longPress = UILongPressGestureRecognizer(target: self, action: "longPress:")
        //        longPress.minimumPressDuration = 1
        //        view.addGestureRecognizer(longPress)
        let  panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewCell.panView(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MainViewCell.doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
    }
    
    
    //    func longPress(longPress:UILongPressGestureRecognizer){
    //        if panGestureRecognizer == nil{
    //            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panView:")
    //        }
    //        self.screenContainer.layer.borderColor = UIColor.redColor().CGColor
    //        if let view = longPress.view{
    //            view.addGestureRecognizer(panGestureRecognizer)
    //        }
    //    }
    
    func removeGestureRecognizerFromView(_ view:UIView) {
        if let arr = view.gestureRecognizers {
            for item in arr {
                view.removeGestureRecognizer(item)
            }
        }
    }
    
    // 处理旋转手势
    func rotateView(_ rotationGestureRecognizer:UIRotationGestureRecognizer){
        if let view = rotationGestureRecognizer.view{
            if (rotationGestureRecognizer.state == UIGestureRecognizerState.began || rotationGestureRecognizer.state == UIGestureRecognizerState.changed) {
                view.transform = view.transform.rotated(by: rotationGestureRecognizer.rotation);
                rotationGestureRecognizer.rotation = 0
            }
        }
    }
    
    //双击
    func doubleTap(_ doubleTap:UIRotationGestureRecognizer){
        if let view = doubleTap.view{
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            self.screenContainer.layer.borderColor = UIColor.black.cgColor
            
            view.center = CGPoint(x: view.center.x - moveX,y: view.center.y - moveY)
            moveX = 0
            moveY = 0
        }
    }
    
    // 处理缩放手势
    func pinchView(_ pinchGestureRecognizer:UIPinchGestureRecognizer){
        if let view = pinchGestureRecognizer.view{
            if (pinchGestureRecognizer.state == UIGestureRecognizerState.began || pinchGestureRecognizer.state == UIGestureRecognizerState.changed) {
                let transform = view.transform.scaledBy(x: pinchGestureRecognizer.scale, y: pinchGestureRecognizer.scale)
                if transform.a > 1 && transform.a < 4 {
                    view.transform = transform
                }
                pinchGestureRecognizer.scale = 1;
                
            }
        }
    }
    var moveX:CGFloat = 0
    var moveY:CGFloat = 0
    // 处理拖拉手势
    func panView(_ panGestureRecognizer:UIPanGestureRecognizer){
        if panGestureRecognizer.state == UIGestureRecognizerState.ended{
            //            self.screenContainer.layer.borderColor = UIColor.blackColor().CGColor
            //            panGestureRecognizer.view?.removeGestureRecognizer(panGestureRecognizer)
        }else{
            if let view = panGestureRecognizer.view{
                if (panGestureRecognizer.state == UIGestureRecognizerState.began || panGestureRecognizer.state == UIGestureRecognizerState.changed) {
                    let translation = panGestureRecognizer.translation(in: view.superview)
                    
                    moveX = moveX + translation.x
                    moveY = moveY + translation.y
                    view.center = CGPoint(x: view.center.x + translation.x,y: view.center.y + translation.y)
                    
                    
                    panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
                }
            }
        }
        
    }
    
    @IBAction func onSwitchClick(_ sender: UIButton) {
        delegate?.onSwitchButtonClick(self)
        
        sender.isSelected = !sender.isSelected
        
        
        if sender.isSelected {
            self.progressContainer.isHidden = false
            self.timeSelectionBar?.isHidden = false
            self.liveLabel.isHidden = true
            //            self.speedButton?.hidden = false
            
            endTime = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: Date())
            endTime?.hour = 23;
            endTime?.minute = 59;
            endTime?.second = 59;
            
            startTime = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: Date())
            startTime?.hour = 0;
            startTime?.minute = 0;
            startTime?.second = 0;
            refresh()
            
            self.screen.search(startTime, end: endTime)
            
            
            self.progressX.constant = 0
        }else{
            self.progressContainer.isHidden = true
            self.timeSelectionBar?.isHidden = true
            //            self.speedButton?.hidden = true
            self.liveLabel.isHidden = false
        }
        
        
        
    }
    func refresh(_ autoStart:Bool = false){
        
        self.progressBar.reset(self.startTime!, end: self.endTime!, files: self.screen.timeArray)
        self.progressLandScape?.reset(self.startTime!, end: self.endTime!, files: self.screen.timeArray)
        
        if let arr = self.screen.timeArray {
            if  arr.count == 0 {
                self.progressX.constant = 0
                MBProgressHUD.hide(for: self.screenContainer, animated: false)
                let hud = MBProgressHUD.showAdded(to: self.screenContainer, animated: true)
                hud.label.text = "No video"
                hud.mode = .text
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
            }else{
                let start = arr.lastObject as! FileData
                
                updateProgress((self.progressBar.startlong + TimeInterval(start.stBeginTime))*1000)
                if autoStart {
                    self.delegate?.onTouchup(self,progress: currentProgress())
                }
                
            }
        }
    }
    func  currentProgress() -> CGFloat {
        return -self.progressX.constant/self.progressBar.bounds.width
    }
    
    @IBAction func onScreenShotClick(_ sender: UIButton) {
        self.screen.shot()
    }
    @IBAction func onSoundClick(_ sender: UIButton) {
        screen.sound(sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    func refreshStatus(){
        
        switch device.alarm {
        case .DEFAULT: alarmButtonX.constant = 0
        case .ON: alarmButtonX.constant = ScreenWidth * 0.17
        case .OFF: alarmButtonX.constant = -ScreenWidth * 0.17
        }
        
        switch device.mode {
        case .AlwaysOn: lampButtonX.constant =  ScreenWidth * 0.17
        case .Sensor: lampButtonX.constant =  0
        case .Test:   lampButtonX.constant = -ScreenWidth * 0.17
        case .D2D :break
        }
    }
    @IBAction func onRecordClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        screen.record(sender.isSelected)
    }
    var device: Device!
    func load(_ device:Device){
        self.device = device
        self.app = UIApplication.shared.delegate as! AppDelegate
        
        if self.playButton == nil{
            timeFormat.dateFormat = "HH:mm"
            calendar = Calendar.current
            self.screen.load(device.sn,pwd: device.password)
            self.screenContainer.clipsToBounds = true
            self.timeline.clipsToBounds = true
            self.playButton = UIButton()
            self.playButton.alpha = 0.6
            self.playButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainViewCell.onPlayButtonClick)))
            self.playButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
            self.playButton.setImage(UIImage(named: "play"), for: UIControlState())
            self.playButton.setImage(UIImage(named: "pause"), for: .selected)
            self.screenContainer.addSubview(playButton)
            self.screenContainer.bounds = CGRect(x: 0, y: 0, width: SW, height: SH)
            self.playButton.frame = CGRect(x: (self.screenContainer.bounds.width - playButtonWidth)/2,y: self.screenContainer.bounds.height/2 - playButtonWidth/2,width: playButtonWidth,height: playButtonWidth)
            
            self.alarmSettingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainViewCell.handelAlarmSettingTap(_:))))
            self.lampSettingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MainViewCell.handelLampSettingTap(_:))))
            self.alarmSettingView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(MainViewCell.handelAlarmSettingPan(_:))))
            self.lampSettingView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(MainViewCell.handelLampSettingPan(_:))))
            self.progressBar.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(MainViewCell.onProgressPan(_:))))
            //            self.speedButton = UIButton()
            //            self.speedButton?.frame = CGRectMake(self.screenContainer.bounds.width - 54 ,self.screenContainer.bounds.height - 54,54,54)
            //            self.speedButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onSpeedClick"))
            //            self.speedButton?.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
            //            self.speedButton?.backgroundColor = UIColor.init(hex: 0x000000,alpha:0.5)
            //            self.speedButton?.setImage(UIImage(named: "transparent"), forState: .Normal)
            //            self.speedButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            //            self.speedButton?.setTitle("x1", forState: .Normal)
            //            self.screenContainer.addSubview(speedButton!)
            //            self.speedButton?.hidden = true
            //            screen.connect(device.password)
            
            if timeSelectionBar == nil {
                timeSelectionBar = (Bundle.main.loadNibNamed("TimeSelectionBar", owner: self, options: nil)! as NSArray).lastObject as? TimeSelectionBar
                timeSelectionBar?.initView(CGRect(x: 0, y: screenContainer.frame.height - 36, width: screenContainer.frame.width, height: 36))
                timeSelectionBar?.currentTime = Date().timeIntervalSince1970
                timeSelectionBar?.delegate = self
                self.screenContainer.addSubview(timeSelectionBar!)
                timeSelectionBar?.isHidden = true
            }
            if timeSelectCollectonView == nil {
                timeSelectCollectonView = (Bundle.main.loadNibNamed("TimeSelectCollectonView", owner: self, options: nil)! as NSArray).lastObject as? TimeSelectCollectonView
                timeSelectCollectonView?.initView(CGRect(x: 0, y: self.screenContainer.frame.maxY + 5, width: self.frame.width, height: self.frame.height - self.screenContainer.frame.maxY - 5))
                timeSelectCollectonView?.delegate = self
            }
        }
        
        //初始化Progressbar
        progressBar.time_scale = .fifteenMins
        width_progressBar.constant = CGFloat(FifteenMinsTotalWidth)
        progressBar.layoutIfNeeded()
        
        refreshStatus()
    }
    
    // MARK: - TimeSelectionBarDelegate
    func didTapNextClick(_ nextTime: TimeInterval) {
        
    }
    func didTapPreviousNextClick(_ previousTime: TimeInterval) {
        
    }
    //    var speed:Int32 = 0
    //    func onSpeedClick(){
    //        //1、2、4、8  0~3
    //        if speed < 2 {
    //            speed++
    //        }else {
    //            speed = 0
    //        }
    //        Async(){
    //            self.screen.speed(self.speed)
    //        }
    //
    //        var str:String!
    //
    //        switch self.speed {
    //        case 0:str = "x1"
    //        case 1:str = "x2"
    //        case 2:str = "x4"
    //        default:break
    //        }
    //        self.speedButton?.setTitle(str, forState: .Normal)
    //
    //    }
    func didTaptimeSwitchClick() {
        if  let data =  screen.dateArray {
            self.timeSelectCollectonView?.reload(data.flatMap({($0 as AnyObject).doubleValue}))
        }
    
        timeSelectCollectonView?.showTimeSelectionCollectionView(self.window!, targetframe: CGRect(x: 0, y: self.screenContainer.frame.maxY + 5 + 64, width: self.frame.width, height: self.frame.height - self.screenContainer.frame.maxY - 5 - 64))
        
    }
    func didTaptimeScaleClick() {
        
        let percent = currentProgress()
        
        switch progressBar.time_scale {
        case .fifteenMins:
            progressBar.time_scale = .halfFifteenMins
            width_progressBar.constant = CGFloat(HalfFifteenMinsTotalWidth)
        case .halfFifteenMins:
            progressBar.time_scale = .halfFiveMins
            width_progressBar.constant = CGFloat(HalfFiveMinsTotalWidth)
        case .halfFiveMins:
            progressBar.time_scale = .fifteenMins
            width_progressBar.constant = CGFloat(FifteenMinsTotalWidth)
        }
        progressBar.layoutIfNeeded()
        progressBar.setNeedsDisplay()
        
        self.progressX.constant = CGFloat(-width_progressBar.constant * percent)
    }
    // MARK: - TimeSelectCollectonDelegate
    func didChooseOneTime(_ time: TimeInterval) {
        screen.stop()
        onStop()
        endTime = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: Date(timeIntervalSince1970: time))
        endTime?.hour = 23;
        endTime?.minute = 59;
        endTime?.second = 59;
        
        startTime = calendar.dateComponents(in: TimeZone.autoupdatingCurrent, from: Date(timeIntervalSince1970: time))
        startTime?.hour = 0;
        startTime?.minute = 0;
        startTime?.second = 0;
        timeSelectionBar?.currentTime = time
        refresh()
        self.screen.search(startTime, end: endTime)
    }
    
    
    func resetPlayButtonStatus(){
        if screen.isPlaying() {
            onPlay()
        }else{
            onStop()
        }
    }
    
    func onPlay(){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.playButton.isSelected = true
            self.playButton.frame = CGRect(x: 0,y: self.screenContainer.bounds.height - self.playButtonWidth, width: self.playButtonWidth, height: self.playButtonWidth)
        })
    }
    
    func onStop(){
        MBProgressHUD.hide(for: self.screenContainer, animated: true)
        UIView.animate(withDuration: 0.3, animations: {
            self.playButton.isSelected = false
            self.playButton.frame = CGRect(x: self.screenContainer.bounds.width/2 - self.playButtonWidth/2,y: self.screenContainer.bounds.height/2 - self.playButtonWidth/2,width: self.playButtonWidth,height: self.playButtonWidth)
        })
    }
    
    func onPlayButtonClick(){
        delegate?.onPlayButtonClick(self)
    }
    
    var xDown:CGFloat = 0
    var xBefore:CGFloat = 0
    var onTouch = false;
    var notice:MBProgressHUD?
    let timeFormat = DateFormatter()
    //拖动手势。。
    func onProgressPan(_ panGestureRecognizer :UIPanGestureRecognizer){
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm:ss"
        switch panGestureRecognizer.state {
        case .began:
            onTouch = true;
            xDown = panGestureRecognizer.location(in: self.progressContainer).x
            xBefore = self.progressX.constant
            notice = MBProgressHUD.showAdded(to: self.screen, animated: true)
            notice?.mode = .text
            notice?.label.textColor = UIColor.white
            playButton.isHidden = true
            notice?.label.text = timeFormat.string(from: Date(timeIntervalSince1970: self.progressBar.timelong * Double(currentProgress()) + Double(self.progressBar.startlong)))
        case .changed :
            //禁止超滑
            let offset_x = xBefore + panGestureRecognizer.location(in: self.progressContainer).x - xDown
            if offset_x > 1 || offset_x < -(width_progressBar.constant + 1) {
                return;
            }
            
            self.progressX.constant = CGFloat(offset_x)
            notice?.label.text = timeFormat.string(from: Date(timeIntervalSince1970: self.progressBar.timelong * Double(currentProgress()) + Double(self.progressBar.startlong)))
        case .ended,.cancelled,.failed:
            playButton.isHidden = false
            print("\(currentProgress())")
            notice?.hide(animated: true, afterDelay: 0)
            onTouch = false
            self.delegate?.onTouchup(self,progress: currentProgress())
        default:break
        }
        
    }
    
    func onLandScapeProgressPan(_ panGestureRecognizer :UIPanGestureRecognizer){
        if let view = panGestureRecognizer.view{
            if panGestureRecognizer.state == UIGestureRecognizerState.began{
                view.alpha = 1
                self.indicatorLandScape?.alpha = 1
                onTouch = true
                notice = MBProgressHUD.showAdded(to: self.screen, animated: true)
                notice?.mode = .text
                notice?.label.textColor = UIColor.white
                playButton.isHidden = true
                
            }else if panGestureRecognizer.state == UIGestureRecognizerState.ended || panGestureRecognizer.state == UIGestureRecognizerState.failed || panGestureRecognizer.state == UIGestureRecognizerState.cancelled{
                notice?.hide(animated: true, afterDelay: 0)
                view.alpha = 0.2
                playButton.isHidden = false
                self.indicatorLandScape?.alpha = 0.2
                onTouch = false
                self.delegate?.onTouchup(self, progress: (2*ScreenHeight - view.center.x) / (3*ScreenHeight))
            }
            
            if (panGestureRecognizer.state == UIGestureRecognizerState.began || panGestureRecognizer.state == UIGestureRecognizerState.changed) {
                
                
                
                let translation = panGestureRecognizer.translation(in: view.superview)
                
                
                view.center = CGPoint(x: view.center.x + translation.x,y: view.center.y)
                
                
                panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
                
                let progress =  (2*ScreenHeight - view.center.x) / (3*ScreenHeight)
                
                notice?.label.text = timeFormat.string(from: Date(timeIntervalSince1970: self.progressBar.timelong * Double(progress) + Double(self.progressBar.startlong)))
            }
        }
        
        
    }
    //更新进度条
    func updateProgress(_ current:TimeInterval){
        
        let progress_width = self.width_progressBar.constant;
        
        if !onTouch {
            self.progressX.constant = -CGFloat((current/1000.0 - self.progressBar.startlong) / self.progressBar.timelong) * progress_width
            if self.progressLandScape != nil{
                self.progressLandScape?.center.x = 2*ScreenHeight +  -CGFloat((current/1000.0 - self.progressBar.startlong) / self.progressBar.timelong) * (3*ScreenHeight)
            }
        }
    }
    // MARK: - UITapGestureRecognizer Action
    func handelAlarmSettingTap(_ tapGestureRecognizer:UITapGestureRecognizer)
    {
        let point = tapGestureRecognizer.location(in: self.alarmSettingView)
        switch checkStatus(point.x){
        case 0: alarmButtonX.constant = -ScreenWidth * 0.17
        handleAlarmChange(.OFF)
        case 1: alarmButtonX.constant = 0
        handleAlarmChange(.DEFAULT)
            
        case 2: alarmButtonX.constant = ScreenWidth * 0.17
        handleAlarmChange(.ON)
        default: break
        }
        alarmButton.layoutIfNeeded()
    }
    // MARK: - UITapGestureRecognizer Action
    func handelAlarmSettingPan(_ pan:UIPanGestureRecognizer)
    {
        
        let point = pan.location(in: self.alarmSettingView)
        switch pan.state {
        case .began:
            break
        case .changed:
            if point.x >= ScreenWidth/2 * 0.16 && point.x <= ScreenWidth/2 * 0.84{
                alarmButtonX.constant = point.x - (ScreenWidth * 0.25)
            }
        case .ended,.failed,.cancelled:
            switch checkStatus(point.x) {
            case 0: alarmButtonX.constant = -ScreenWidth * 0.17
            handleAlarmChange(.OFF)
            case 1: alarmButtonX.constant = 0
            handleAlarmChange(.DEFAULT)
            case 2: alarmButtonX.constant = ScreenWidth * 0.17
            handleAlarmChange(.ON)
            default: break
            }
        default:break
        }
        
        alarmButton.layoutIfNeeded()
    }
    
    
    func checkStatus(_ x:CGFloat) -> Int{
        if x < ScreenWidth/8{
            return 0
        }else if x < ScreenWidth/4 + ScreenWidth/8{
            return 1
        }else {
            return 2
        }
    }
    
    
    func handelLampSettingTap(_ tapGestureRecognizer :UITapGestureRecognizer)
    {
        let point = tapGestureRecognizer.location(in: self.lampSettingView)
        
        
        
        switch checkStatus(point.x) {
        case 0:
            lampButtonX.constant = -ScreenWidth * 0.17
            
            handleModeChange(.Test)
        case 1:
            lampButtonX.constant =  0
            
            handleModeChange(.Sensor)
        case 2:
            lampButtonX.constant =  ScreenWidth * 0.17
            handleModeChange(.AlwaysOn)
        default: break
        }
        lampButton.layoutIfNeeded()
    }
    
    func handelLampSettingPan(_ pan:UIPanGestureRecognizer){
        let point = pan.location(in: self.lampSettingView)
        switch pan.state {
        case .began:
            break
        case .changed:
            if point.x >= ScreenWidth/2 * 0.16 && point.x <= ScreenWidth/2 * 0.84{
                lampButtonX.constant = point.x - (ScreenWidth * 0.25)
            }
        case .ended,.failed,.cancelled:
            switch checkStatus(point.x) {
            case 0:
                lampButtonX.constant = -ScreenWidth * 0.17
                handleModeChange(.Test)
            case 1:
                lampButtonX.constant =  0
                
                handleModeChange(.Sensor)
            case 2:
                lampButtonX.constant =  ScreenWidth * 0.17
                handleModeChange(.AlwaysOn)
            default: break
            }
        default:break
        }
        
        lampButton.layoutIfNeeded()
    }
    
    func handleModeChange(_ mode:LampMode){
        if mode == .Sensor {
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.SLevel(device.level).str, dev: device.sn)
        }else{
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.SMode(mode).str, dev: device.sn)
        }
        self.device.mode = mode
        app.onDeviceChange()
    }
    func handleAlarmChange(_ alarm:AlarmMode){
        self.device.alarm = alarm
        let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Alarm(alarm == .ON).str, dev: device.sn)
        let _ = (SDK.sharedSDK() as AnyObject).setAlarm(alarm == .DEFAULT || alarm == .ON, sn: self.device.sn,name: self.device.name)
        let _ = (SDK.sharedSDK() as AnyObject).beep(self.device.sn,on: alarm == .ON)
        app.onDeviceChange()
    }
}
protocol MainViewCellDelegate{
    func onPlayButtonClick(_ cell:MainViewCell)
    func onTouchup(_ cell:MainViewCell,progress:CGFloat)
    func onSwitchButtonClick(_ cell:MainViewCell)
}
