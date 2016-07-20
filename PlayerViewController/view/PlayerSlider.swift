//
//  PlayerSlider.swift
//  ZhangShi
//
//  Created by Liuming Qiu on 16/7/15.
//  Copyright © 2016年 ZW. All rights reserved.
//

import UIKit

class PlayerSlider: UISlider {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setThumbImage(UIImage(named: "point"), forState: UIControlState.Normal)
    }
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        let height:CGFloat = 3.0
        let y = (bounds.size.height - height) / 2.0
        let width = bounds.size.width
        return CGRect(x: 0, y: y, width: width, height: height)
    }
    

}


