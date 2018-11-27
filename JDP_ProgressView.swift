//
//  JDP_ProgressView.swift
//  JDPHouseDemolitionManagement
//
//  Created by 潘鹏飞 on 2018/11/26.
//  Copyright © 2018 健德普. All rights reserved.
//

import UIKit

/// 进度条
class JDP_ProgressView: UIView {
    /// 轨道
    var trackLayer:CAShapeLayer!
    
    /// 渐变层
    var gradientLayer:CAGradientLayer!
    /// 渐变蒙版
    var gradientMaskLayer:CAShapeLayer!
    
    /// bar的高度
    var barHeight:CGFloat = 6
    /// 比例
    var rate:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initializeUI() {
        print(#function)
        trackLayer = {
            let l = CAShapeLayer()
            l.lineCap = CAShapeLayerLineCap.round
            self.layer.addSublayer(l)
            return l
        }()
        
        gradientLayer = {
            let l = CAGradientLayer()
            l.colors = [UIColor.gray.cgColor,UIColor.blue.cgColor]
            l.locations = [0,1]
            l.startPoint = CGPoint(x: 0, y: 0.5)
            l.endPoint = CGPoint(x: 1, y: 0.5)
            l.masksToBounds = true
            self.layer.addSublayer(l)
            return l
        }()
        
        gradientMaskLayer = {
            let l = CAShapeLayer()
            l.strokeColor = UIColor.white.cgColor
            l.lineCap = CAShapeLayerLineCap.round
            gradientLayer.mask = l
            return l
        }()
        
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let orginX = barHeight / 2
        let orginY = rect.height / 2
        
        let path0:UIBezierPath = {
            let p = UIBezierPath()
            
            p.move(to: CGPoint(x: orginX, y: orginY))
            p.addLine(to: CGPoint(x: rect.width - orginX, y: orginY))
            
            return p
        }()
        trackLayer.lineWidth = barHeight
        trackLayer.path = path0.cgPath
        trackLayer.displayIfNeeded()
        
        let path1:UIBezierPath = {
            let p = UIBezierPath()
            
            let width = (rect.width - barHeight) * rate
            
            p.move(to: CGPoint(x: orginX, y: orginY))
            p.addLine(to: CGPoint(x: orginX + width, y: orginY))
            
            return p
        }()
        gradientMaskLayer.lineWidth = barHeight
        gradientMaskLayer.path = path1.cgPath
        trackLayer.displayIfNeeded()
        
        self.gradientLayer.frame = rect
    }
    
    /// 设置比例,0.0~1.0
    func setNumber(_ number:CGFloat) {
        self.rate = number
        setNeedsDisplay()
    }
    
    /// 设置前景色,及位置
    func setColors(_ colors:[UIColor],locations:[NSNumber]){
        guard colors.count == locations.count else{
            fatalError()
        }
        gradientLayer.colors = colors.compactMap(){ $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.displayIfNeeded()
    }
    /// 设置轨道颜色
    func setTrack(color:UIColor){
        trackLayer.strokeColor = color.cgColor
    }
    /// 设置
    func setBarHeight(_ height:CGFloat) {
        self.barHeight = height
        gradientLayer.displayIfNeeded()
        trackLayer.displayIfNeeded()
    }
}
