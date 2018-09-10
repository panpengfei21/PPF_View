//
//  JDP_ShowNumberListView.swift
//  JDPHouseDemolitionManagement
//
//  Created by 潘鹏飞 on 2018/9/7.
//  Copyright © 2018年 健德普. All rights reserved.
//  用来展示横向等宽的界面

import UIKit

protocol ShowListView_delegate:class {
    /// 总共有几个View
    func showListViewNumber(lView:JDP_ShowListView)->Int
    /// 指定索引的View
    func showListView(lView:JDP_ShowListView,viewAtIndex index:Int) -> UIView
}

class ShowListView: UIView {
    /// 单个数字的View
    weak var delegate:ShowListView_delegate!
    
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
        let total = delegate?.showListViewNumber(lView: self) ?? 0
        for i in 0 ..< total {
            let v = delegate.showListView(lView: self, viewAtIndex: i)
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
        numberVs.first!.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 3).isActive = true
        numberVs.last!.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -3).isActive = true
        for i in 0 ..< numberVs.count {
            numberVs[i].topAnchor.constraint(equalTo: self.topAnchor, constant: 14).isActive = true
            numberVs[i].bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14).isActive = true
            if i >= 0 && i < numberVs.count - 1 {
                numberVs[i].rightAnchor.constraint(equalTo: numberVs[i + 1].leftAnchor).isActive = true
            }
            if i + 1 <= numberVs.count - 1 {
                numberVs[i].widthAnchor.constraint(equalTo: numberVs[i + 1].widthAnchor).isActive = true
            }
        }
    }
}
