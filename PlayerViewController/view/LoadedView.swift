 //
//  LoadedView.swift
//  ZhangShi
//
//  Created by Liuming Qiu on 16/7/15.
//  Copyright © 2016年 ZW. All rights reserved.
//  用于显示已加载的进度条,可显示非连续的

import UIKit

struct PPFRange {
    var location:Double
    var length:Double
    
    var max:Double{
        return location + length
    }
    
    /**
     增加范围
     
     - parameter range: 另一个范围
     
     - returns: 是否已经合成
     */
    mutating func addRange(range:PPFRange) -> Bool{
        if self.containRange(range){
            return true
        }
        if self.isSubRangeOf(range){
            location = range.location
            length = range.length
            return true
        }
        
        if max > range.location && location < range.location{
            length = range.max - location
            return true
        }
        if range.max > location && range.location < location{
            location = range.location
            length = max - range.location
            return true
        }
        return false
    }
    
    /**
     是否包含另一个范围
     
     - parameter range: 另一个范围
     
     - returns: 包含是否成功
     */
    func containRange(range:PPFRange) -> Bool{
        if location > range.location{
            return false
        }
        if max < range.max {
            return false
        }
        return true
    }
    
    /**
     是否是子范围
     
     - parameter range: 另一个范围
     
     - returns:
     */
    func isSubRangeOf(range:PPFRange) -> Bool{
        return range.containRange(self)
    }
}

class LoadedView: UIView {
    /// 范围片数的数组,都在0.0~1.0的范围内
    private(set) var loadedPieces:[PPFRange] = []
    
    
    /**
     增加范围
     
     - parameter range: 范围
     */
    func addRange(range:PPFRange){
        guard range.location + range.length <= 1.0 else{
            print("超过范围:\(range)")
            return
        }
        var a = false
        for i in 0 ..< loadedPieces.count{
            a = loadedPieces[i].addRange(range)
        }
        if !a{
            loadedPieces.append(range)
        }
        setupUIWithRanges(loadedPieces)
    }
    /**
     移除所有
     */
    func removeAllPiece(){
        loadedPieces = []
        setupUIWithRanges(loadedPieces)
    }
    
    /**
     用范围值再重新配置UI
     
     - parameter ranges: 范围
     */
    private func setupUIWithRanges(ranges:[PPFRange]){
        //1. 清空
        for v in subviews {
            v.removeFromSuperview()
        }
        //2. 创建子view
        for _ in 0 ..< loadedPieces.count{
            let v = UIView()
            v.backgroundColor = UIColor.grayColor()
            self.addSubview(v)
        }
        //3.刷新约束
        self.setNeedsUpdateConstraints()
    }
    
    func syncUI(){
        self.setNeedsUpdateConstraints()
    }
    
    override class func requiresConstraintBasedLayout() -> Bool{
        return true
    }
    override func updateConstraints() {
        guard subviews.count == loadedPieces.count else{
            fatalError("subviews.count != loadedPiecees.count")
        }
        
        for i in 0 ..< loadedPieces.count{
            let piece = loadedPieces[i]
            let view = subviews[i]
            
            let leading = bounds.width * CGFloat(piece.location)
            let width = bounds.width * CGFloat(piece.length)
            view.mas_remakeConstraints(){[weak self] in
                $0.leading.equalTo()(self).offset()(leading)
                $0.top.and().bottom().equalTo()(self)
                $0.width.equalTo()(width)
            }
        }
        super.updateConstraints()
    }
}









