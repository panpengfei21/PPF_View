//
//  UITableViewCell+Extension.swift
//  JDPHouseDemolitionManagement
//
//  Created by 潘鹏飞 on 2018/8/22.
//  Copyright © 2018年 健德普. All rights reserved.
//  这个table view cell 的子类,是可以把分割线去除

import UIKit


class HasNoSeparatorTableViewCell:UITableViewCell {
    override func addSubview(_ view: UIView) {
        let className = class_getName(view.classForCoder)
        let name = String(cString: className)
        guard name != "_UITableViewCellSeparatorView" else{
            return
        }
        super.addSubview(view)
    }
}
