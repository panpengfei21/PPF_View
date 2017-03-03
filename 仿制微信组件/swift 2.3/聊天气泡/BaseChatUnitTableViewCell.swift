//
//  BaseChatUnitTableViewCell.swift
//  YanXiuWang
//
//  Created by Liuming Qiu on 2017/2/27.
//  Copyright © 2017年 ZW. All rights reserved.
//

import UIKit

class BaseChatUnitTableViewCell: UITableViewCell {
    /// 头像宽(高应该和宽一样)
    let avatarWidth:CGFloat = 40
    /// 头像的边距
    let edgeInset:CGFloat = 8
    /// 名字的高度
    let nameLabelHeight:CGFloat = 11

    var chatUnit:ChatUnit2_M! {
        didSet{
            setupUI(chatUnit)
        }
    }
    
    weak var avatarIV:UIImageView!
    weak var nameL:UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        selectionStyle = .None
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isMe() -> Bool{
        return chatUnit == nil ? false : chatUnit.sender?.id == userID
    }
}


extension BaseChatUnitTableViewCell{
    func setupUI(chatUnit:ChatUnit2_M){
        setNeedsUpdateConstraints()
        avatarIV.yy_setImageWithURL(NSURL(string: chatUnit.sender?.avatarPath ?? ""), placeholder: UIImage(named: "avatarImage50"))
        nameL.text = chatUnit.sender?.name
    }
    
    /// 创建UI
    func createUI(){
        if avatarIV == nil{
            let iv = UIImageView()
            iv.contentMode = .ScaleAspectFill
            iv.clipsToBounds = true
            contentView.addSubview(iv)
            avatarIV = iv
        }
        if nameL == nil{
            let nl = UILabel()
            nl.font = UIFont.systemFontOfSize(nameLabelHeight)
            nl.textColor = colorWithHex(0x696969)
            contentView.addSubview(nl)
            nameL = nl;
        }
    }
}

extension BaseChatUnitTableViewCell{
    override class func requiresConstraintBasedLayout() -> Bool{
        return true
    }
    
    override func updateConstraints() {
        
        let con = contentView.constraints.filter{
            if ($0.secondItem is UIImageView) && ($0.secondItem as! UIImageView) == self.avatarIV{
                return true
            }else if ($0.secondItem is UILabel) && ($0.secondItem as! UILabel) == self.nameL{
                return true
            }else{
                return false
            }
        }
        contentView.removeConstraints(con)
        
        avatarIV.mas_remakeConstraints {
            $0.width.equalTo()(self.avatarWidth)
            $0.height.equalTo()(self.avatarWidth)
            $0.top.equalTo()(self.contentView.mas_top).offset()(self.edgeInset)
            $0.bottom.lessThanOrEqualTo()(self.contentView.mas_bottom).setOffset(-self.edgeInset)
            if self.isMe(){
                $0.trailing.equalTo()(self.contentView.mas_trailing).setOffset(-self.edgeInset)
            }else{
                $0.leading.equalTo()(self.contentView.mas_leading).setOffset(self.edgeInset)
            }
        }
        
        nameL.mas_remakeConstraints(){
            $0.top.equalTo()(self.avatarIV.mas_top)
            $0.height.equalTo()(self.nameLabelHeight)
            if self.isMe(){
                $0.trailing.equalTo()(self.avatarIV.mas_leading).setOffset(-15)
                $0.leading.greaterThanOrEqualTo()(self.contentView.mas_leading).setOffset(15)
            }else{
                $0.leading.equalTo()(self.avatarIV.mas_trailing).setOffset(15)
                $0.trailing.lessThanOrEqualTo()(self.contentView.mas_trailing).setOffset(-15)
            }
        }
        super.updateConstraints()
    }
}










