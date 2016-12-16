//
//  SelectView.swift
//  wzer
//
//  Created by apple on 15/11/17.
//  Copyright © 2015年 ZYXiao_. All rights reserved.
//  滑动选项
//  1.实现单行文字多项文字之间的滑动选择
//  2.如果只有单个选项，只会出现显示的作用

import UIKit
@objc  protocol SelectView_delegate{
    @objc optional func selectView(sv:SelectView,willSelectTitle st:String)
    @objc optional func selectView(sv:SelectView,didSelectTitle st:String)
}

//@IBDesignable
class SelectView: UIView {
    // MARK: - property
    
    /// 滑条和选中字的颜色
    @IBInspectable
    var svSelectmainColor:UIColor = UIColor.blue{
        didSet{
            slider?.backgroundColor = svSelectmainColor
            bottomView?.backgroundColor = svSelectmainColor
            setColorOfButtonTitleWithIndex(index: currentIndex)
        }
    }
    /// 动画持续时间
    var animationDuration = 0.25
    @IBInspectable
    var svUnselectedTextColor:UIColor = UIColor.black
    /// 字体
    var svFont:UIFont = UIFont.systemFont(ofSize: 15)
    
    /// 选择项的 几个选项。
    @IBInspectable
    var itemsStr:String = ""{
        didSet{
//            items = itemsStr.componentsSeparatedByString(",")
            items = itemsStr.components(separatedBy: ",")
        }
    }
    
    var items:[String] = ["无"]
    ///滑条
    var slider:UIView?
    
    /// 底部的一条细线
    var bottomView:UIView?
    
    ///当前选项
    var currentIndex:Int = 0 {
        didSet{
            if currentIndex != oldValue{
                unselectButtonWithIndex(index: oldValue)
                selectButtonWithIndex(index: currentIndex)
            }
        }
    }
    ///选项按钮的集合
    var itemsButton = [UIButton]()

    ///代理
    weak var delegate:SelectView_delegate?
    
    // MARK:初始化
    init (frame:CGRect,withItems items:[String],withColor c:UIColor = UIColor.blue){
        svSelectmainColor = c
        self.items = items
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUIWithItems(items: items)
    }
    // MARK: - UI 变化
    
    func setupUIWithItems(items:[String]){
        guard !items.isEmpty else{
            print("items 的数量为零。")
            return
        }
        for v in subviews{
            v.removeFromSuperview()
        }
        self.items = items
        initUIWithRect(rect: frame)
    }
    private func initUIWithRect(rect:CGRect){
        guard items.count > 0 else {
            print("items 的数量为零。")
            return
        }
        //下面的加一条细横线。
        let bVLineFrame = CGRect(x: 0, y: rect.maxY - 1.0, width: rect.width, height: 1.0)
        bottomView = UIView(frame: bVLineFrame)
        bottomView!.backgroundColor = svSelectmainColor
        self.addSubview(bottomView!)
        
        // 加显示的label 或 button
        if items.count == 1 {
            let label = UILabel()
            label.text = items.first!
            label.textColor = svSelectmainColor
            label.font = svFont
            label.sizeToFit()
            label.center.y = rect.midY
            label.frame.origin.x = 10
            self.addSubview(label)
        }
        else{
            itemsButton = []
            
            let stepDistance:CGFloat = rect.width / CGFloat(items.count)
            for i in 0 ..< items.count{
                let buFrame = CGRect(x: CGFloat(i) * stepDistance, y: 0, width: stepDistance, height: rect.height)
                let button = UIButton(frame: buFrame)
                
                let attributes = [NSFontAttributeName:svFont,
                    NSForegroundColorAttributeName:svUnselectedTextColor] as [String : Any]
                let buAString = NSAttributedString(string: items[i], attributes: attributes)
                button.setAttributedTitle(buAString, for: UIControlState.normal)
                button.addTarget(self, action: #selector(SelectView.tapButton), for: UIControlEvents.touchUpInside)
                
                self.addSubview(button)
                itemsButton.append(button)
            }
            selectButtonWithIndex(index: currentIndex)
            //滑条
            let sliderHeight:CGFloat = 2.0
            let sliderFrame = CGRect(x: 0, y: rect.size.height - sliderHeight, width: 0.65 * stepDistance, height: sliderHeight)
            slider = UIView(frame: sliderFrame)
            slider?.backgroundColor = svSelectmainColor
            slider?.center.x = self.itemsButton[currentIndex].center.x
            self.addSubview(slider!)
        }
    }
    
    /**
     设置选中状态的button的title的颜色。
     
     - parameter index: 索引
     */
    private func setColorOfButtonTitleWithIndex(index:Int){
        guard (0 ..< itemsButton.count).contains(index) else{
            return
        }
        if let attr0 = itemsButton[index].currentAttributedTitle{
            let attr = NSMutableAttributedString(attributedString: attr0)
            attr.addAttribute(NSForegroundColorAttributeName, value: svSelectmainColor, range: NSRange(location: 0, length: attr.length))
            
            itemsButton[index].setAttributedTitle(attr, for: UIControlState.normal)
        }
    }
    
    ///点击按钮
    func tapButton(sender:UIButton){
        for i in 0 ..< itemsButton.count{
            if sender === itemsButton[i]{
                currentIndex = i
                break
            }
        }
    }
    
    ///选择一个按钮
    private func selectButtonWithIndex(index:Int) {
        guard index < itemsButton.count && index >= 0 else {
            print("index 超出范围")
            return
        }
        setColorOfButtonTitleWithIndex(index: index)
        
        self.delegate?.selectView?(sv: self, willSelectTitle: self.items[index])
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.curveEaseInOut, animations: { [unowned self] in
                self.slider?.center.x = self.itemsButton[index].center.x
            }){[unowned self] in
                if $0 {
                    self.delegate?.selectView?(sv:self, didSelectTitle: self.items[index])
                }
        }
        
    }
    
    ///不选择一个选钮
    private func unselectButtonWithIndex(index:Int){
        guard index < itemsButton.count && index >= 0 else {
            print("index 超出范围")
            return
        }
        if let attr0 = itemsButton[index].currentAttributedTitle{
            let attr = NSMutableAttributedString(attributedString: attr0)
            attr.addAttribute(NSForegroundColorAttributeName, value: svUnselectedTextColor, range: NSRange(location: 0, length: attr.length))

            itemsButton[index].setAttributedTitle(attr, for: UIControlState.normal)
        }
    }
}




