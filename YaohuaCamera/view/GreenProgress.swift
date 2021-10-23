//
//  GreenProgress.swift
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.

import UIKit
//@IBDesignable//编辑状态下注释上面一行，否则MainViewCell.xib会报错，尽管不影响侧测试，但是影响修改xib，安装盘会失败.
class GreenProgress: UIView {
    var timer:Timer!
    var progress:CGFloat = 0
    var top = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func drawRect() -> CGRect {
         return CGRect(x: 0 + 2, y: 0 - 1, width: self.bounds.width - 2 , height: self.bounds.height)
    }
    func startAnim(){
        timer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(self.anim), userInfo: nil, repeats: true)
        timer.fire()
    }
    func stopAnim(){
        timer?.invalidate()
        progress = 0.0
        self.setNeedsDisplay()
    }
    
    @objc func anim(){
        if top {
            progress += 0.0125  + 0.0002 * (progress / 0.0125)
            self.setNeedsDisplay()
            if progress >= 1 {
                top = false
            }
        }else{
            progress -= 0.0125 + 0.0002 * (progress / 0.0125)
            self.setNeedsDisplay()
            if progress <= 0 {
                top = true
            }
        }
    }
    
    func progress(_ db:CGFloat){
        if db == 120 {
            self.progress = 0
            self.setNeedsDisplay()
        } else {
            UIView.animate(withDuration: 0.15, animations: {
                self.progress = db / 60
                self.setNeedsDisplay()
            })
        }
    }
    fileprivate func extractedFunc() -> CGColorSpace {
        return CGColorSpaceCreateDeviceRGB()
    }
    
    override func draw(_ rect: CGRect) {
      
        let drawRect = self.drawRect()
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        let colorSpace = extractedFunc()
        let components: [CGFloat] = [ 255 / 255,128 / 255,0 / 255, 0,  255 / 255,128 / 255,0 / 255,0.9 ]//橙色设置
        //        [180 / 255, 236 / 255, 81 / 255, 0, 66 / 255, 147 / 255, 33 / 255,0.8]
        let locations: [CGFloat] = [0.0,1.0]//[0.0,1.0]
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        //限制绘制区域为圆
        UIBezierPath(roundedRect: drawRect, cornerRadius: drawRect.width / 1.5).addClip()
        //限制绘制区域的高度
        UIBezierPath(rect: CGRect(x: 0, y: self.bounds.height * (1-progress), width: self.bounds.width, height: self.bounds.height * progress)).addClip()
        let startPoint = CGPoint(x: self.bounds.width / 2, y: 0)
        let endPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.height)
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions.drawsAfterEndLocation)
        /*绘制线性渐变
         gradient:渐变色
         startPoint:起始位置
         endPoint:终止位置
         options:绘制方式,kCGGradientDrawsBeforeStartLocation 开始位置之前就进行绘制，到结束位置之后不再绘制，
         kCGGradientDrawsAfterEndLocation开始位置之前不进行绘制，到结束点之后继续填充
         */

        
        context?.restoreGState()
        
    }
    
    
}


