//
//  CommentsView.swift
//  YanXiuWang
//
//  Created by Liuming Qiu on 2017/3/3.
//  Copyright © 2017年 ZW. All rights reserved.
//

import UIKit

protocol AttributeString {
    var attributeString:NSAttributedString { get }
}

protocol CommentsView_delegate:class{
    func commentsView<T:AttributeString>(cv:CommentsView<T>,didSelected comment:T)
}

class CommentsView<T:AttributeString>: UIView {
    
    /// 边距
    let edge:CGFloat = 5
    /// 间距
    let space:CGFloat = 3

    /// 评论
    var comments:[T]!
    /// 按钮
    var buttons:[UIButton]!
    /// 显示label
    var labels:[UILabel]!
    
    weak var delegate:CommentsView_delegate?
    
    
    init(comments:[T]){
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        backgroundColor = colorWithHex(0xF0F0F2)
        updateUI(comments)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 更新数据和UI
    ///
    /// - Parameter comments: 数据源
    func updateUI(comments:[T]){
        self.comments = comments
        guard comments.count != labels?.count else{
            for i in 0 ..< labels.count{
                labels![i].attributedText = comments[i].attributeString
            }
            return
        }
        // 2:增加或删除 按钮 达到和评论一样的数量
        if labels == nil{
            labels = []
        }
        if buttons == nil{
            buttons = []
        }
        if comments.count > labels!.count{
            for _ in 0 ..< comments.count - labels!.count {
                let b = UILabel()
                b.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: UILayoutConstraintAxis.Vertical)
                
                b.numberOfLines = 0
                self.addSubview(b)
                labels!.append(b)
                
                let button = UIButton()
                button.addTarget(self, action: #selector(CommentsView.tapOnComments(_:)), forControlEvents: .TouchUpInside)
                self.addSubview(button)
                buttons.append(button)
            }
        }else if comments.count < labels!.count{
            for _ in 0 ..< labels!.count - comments.count {
                labels!.removeLast().removeFromSuperview()
                buttons.removeLast().removeFromSuperview()
            }
        }
        
        for i in 0 ..< comments.count{
            labels![i].attributedText = comments[i].attributeString
        }
        
        makeConstraint()
    }
    
    private func makeConstraint(){
        //边距
        for i in 0 ..< comments.count{
            if i == 0{
                if comments.count == 1{
                    labels![i].mas_remakeConstraints(){
                        $0.top.leading().equalTo()(self).offset()(self.edge)
                        $0.bottom.trailing().equalTo()(self).offset()(-self.edge)
                    }
                }else{
                    labels![i].mas_remakeConstraints(){
                        $0.top.leading().equalTo()(self).offset()(self.edge)
                        $0.trailing.equalTo()(self).offset()(-self.edge)
                    }
                }
            }else if i == comments.count - 1 {
                labels![i].mas_remakeConstraints(){
                    $0.top.equalTo()(self.labels![i - 1].mas_bottom).offset()(self.space)
                    $0.leading.equalTo()(self).offset()(self.edge)
                    $0.bottom.trailing().equalTo()(self).offset()(-self.edge)
                }
            }else{
                labels![i].mas_remakeConstraints(){
                    $0.top.equalTo()(self.labels![i - 1].mas_bottom).offset()(self.space)
                    $0.leading.equalTo()(self).offset()(self.edge)
                    $0.trailing.equalTo()(self).offset()(-self.edge)
                }
            }
            buttons![i].mas_remakeConstraints(){
                $0.edges.equalTo()(self.labels[i])
            }
        }
    }

    
    /// 交互
    ///
    /// - Parameter button: 按钮
    func tapOnComments(button:UIButton){
        guard let index = buttons.indexOf(button) else{
            fatalError()
        }
        delegate?.commentsView(self, didSelected: comments[index])
    }
}
