//
//  IndexView.swift
//  ZhangShi
//
//  Created by Liuming Qiu on 16/7/5.
//  Copyright © 2016年 ZW. All rights reserved.
//  索引指示

import UIKit

class IndexView: UIView {

    /// 子view 的固定宽度
    private let sbWith:CGFloat = 13
    /// 子view 的固定高度
    private let sbHeight:CGFloat = 3
        ///没有被选中的颜色
    private let normalColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        /// 被选中的颜色
    private let selectedColor = mainColor.colorWithAlphaComponent(0.6)
        /// 子view的内距
    private let space:CGFloat = 5.0;
    
        /// 总数
    var total:Int
        /// 当前的索引
    var index:Int {
        didSet{
            guard index >= 0 && index < total else{
                index = oldValue
                return
            }
            views[oldValue].backgroundColor = normalColor
            views[index].backgroundColor = selectedColor
        }
    }
        /// 当前包含的子view
    private var views:[UIView]
    
    // MARK: - 初始化
    init?(amountOfIndexs t:Int,index:Int = 0){
        guard t > 0 else{
            return nil
        }
        total = t
        self.index = index
        views = []
        for i in 0 ..< t{
            let originX = CGFloat(i) * (sbWith + space)
            let view = UIView(frame: CGRect(origin: CGPoint(x: originX,y: 0), size: CGSize(width: sbWith, height: sbHeight)))
            view.backgroundColor = normalColor
            views.append(view)
        }
        views[index].backgroundColor = selectedColor
        
        let width = CGFloat(t - 1) * (sbWith + space) + sbWith
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: sbHeight))
        views.forEach(){[weak self] in
            self?.addSubview($0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
