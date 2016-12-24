//
//  MarqueeView.swift
//  FindMeChat
//
//  Created by Liuming Qiu on 2016/12/24.
//  Copyright © 2016年 ZW. All rights reserved.
//

import UIKit
import Masonry

class MarqueeView: UIView {

    
    private var labels:[UILabel]!
    private weak var timer:Timer!
    private var beginContraint:MASConstraint!
    
    
    @IBInspectable
    var duration:Double = 6
    @IBInspectable
    var textColor:UIColor = grayColor
    @IBInspectable 
    var font:UIFont = UIFont.boldSystemFont(ofSize: 15)
    
    @IBInspectable
    var text:String!{
        didSet{
            setupLabels(withTexts: text)
        }
    }
    
    init(frame: CGRect,text:String) {
        self.text = text
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print(#function)
    }
    
    // MARK: - UI 处理
    /// 设置显示内容
    ///
    /// - Parameter text: 内容
    func setupLabels(withTexts text:String){
        if labels != nil && !labels.isEmpty{
            labels.forEach(){
                $0.removeFromSuperview()
            }
        }
        
        labels = (0 ..< 2).flatMap(){ _ in
            let label = UILabel()
            label.text = text
            label.textColor = textColor
            label.font = font
            label.sizeToFit()
            self.addSubview(label)
            return label
        }        
    }

    
    var i = 0
    
    @objc private func run(){
        guard labels != nil && !labels.isEmpty else {
            return
        }
        self.beginContraint?.setOffset(0)
        self.layoutIfNeeded()
        
        self.beginContraint?.setOffset(-self.labels.first!.frame.width)
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    /// timer
    func startRunning(){
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(MarqueeView.run), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
            timer.fire()
        }
    }
    func stopRunning(){
        if timer != nil && timer.isValid{
            timer.invalidate()
        }
    }

    
    
    
    
    /// contraints
    open override class var requiresConstraintBasedLayout:Bool{
        return true
    }
    
    override func updateConstraints() {
        if labels != nil && labels.count == 2{
            let label0 = labels.first!
            let label1 = labels.last!
            
            label0.mas_remakeConstraints(){
                self.beginContraint = $0!.leading.equalTo()(self)
                _ = $0?.centerY.equalTo()(self)
                _ = $0?.width.greaterThanOrEqualTo()(self.mas_width)
                
            }
            label1.mas_remakeConstraints(){
                _ = $0?.leading.equalTo()(label0.mas_trailing)
                _ = $0?.centerY.equalTo()(self.mas_centerY)
                _ = $0?.width.equalTo()(label0)
            }
        }
        
        super.updateConstraints()
    }
    
}























