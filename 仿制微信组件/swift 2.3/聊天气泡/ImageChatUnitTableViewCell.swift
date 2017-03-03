//
//  ImageChatUnitTableViewCell.swift
//  YanXiuWang
//
//  Created by Liuming Qiu on 2017/2/28.
//  Copyright © 2017年 ZW. All rights reserved.
//

import UIKit
import Masonry

protocol ImageChatUnitTableViewCell_delegate:class {
    func imageChatUnitTableView(cell:ImageChatUnitTableViewCell,willLoad imageView:UIImageView)
    func imageChatUnitTableView(cell:ImageChatUnitTableViewCell,didLoad imageView:UIImageView)
}

class ImageChatUnitTableViewCell: BaseChatUnitTableViewCell {

    
    /// default image size
    let defaultImageSize = CGSize(width: 115, height: 97)
    /// 聊天图片最大的高或宽
    let lengthOfImageView:CGFloat = 130
     var imageV:UIImageView!
    weak var delegate:ImageChatUnitTableViewCell_delegate?
    
    weak var widthConstraint:MASConstraint?
    weak var heightConstraint:MASConstraint?
    weak var leadingConstraint:MASConstraint?
    weak var trailingConstraint:MASConstraint?
    
    override func createUI() {
        super.createUI()
        if imageV == nil{
            let iv = UIImageView(image: UIImage(named: "Cloud_Picture"))
            contentView.addSubview(iv)
            imageV = iv
        }
    }

    override func setupUI(chatUnit: ChatUnit2_M) {
        super.setupUI(chatUnit)
        var maskV:UIImageView
        
        if self.isMe(){
            maskV = UIImageView(image: UIImage(named: "bubble_right"))
        }else{
            maskV = UIImageView(image: UIImage(named: "bubble_left"))
        }
        imageV.maskView = maskV
        let url = NSURL(string: chatUnit.imageURL ?? "")
        delegate?.imageChatUnitTableView(self, willLoad: imageV)
        imageV.yy_setImageWithURL(url, placeholder: UIImage(named: "Cloud_Picture"), options: .ProgressiveBlur) { (image, url, type, stage, error) in
            self.setNeedsUpdateConstraints()
            self.delegate?.imageChatUnitTableView(self, didLoad: self.imageV)
        }
    }
    
    func setUI(chatUnit: ChatUnit2_M,size:CGSize){
        
    }
    
    
    
    /// 有效的心尺寸
    ///
    /// - Parameter image: 图片
    /// - Returns: 尺寸
    private func validSize(image:UIImage?) -> CGSize{
        guard let im = image else{
            return defaultImageSize
        }
        var size:CGSize
        
        if im.size.height <= lengthOfImageView && im.size.width <= lengthOfImageView{
            size = im.size
        }else if im.size.width > im.size.height{
            let width = lengthOfImageView
            let height = im.size.height / im.size.width * lengthOfImageView
            size = CGSize(width: width, height: height)
        }else{
            let width = im.size.width / im.size.height * lengthOfImageView
            let height = lengthOfImageView
            size = CGSize(width: width, height: height)
        }
        
        return size
    }
}

extension ImageChatUnitTableViewCell{
    override class func requiresConstraintBasedLayout() -> Bool{
        return true
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        let size = self.validSize(self.imageV.image)
        imageV.maskView?.bounds.size = size
        imageV.maskView?.frame.origin = CGPointZero
        imageV.mas_remakeConstraints(){
            self.widthConstraint = $0.width.equalTo()(size.width)
            self.heightConstraint = $0.height.equalTo()(size.height)
            $0.top.equalTo()(self.nameL.mas_bottom).setOffset(8)
            $0.bottom.equalTo()(self.contentView).offset()(-13).priority()(MASLayoutPriority(floatLiteral: 250))
            if self.isMe(){
               self.trailingConstraint = $0.trailing.equalTo()(self.nameL.mas_trailing).offset()(13)
            }else{
                self.leadingConstraint = $0.leading.equalTo()(self.nameL.mas_leading).offset()(-13)
            }
        }
    }
}
