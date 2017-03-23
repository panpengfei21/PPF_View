//
//  CarouselTimer.swift
//  CollectionV
//
//  Created by Liuming Qiu on 2017/3/23.
//  Copyright © 2017年 ZW. All rights reserved.
//

import UIKit

protocol Nextable:class {
    func next();
}

class CarouselTimer: NSObject {
    
    /// 时间间隔
    let timeInterval:Double
    /// 对像
    weak var next:Nextable?
    /// 计时器
    weak var timer:Timer?
    
    override init() {
        timeInterval = 1
        super.init()
        
    }
    init(timeInterval:Double) {
        self.timeInterval = timeInterval
        super.init()
    }
    
    
    /// 运行代码块
    ///
    /// - Parameter timer: 计时器
    func run(timer:Timer){
        next?.next()
    }
    
    /// 开始
    public func start(){
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(CarouselTimer.run(timer:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
        }
    }
    /// 停止
    func stop(){
        guard let t = timer else {
            return
        }
        if t.isValid{
            t.invalidate()
        }
    }
    
    /// 暂停
    func pause(){
        timer?.fireDate = Date.distantFuture
    }
    
    /// 恢复
    func resume(){
        timer?.fireDate = Date(timeIntervalSinceNow: timeInterval)
    }
}
