//
//  SearchView.swift
//  YanXiuWang
//
//  Created by Liuming Qiu on 16/3/15.
//  Copyright © 2016年 ZW. All rights reserved.
// 应该叫做 search bar 是搜索输入框

import UIKit
protocol SearchView_delegate:class{
    func searchView(sv:SearchView,didClickWithStatus status:Bool)
}

class SearchView: UIView {
    // MARK: - UI
    var textField:UITextField!
    var label:UILabel!
    var imageV:UIImageView!
    var cancelB:UIButton!
        
    /**
     存放输入的搜索内容,应该在以下的方法里赋值
         func textFieldDidEndEditing(textField: UITextField) {
             searchBar?.searchText = textField.text
         }
     */
    private(set) var searchText:String?
    
    // MARK: - peoperty
    /// text field 里的left view 距左边界的距离
    let leftViewToBorder:CGFloat = 8.0;
    /// 占位字符串
    let placeHodlerString = "搜索"
    /// 动画的持续时间
    var duration:CGFloat = UINavigationControllerHideShowBarDuration
    
    /// 退出按钮的包
    var cancelButtonBlock:(()->())?
    
    /// 是否激活这个view,也是动画的触发点。
    private(set) var enable:Bool = false
    /// 代理
    weak var delegate:SearchView_delegate?
    
    /// 默认有动画效果
    var animated:Bool = true
    
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI(){
        cancelB = UIButton()
        let font = UIFont.systemFontOfSize(19)
        let attrStr = NSAttributedString(string: "取消", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:font])
        cancelB.setAttributedTitle(attrStr, forState: UIControlState.Normal)
        cancelB.sizeToFit()
        cancelB.alpha = 0.0
        
        imageV = UIImageView(image: UIImage(named: "zoom"))
        imageV.clipsToBounds = false
        
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        textField.placeholder = placeHodlerString
        textField.textAlignment = NSTextAlignment.Left
        textField.borderStyle = UITextBorderStyle.RoundedRect
        let leftViewRect = CGRect(x: 0, y: 0, width: imageV.frame.width + leftViewToBorder, height: imageV.frame.height)
        textField.leftView = UIView(frame: leftViewRect)
        textField.leftViewMode = UITextFieldViewMode.Always
        textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        textField.enabled = false
        textField.setValue(colorWithHex(0x8f8e94), forKeyPath: "_placeholderLabel.textColor")
        textField.returnKeyType = .Search
        
        label = UILabel()
        label.textColor = colorWithHex(0x8f8e94)
        label.font = textField.valueForKeyPath("_placeholderLabel.font") as! UIFont
        label.text = placeHodlerString
        label.sizeToFit()
        
        textField.placeholder = nil
        
        self.addSubview(cancelB)
        self.addSubview(textField)
        self.addSubview(label)
        self.addSubview(imageV)
        
        //  加按钮的事件和手势
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SearchView.setEnableToreverse))
        self.addGestureRecognizer(gesture)
        cancelB.addTarget(self, action: #selector(SearchView.cancelEditing(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    // MARK: - event
    func cancelEditing(but:UIButton){
        //如果有包就运行包里的，没有就运行默认的
        if let blo = cancelButtonBlock {
            blo()
        }else{
            enable = !enable
        }
    }
    
    /**
     把search view的活动状态,激活或失效
     */
    func setEnableToreverse(){
        setEnable(!enable, WithAnimated: animated)
    }
    
    /**
     让键盘缩回去
     
     - returns: bool
     */
    func textFieldResignFirstResponder() -> Bool{
        return textField.resignFirstResponder()
    }
    
    /**
     设置search view是否活动
     
     - parameter animated: 动画
     */
    func setEnable(enable:Bool,WithAnimated animated:Bool){
        if self.enable != enable{
            self.enable = enable
            if enable{
                moveToLeftWithAnimated(animated)
            }else{
                moveToRightWithAnimated(animated)
            }
        }
    }
    
    // MARK: - UI action
    
    private func moveToLeftWithAnimated(animated:Bool){
        
        self.label.text = (searchText == nil || searchText == "") ? placeHodlerString : searchText!
        
        label.mas_remakeConstraints(){
            $0.left.equalTo()(self.mas_left).with().offset()(self.textField.placeholderRectForBounds(self.textField.bounds).origin.x)
            $0.centerY.equalTo()(self.mas_centerY)
        }
        
        textField.mas_remakeConstraints(){
            let edge = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.cancelB.frame.width + 2 * 8)
            $0.edges.equalTo()(self).with().insets()(edge)
        }
        
        if animated{
            self.userInteractionEnabled = false
            UIView.animateWithDuration(Double(duration), animations: { [unowned self] in
                self.cancelB.alpha = 1.0
                self.layoutIfNeeded()
            }) { [weak self] (finish:Bool)in
                self!.userInteractionEnabled = true
                if self?.searchText == nil || self?.searchText == ""{
                    self!.textField.placeholder = self!.placeHodlerString
                }else{
                    self?.textField.text = self?.searchText!
                }
                
                self?.label.hidden = true
                self?.textField.enabled = true
                self?.textField.becomeFirstResponder()
                self?.delegate?.searchView(self!, didClickWithStatus: self!.enable)
            }
        }else{
            self.cancelB.alpha = 1.0
            self.layoutIfNeeded()
            
            if self.searchText == nil || self.searchText == ""{
                self.textField.placeholder = self.placeHodlerString
            }else{
                self.textField.text = self.searchText!
            }
            
            self.label.hidden = true
            self.textField.enabled = true
            self.textField.becomeFirstResponder()
            self.delegate?.searchView(self, didClickWithStatus: self.enable)
        }
    }
    
    private func moveToRightWithAnimated(animated:Bool){
        self.textField.resignFirstResponder()
        self.label.hidden = false
        self.label.text = (searchText == nil || searchText == "") ? placeHodlerString : searchText!
        self.textField.placeholder = nil
        self.textField.text = nil
        self.textField.enabled = false
        
        
        label.mas_remakeConstraints(){[weak self] in
            $0.center.equalTo()(self)
        }
        
        textField.mas_remakeConstraints(){[weak self] in
            $0.edges.equalTo()(self)
        }
        
        if animated{
            self.userInteractionEnabled = false
            UIView.animateWithDuration(Double(duration), animations: { [weak self] in
                self?.cancelB.alpha = 0.0
                self?.layoutIfNeeded()
            }) { [weak self] in
                if $0 {
                    self!.userInteractionEnabled = true
                    self!.delegate?.searchView(self!, didClickWithStatus: self!.enable)
                }
            }
        }else{
            self.cancelB.alpha = 0.0
            self.layoutIfNeeded()
            self.delegate?.searchView(self, didClickWithStatus: self.enable)
        }
    }
    
    
    
    override static func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    override func updateConstraints() {
        cancelB.mas_makeConstraints(){[unowned self] in
            $0.centerY.equalTo()(self.cancelB.superview?.mas_centerY)
            $0.right.equalTo()(self.cancelB.superview?.mas_right).with().offset()(-8)
        }
        
        textField.mas_makeConstraints(){[unowned self] in
            $0.edges.equalTo()(self)
        }
        
        label.mas_makeConstraints(){
            $0.center.equalTo()(self)
        }
        
        imageV.mas_makeConstraints(){[unowned self] in
            $0.centerY.equalTo()(self.label.mas_centerY)
            $0.right.equalTo()(self.label.mas_left).with().offset()(-8)
        }
        
        super.updateConstraints()
    }

    /**
     重置搜索的文本
     
     - parameter newText: 搜索文本
     */
    func resetSearchText(newText:String?){
        searchText = newText
        self.label.text = (searchText == nil || searchText == "") ? placeHodlerString : searchText!
    }
    
}
