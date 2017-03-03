//
//  TextChatUnitTableViewCell.swift
//  YanXiuWang
//
//  Created by Liuming Qiu on 2017/2/27.
//  Copyright © 2017年 ZW. All rights reserved.
//

import UIKit

class TextChatUnitTableViewCell: BaseChatUnitTableViewCell {
    
    weak var bubbleV:UIImageView!
    weak var contentL:UILabel!

    override func setupUI(chatUnit: ChatUnit2_M) {
        super.setupUI(chatUnit)
        contentL.text = chatUnit.text
        if isMe(){
            bubbleV.image = UIImage(named: "bubble_right")
            contentL.textColor = UIColor.whiteColor()
        }else{
            bubbleV.image = UIImage(named: "bubble_left")
            contentL.textColor = UIColor.blackColor()
        }
    }
    
    override func createUI() {
        super.createUI()
        if bubbleV == nil{
            let bv = UIImageView()
            bv.backgroundColor = UIColor.clearColor()
            contentView.addSubview(bv)
            bubbleV = bv
        }
        
        if contentL == nil{
            let cl = UILabel()
            cl.font = UIFont.systemFontOfSize(14)
            cl.textColor = colorWithHex(0x333333)
            cl.numberOfLines = 0
            contentView.addSubview(cl)
            contentL = cl
        }
    }
}

extension TextChatUnitTableViewCell{
    override class func requiresConstraintBasedLayout() -> Bool{
        return true
    }

    override func updateConstraints() {
        super.updateConstraints()
        contentL.mas_remakeConstraints(){
            $0.top.equalTo()(self.nameL.mas_bottom).setOffset(8)
            $0.bottom.equalTo()(self.contentView.mas_bottomMargin).setOffset(-8)
            if self.isMe(){
                $0.trailing.equalTo()(self.nameL.mas_trailing)
                $0.leading.greaterThanOrEqualTo()(self.contentView.mas_leadingMargin).setOffset(60)
            }else{
                $0.leading.equalTo()(self.nameL.mas_leading)
                $0.trailing.lessThanOrEqualTo()(self.contentView.mas_trailingMargin).setOffset(-60)
            }
        }
        
        bubbleV.mas_remakeConstraints(){
            var inserts = UIEdgeInsetsMake(-5, -9, -5, -9)
            if self.isMe(){
                inserts.right = -13
            }else{
                inserts.left = -13
            }
            $0.edges.equalTo()(self.contentL).setInsets(inserts)
        }
        
    }
}
