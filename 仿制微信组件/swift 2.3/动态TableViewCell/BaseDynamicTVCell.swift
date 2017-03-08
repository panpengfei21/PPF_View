//
//  BaseDynamicTVCell.swift
//  YanXiuWang
//
//  Created by Liuming Qiu on 2017/3/2.
//  Copyright © 2017年 ZW. All rights reserved.
//

import UIKit
import Masonry


protocol BaseDynamicTVCell_delegate:class {
    func baseDynamicTV(cell:BaseDynamicTVCell,didSelected comment:PPFComment)
    func baseDynamicTV(cell:BaseDynamicTVCell,didSelectedLinker linker: Publication_linker)
    func baseDynamicTV(cell:BaseDynamicTVCell,didSelectedResource resource: Publication_resource)
    func baseDynamicTV(cell:BaseDynamicTVCell,didSelectedImageAndText it: Publication_ImageAndText, with imagePath: String)

    func baseDynamicTV(cell:BaseDynamicTVCell,didSelectedTrash button:UIButton)
    func baseDynamicTV(cell:BaseDynamicTVCell,didSelectedMenu button:UIButton)
    
}

class BaseDynamicTVCell: UITableViewCell {

    
    /// 头像
    weak var avatarIV:UIImageView!
    /// 名字
    weak var nameL:UILabel!
    /// 时期
    weak var dateL:UILabel!
    /// 删除按钮
    weak var trashB:UIButton!
    /// 装饰线
    weak var firstLineV:UIView!
    /// 用于显示内容的框(里面可能有图片,文字等等)
    weak var contentV:PublicationContentView!
    /// 统计
    weak var statisticsL:UILabel!
    /// menu 按钮
    weak var menuB:UIButton!
    /// 评论
    weak var commentsV:CommentsView<PPFComment>?
    
    /// 评论按钮
    var commentsLabels:[UILabel]?
    var commentsButtons:[UIButton]?
    
    var statisticsLBottomConstraint:MASConstraint!
    
    var publication:PPFPublication! {
        didSet{
            updateAllUI(publication)
        }
    }
    
    var delegate:BaseDynamicTVCell_delegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        createUI()
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - UI 处理
extension BaseDynamicTVCell{
    func createUI(){
        avatarIV = {
            let iv = UIImageView()
            iv.image = UIImage(named: "avatarImage50")
            iv.clipsToBounds = true
            iv.frame.size = CGSize(width: 42, height: 42)
            self.contentView.addSubview(iv)
            return iv
        }()
        
        nameL = {
            let l = UILabel()
            l.font = UIFont.systemFontOfSize(15)
            l.textColor = colorWithHex(0x295999)
            l.text = "name"
            self.contentView.addSubview(l)
            return l
        }()
        
        dateL = {
            let l = UILabel()
            l.font = UIFont.systemFontOfSize(12)
            l.textColor = colorWithHex(0x707070)
            l.text = "yyyy-MM-dd"
            self.contentView.addSubview(l)
            return l
        }()
        
        trashB = {
            let b = UIButton()
            b.frame.size = CGSize(width: 30, height: 30)
            b.setImage(UIImage(named:"P4-2_delete"), forState: .Normal)
            b.addTarget(self, action: #selector(BaseDynamicTVCell.tapForDelete(_:)), forControlEvents: .TouchUpInside)
            self.contentView.addSubview(b)
            return b;
        }()
        
        firstLineV = {
            let v = UIView()
            v.backgroundColor = colorWithHex(0xF0F0F0)
            self.contentView.addSubview(v)
            return v
        }()

        contentV = {
            let v = PublicationContentView()
            v.delegate = self
            self.contentView.addSubview(v)
            return v;
        }()
        
        statisticsL = {
            let l = UILabel()
            l.font = UIFont.systemFontOfSize(12)
            l.textColor = colorWithHex(0xbdbdbd)
            l.text = "?赞?评"
            self.contentView.addSubview(l)
            return l;
        }()

        menuB = {
            let b = UIButton()
            b.frame.size = CGSize(width: 30, height: 22)
            b.setImage(UIImage(named:"P3-1_more"), forState: .Normal)
            b.addTarget(self, action: #selector(BaseDynamicTVCell.tapForMenu(_:)), forControlEvents: .TouchUpInside)
            self.contentView.addSubview(b)
            return b;
        }()
    }
    
    
    /// 更新全部UI
    ///
    /// - Parameter pub: pub description
    func updateAllUI(pub:PPFPublication){
        avatarIV.yy_setImageWithURL(NSURL(string: pub.publisher.avatarPath), placeholder: UIImage(named: "avatarImage50"))
        nameL.text = pub.publisher.name
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
        dateL.text = dateFormatter.stringFromDate(pub.date)
        
        statisticsL.text = "\(pub.amountOfPraise)赞 \(pub.amountOfComments)评论 \(pub.amountOfRead)阅读 \(pub.amountOfShare)分享"
        contentV.updateUI(pub)
        updateCommentView(pub.comments)
        setNeedsUpdateConstraints()
    }
    
    
    /// 更新评论view
    ///
    /// - Parameter comments: comments description
    func updateCommentView(comments:[PPFComment]?){
        guard let com = comments where !com.isEmpty else {
            commentsLabels = nil
            commentsV?.removeFromSuperview()
            statisticsLBottomConstraint.activate()
            return
        }
        statisticsLBottomConstraint.deactivate()
        // 1:建外面的框
        if commentsV == nil{
            commentsV = {
                let cv = CommentsView(comments: comments!)
                cv.delegate = self
                self.contentView.addSubview(cv)
                return cv
            }()
        }else{
            commentsV!.updateUI(comments!)
        }
        
        commentsV!.mas_remakeConstraints(){
            $0.top.equalTo()(self.statisticsL.mas_bottom).offset()(10)
            $0.leading.equalTo()(self.firstLineV.mas_leading)
            $0.trailing.equalTo()(self.contentView.mas_trailingMargin)
            $0.bottom.equalTo()(self.contentView.mas_bottomMargin)
        }
    }

}


// MARK: - 约束
extension BaseDynamicTVCell{
    
    private func makeConstraints(){
        avatarIV.mas_makeConstraints(){
            $0.top.equalTo()(self.contentView.mas_top).offset()(12)
            $0.leading.equalTo()(self.contentView.mas_leading).offset()(12)
            $0.width.equalTo()(42)
            $0.height.equalTo()(42)
        }
        nameL.mas_makeConstraints(){
            $0.top.equalTo()(self.avatarIV)
            $0.leading.equalTo()(self.avatarIV.mas_trailing).offset()(8)
            $0.trailing.equalTo()(self.trashB.mas_leading).offset()(-8)
        }
        dateL.mas_makeConstraints(){
            $0.top.equalTo()(self.nameL.mas_bottom).offset()(4)
            $0.leading.equalTo()(self.nameL)
        }
        trashB.mas_makeConstraints(){
            $0.centerY.equalTo()(self.nameL)
            $0.trailing.equalTo()(self.contentView.mas_trailingMargin)
        }
        firstLineV.mas_makeConstraints(){
            $0.leading.equalTo()(self.nameL)
            $0.bottom.equalTo()(self.avatarIV)
            $0.height.equalTo()(1)
            $0.trailing.equalTo()(self.contentView.mas_trailing)
        }
        
        contentV.mas_makeConstraints(){
            $0.leading.equalTo()(self.nameL)
            $0.trailing.equalTo()(self.contentView.mas_trailingMargin)
            $0.top.equalTo()(self.firstLineV.mas_bottom).offset()(8)
        }
        
        menuB.mas_makeConstraints(){
            $0.trailing.equalTo()(self.contentView.mas_trailingMargin)
            $0.centerY.equalTo()(self.statisticsL)
        }
        
        statisticsL.mas_makeConstraints(){
            $0.leading.equalTo()(self.firstLineV)
            $0.top.equalTo()(self.contentV.mas_bottom).offset()(8)
            $0.trailing.equalTo()(self.menuB.mas_leading).offset()(-8)
            self.statisticsLBottomConstraint = $0.bottom.equalTo()(self.contentView.mas_bottomMargin)
        }
    }
    
    override class func requiresConstraintBasedLayout() -> Bool{
        return true
    }
    override func updateConstraints() {
        super.updateConstraints()
    }
}


// MARK: - 交互
extension BaseDynamicTVCell{
    func tapForDelete(trashB:UIButton){
        delegate?.baseDynamicTV(self, didSelectedTrash: trashB)
    }
    
    func tapForMenu(menuB:UIButton){
        delegate?.baseDynamicTV(self, didSelectedMenu: menuB)
    }
    
}



// MARK: - CommentsView_delegate
extension BaseDynamicTVCell:CommentsView_delegate{
    func commentsView<T : AttributeString>(cv: CommentsView<T>, didSelected comment: T) {
        delegate?.baseDynamicTV(self, didSelected: comment as! PPFComment)
    }
}

// MARK: - PublicationContentView_delegate
extension BaseDynamicTVCell:PublicationContentView_delegate{
    func publicationContentView(pcv: PublicationContentView, didSelectedLinker linker: Publication_linker) {
        delegate?.baseDynamicTV(self, didSelectedLinker: linker)
    }
    func publicationContentView(pcv: PublicationContentView, didSelectedResource resource: Publication_resource) {
        delegate?.baseDynamicTV(self, didSelectedResource: resource)
    }
    func publicationContentView(pcv: PublicationContentView, didSelectedImageAndText it: Publication_ImageAndText, with imagePath: String) {
        delegate?.baseDynamicTV(self, didSelectedImageAndText: it, with: imagePath)
    }
}


