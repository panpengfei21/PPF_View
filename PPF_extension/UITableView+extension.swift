//
//  UITableView+extension.swift
//  YanXiuWang
//
//  Created by Liuming Qiu on 16/3/25.
//  Copyright © 2016年 ZW. All rights reserved.
//

import UIKit
extension UITableView{
    /**
     刷新table view
     
     - parameter oldData: 旧数据
     - parameter newData: 新数据
     */
    func reloadTableViewWithOldData<T:NSObject>(inout oldData:[T],newData:[T],offs:Int){
        let originCount = oldData.count
        
        if oldData.count > newData.count {  // 减少数据
            let minusIndexPaths = (newData.count ..< oldData.count).map(){NSIndexPath(forItem: $0 + offs, inSection: 0)}
            oldData.removeRange(Range(start: newData.count, end: oldData.count))
            
            self.beginUpdates()
            self.deleteRowsAtIndexPaths(minusIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            self.endUpdates()
        }else if oldData.count < newData.count{  // 增加数据
            let plusIndexPaths = (oldData.count ..< newData.count).map(){NSIndexPath(forItem: $0 + offs, inSection: 0)}
            oldData += newData[oldData.count ..< newData.count]
            
            self.beginUpdates()
            self.insertRowsAtIndexPaths(plusIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            self.endUpdates()
        }
        
        // 当旧数据或新新数据是零时，因为上面的代码已经完成刷新，以下的代码不用再次刷新
        if originCount == 0 || newData.count == 0 {
            return
        }
        
        oldData = newData
        let indexpaths = (0 ..< newData.count).map(){NSIndexPath(forItem: $0 + offs, inSection: 0)}
        self.reloadRowsAtIndexPaths(indexpaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
}
