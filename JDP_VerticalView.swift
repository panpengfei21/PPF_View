//
//  JDP_VerticalView.swift
//  JDPHouseDemolitionManagement
//
//  Created by 潘鹏飞 on 2018/12/20.
//  Copyright © 2018 健德普. All rights reserved.
//

import UIKit

protocol JDP_VerticalView_delegate:class {
    /// 总共有几个View
    func verticalViewNumber(lView:JDP_VerticalView)->Int
    /// 指定索引的View
    func verticalView(lView:JDP_VerticalView,viewAtIndex index:Int) -> UIView
}

/// 用来展示纵向等高的界面
class JDP_VerticalView: UIView {
    /// 单个数字的View
    weak var delegate:JDP_VerticalView_delegate!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadData(){
        for view in subviews {
            view.removeFromSuperview()
        }
        initializeUI()
        initializeConstraint()
    }
    /// 初始化UI
    private func initializeUI() {
        let total = delegate?.verticalViewNumber(lView: self) ?? 0
        for i in 0 ..< total {
            let v = delegate.verticalView(lView: self, viewAtIndex: i)
            v.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(v)
        }
    }
    
    /// 初始化约束
    private func initializeConstraint() {
        let numberVs = self.subviews
        guard !numberVs.isEmpty else{
            return
        }
        numberVs.first!.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        numberVs.last!.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        for i in 0 ..< numberVs.count {
            numberVs[i].leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            numberVs[i].rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            if i >= 0 && i < numberVs.count - 1 {
                numberVs[i].bottomAnchor.constraint(equalTo: numberVs[i + 1].topAnchor).isActive = true
            }
            if i + 1 <= numberVs.count - 1 {
                numberVs[i].heightAnchor.constraint(equalTo: numberVs[i + 1].heightAnchor).isActive = true
            }
        }
    }
}
