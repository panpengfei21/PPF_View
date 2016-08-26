//
//  RollingShowView.swift
//  ZhangShi
//
//  Created by Liuming Qiu on 16/7/4.
//  Copyright © 2016年 ZW. All rights reserved.
//

import UIKit
import Masonry
import YYWebImage

protocol RollingShowView_delegate:class {
    func rollingShowView(rv:RollingShowView,clickWithIndex index:Int)
}

class RollingShowView: UIView {

    /**
     滑动的方向
     
     - Left:  左滑
     - Right: 右滑
     */
    enum swipDirection {
        case Left
        case Right
    }
    // MARK: - 数据
    /// 动画时长
    var animationDuration:Double = 0.5
    /// 占位图名称
    var placeholderName = "p1-lunbo"
    /// 图片的URL
    private var imageURLs:[String]!
    var index:Int = 0 {
        didSet{
            indexView?.index = index
        }
    }
    /// 代理
    weak var delegate:RollingShowView_delegate?
    
    // MARK: - UI
    var imageViewContentMode:UIViewContentMode = UIViewContentMode.ScaleToFill
        /// 动画的容器,要切换的动画view都放在这个里面.
    var container:UIView!
        /// 展示的imageView
    var showImageView:UIImageView!
        /// 索引view
    var indexView:IndexView!
    
    weak var timer:NSTimer!
    /// 当手动切换时,计时器切换无效
    private var timerIsValid = true;

    
    // MARK: - 初始化
    
    /**
     设置展示的image view
     */
    private func setupUI(){
        guard imageURLs != nil else{
            return
        }
        guard imageURLs.count > 0 else{
            return
        }
        
        if container == nil{
            container = UIView()
            self.addSubview(container)
        }
        if showImageView == nil{
            showImageView = UIImageView()
            showImageView.contentMode = imageViewContentMode
            showImageView?.userInteractionEnabled = true
            showImageView.clipsToBounds = true
            container.addSubview(showImageView)
        }
        
        if !imageURLs.isEmpty {
            let url = NSURL(string: imageURLs![index])
            showImageView?.yy_setImageWithURL(url, placeholder: UIImage(named:placeholderName))
        }else{
            print("imageURLs 没有数据")
        }
        
        if (indexView == nil) || (indexView?.total != imageURLs?.count){
            indexView?.removeFromSuperview()
            indexView = IndexView(amountOfIndexs: imageURLs.count, index: index)
            self.addSubview(indexView)
            self.setNeedsUpdateConstraints()
        }
        addGesture()
        
        if timer == nil && imageURLs.count > 1{
            timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(RollingShowView.repeatForTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    /**
     添加手势
     */
    func addGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(RollingShowView.tap(_:)))
        showImageView?.addGestureRecognizer(tap)
        
        if imageURLs.count > 1{
            let lSwip = UISwipeGestureRecognizer(target: self, action: #selector(RollingShowView.swip(_:)))
            lSwip.direction = .Left
            self.addGestureRecognizer(lSwip)
            
            let rSwip = UISwipeGestureRecognizer(target: self, action: #selector(RollingShowView.swip(_:)))
            rSwip.direction = .Right;
            self.addGestureRecognizer(rSwip)
        }
    }
    
    // MARK: - 约束
    override class func requiresConstraintBasedLayout() -> Bool{
        return true
    }
    override func updateConstraints() {
        container?.mas_remakeConstraints(){[weak self] in
            $0.edges.equalTo()(self)
        }
        showImageView?.mas_remakeConstraints{[weak weakSelf =  self] in
            $0.edges.equalTo()(weakSelf?.container)
        }
        
        indexView?.mas_remakeConstraints(){[weak self] in
            $0.centerX.equalTo()(self!.mas_centerX)
            $0.bottom.equalTo()(self?.mas_bottom).with().setOffset(-8)
            $0.width.equalTo()(self?.indexView.bounds.width)
            $0.height.equalTo()(self?.indexView.bounds.height);
        }
        super.updateConstraints()
    }
    
    // MARK: - 手势
    func swip(swip:UISwipeGestureRecognizer){
        timerIsValid = false
        switch swip.direction {
        case UISwipeGestureRecognizerDirection.Right:
            transitionViewWithDirection(RollingShowView.swipDirection.Right)
        case UISwipeGestureRecognizerDirection.Left:
            transitionViewWithDirection(RollingShowView.swipDirection.Left)
        default:
            print("error")
        }
    }
    
    func tap(tap:UITapGestureRecognizer){
        delegate?.rollingShowView(self, clickWithIndex: index)
    }
    // MARK: - 数据处理
    
    func setupUIWithPaths(urlPaths path:[String]?){
        imageURLs = path;
        index = 0
        setupUI()
    }
    
    // MARK: - UI 处理
    func repeatForTimer(timer:NSTimer){
        if timerIsValid{
            transitionViewWithDirection(RollingShowView.swipDirection.Left)
        }
    }
    
    /**
     切换View
     
     - parameter dir: 方向
     */
    func transitionViewWithDirection(dir:swipDirection){
        var i = index
        switch dir {
        case .Left:
            i += 1;
            if i >= imageURLs.count{
                i = 0;
            }
        case .Right:
            i -= 1;
            if i < 0{
                i = imageURLs.count - 1
            }
        }
        

        let option = dir == swipDirection.Left ? UIViewAnimationOptions.TransitionCurlUp : UIViewAnimationOptions.TransitionCurlDown
        UIView.transitionWithView(showImageView, duration: self.animationDuration, options: [option,.BeginFromCurrentState], animations: {
            self.showImageView.yy_setImageWithURL(NSURL(string: self.imageURLs[i]), placeholder: UIImage(named:self.placeholderName))
            }, completion: { (finish) in
                self.index = i;
                self.timerIsValid = true
        })
        
    }

    
    /**
     计时器暂停
     */
    func timerPause() {
        timer?.fireDate = NSDate.distantFuture()
    }
    /**
     计时器继续
     */
    func timerReplay(){
        timer?.fireDate = NSDate.distantPast()
    }
    
}
