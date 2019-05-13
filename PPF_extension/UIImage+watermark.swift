//
//  UIImage+watermark.swift
//  TestWatermark
//
//  Created by 潘鹏飞 on 2019/5/10.
//  Copyright © 2019 JianDePu. All rights reserved.
//

import Foundation
import UIKit

/// 在一个图片上增加水印:文字,图片
extension UIImage {
    func addWatermark(text:String,withAttributes attri:[NSAttributedString.Key : Any]?) -> UIImage?{
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let attrStr = NSAttributedString(string: text, attributes: attri)
        let re = attrStr.boundingRect(with: CGSize(width: 1000, height: 1000), options: .usesFontLeading, context: nil)
        
        let wCount = Int(size.width.truncatingRemainder(dividingBy: re.width))
        let hCount = Int(size.height.truncatingRemainder(dividingBy: re.height))
        
        for i in 0 ..< wCount {
            for j in 0 ..< hCount {
                let t = text as NSString
                let pointX = CGFloat(i) * (re.width + 30)
                let pointY = CGFloat(j) * (re.height + 30)
                t.draw(at: CGPoint(x: pointX, y: pointY), withAttributes: attri)
            }
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func addWatermark(img:UIImage) -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        
        let wCount = Int(size.width.truncatingRemainder(dividingBy: img.size.width))
        let hCount = Int(size.height.truncatingRemainder(dividingBy: img.size.height))
        
        for i in 0 ..< wCount {
            for j in 0 ..< hCount {
                let pointX = CGFloat(i) * (img.size.width + 30)
                let pointY = CGFloat(j) * (img.size.height + 30)
                img.draw(at: CGPoint(x: pointX, y: pointY))
            }
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img

    }
}
