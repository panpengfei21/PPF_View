//
//  publicationContentView.swift
//  YanXiuWang
//
//  Created by Liuming Qiu on 2017/3/3.
//  Copyright © 2017年 ZW. All rights reserved.
//

import UIKit
import Masonry

protocol PublicationContentView_delegate:class {
    func publicationContentView(pcv:PublicationContentView,didSelectedImageAndText it:Publication_ImageAndText,with imagePath:String)
    func publicationContentView(pcv:PublicationContentView,didSelectedLinker linker:Publication_linker)
    func publicationContentView(pcv:PublicationContentView,didSelectedResource resource:Publication_resource)
}

class PublicationContentView: UIView {
    
    
    /// 单张图片时,最大的尺寸
    let singleImageMaxSize:CGFloat = 100
    
    /// 多张图片的默认尺寸
    let multipleImagesDefaultsSize:CGFloat = 72
    
    let linkerImageViewDefaultsSize:CGFloat = 42
    
    /// 边距
    let edge:CGFloat = 4
    /// 图片之间的距离
    let imagesSpace:CGFloat = 5
    var delegate:PublicationContentView_delegate?
    
    weak var label:UILabel?
    var imageVs:[UIImageView]?
    weak var imageV:UIImageView?

    var publication:PPFPublication!
    init(publication:PPFPublication?){
        self.publication = publication
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        if let pub = publication{
            updateUI(pub)
        }
    }
    convenience init(){
        self.init(publication: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateUI(publication:PPFPublication){
        self.publication = publication
        resetUI()
        
        switch publication.type {
        case .onlyText:
            label?.text = publication.imageAndText?.text

        case .onlyImage:
            if let iv = imageVs where !iv.isEmpty{
                let urls = publication.imageAndText!.imagePaths!.flatMap(){
                    return NSURL(string: $0)
                }
                
                assert(urls.count == iv.count)
                
                for i in 0 ..< iv.count{
                    iv[i].yy_setImageWithURL(urls[i], placeholder: UIImage(named: "P4-2_defaultImage"))
                }
            }
        case .imageAndText:
            label?.text = publication.imageAndText?.text
            if let iv = imageVs where !iv.isEmpty{
                let urls = publication.imageAndText!.imagePaths!.flatMap(){
                    return NSURL(string: $0)
                }
                
                assert(urls.count == iv.count)
                
                for i in 0 ..< iv.count{
                    iv[i].yy_setImageWithURL(urls[i], placeholder: UIImage(named: "P4-2_defaultImage"))
                }
            }
        case .linker:
            label!.text = publication.linker?.title
            let url = NSURL(string: publication.linker?.avatarPath ?? "")
            imageV!.yy_setImageWithURL(url, placeholder: UIImage(named: "P4-P3-1_link"))

        case .resource:
            label!.text = publication.resource?.title
            let url = NSURL(string: publication.resource?.avatarPath ?? "")
            imageV!.yy_setImageWithURL(url, placeholder: UIImage(named: "P4-2_asset"))
            
        }
        
    }
    
    private func resetUI(){
        switch publication.type {
        case .onlyText:
            self.backgroundColor = UIColor.whiteColor()
            removeUnnecessaryView(imageV,viewArray:&imageVs)
            if label == nil{
                label = {
                   let l = UILabel()
                    l.textColor = UIColor.blackColor()
                    l.font = UIFont.systemFontOfSize(15)
                    l.numberOfLines = 0
                    self.addSubview(l)
                    return l
                }()
            }
            label?.mas_remakeConstraints(){
                $0.edges.equalTo()(self)
            }
        case .onlyImage:
            self.backgroundColor = UIColor.whiteColor()
            var tem:[UIView]?
            removeUnnecessaryView(label,imageV,viewArray:&tem)
            configureImageViews(self.mas_top)
        case .imageAndText:
            self.backgroundColor = UIColor.whiteColor()
            var tem:[UIView]?
            removeUnnecessaryView(imageV,viewArray:&tem)
            if label == nil{
                label = {
                    let l = UILabel()
                    l.textColor = UIColor.blackColor()
                    l.font = UIFont.systemFontOfSize(15)
                    self.addSubview(l)
                    return l
                }()
            }
            label!.numberOfLines = 0
            label?.mas_remakeConstraints(){
                $0.top.leading().and().trailing().equalTo()(self)
            }
            configureImageViews(self.label!.mas_bottom)

        case.linker,.resource:
            self.backgroundColor = colorWithHex(0xf0f0f2)
            removeUnnecessaryView(viewArray: &imageVs)
            if imageV == nil{
                imageV = {
                    let iv = UIImageView()
                    iv.clipsToBounds = true
                    iv.userInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: #selector(PublicationContentView.tapOnImage(_:)))
                    iv.addGestureRecognizer(tap)
                    self.addSubview(iv)
                    return iv
                }()
            }
            if label == nil{
                label = {
                    let l = UILabel()
                    l.textColor = UIColor.blackColor()
                    l.font = UIFont.systemFontOfSize(15)
                    self.addSubview(l)
                    return l
                }()
            }
            label!.numberOfLines = 2
            configureLinkerUI()
        }
    }
    
    
    /// 移除多余的view
    private func removeUnnecessaryView<T:UIView>(views:T?...,inout viewArray:[T]?){
        for view in views{
            view?.removeFromSuperview()
        }
        if viewArray != nil{
            for _ in 0 ..< viewArray!.count{
                viewArray!.removeLast().removeFromSuperview()
            }
            
        }
        
    }
    
    
    
    /// 配置 位置
    private func configureLinkerUI(){
        guard let iv = imageV,let la = label else {
            fatalError()
        }
        iv.mas_remakeConstraints(){
            $0.top.and().leading().equalTo()(self).offset()(self.edge)
            $0.bottom.equalTo()(self).offset()(-self.edge).priority()(100)
            $0.width.equalTo()(self.linkerImageViewDefaultsSize)
            $0.height.equalTo()(self.linkerImageViewDefaultsSize)
        }
        la.mas_remakeConstraints(){
            $0.top.and().bottom().equalTo()(iv)
            $0.trailing.equalTo()(self).offset()(-self.edge)
            $0.leading.equalTo()(iv.mas_trailing).offset()(self.edge)
        }
    }
    
    
    /// 配置图片数组的位置
    ///
    /// - Parameter topView: 图片的上部位置的view
    private func configureImageViews(topAttri:MASViewAttribute){
        guard let imagePaths = publication.imageAndText?.imagePaths else{
            fatalError()
        }
        if imageVs == nil{
            imageVs = []
        }
        
        for i in 0 ..< imageVs!.count{
            assert(imageVs![i].superview != nil)
        }
        
        // 1:让image view 和 image path的数量相等
        let diff = imagePaths.count - imageVs!.count
        if diff > 0{
            for _ in 0 ..< diff{
                let iv = UIImageView()
                iv.clipsToBounds = true
                iv.frame.size = CGSize(width: 72, height: 72)
                iv.userInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(PublicationContentView.tapOnImageArray(_:)))
                iv.addGestureRecognizer(tap)
                self.addSubview(iv)
                imageVs!.append(iv)
            }
        }else if diff < 0{
            for _ in 0 ..< -diff{
                imageVs!.removeLast().removeFromSuperview()
            }
        }
        
        for i in 0 ..< imageVs!.count{
            assert(imageVs![i].superview != nil)
        }

        guard let ivs = imageVs where !ivs.isEmpty && ivs.count <= 9 else{
            fatalError()
        }
        
        
        
        // 2:配置imageView 位置
        if ivs.count <= 3{
            configureSubImageViews(topAttri, views: ivs[0 ..< ivs.count].flatMap{$0},addBottomConstraint: true)
        }else if ivs.count <= 6{
            configureSubImageViews(topAttri, views: ivs[0 ..< 3].flatMap{$0},addBottomConstraint: false)
            configureSubImageViews(ivs[0].mas_bottom, views: ivs[3 ..< ivs.count].flatMap{$0},addBottomConstraint: true)
        }else{
            configureSubImageViews(topAttri, views: ivs[0 ..< 3].flatMap{$0},addBottomConstraint: false)
            configureSubImageViews(ivs[0].mas_bottom, views: ivs[3 ..< 6].flatMap{$0},addBottomConstraint: false)
            configureSubImageViews(ivs[3].mas_bottom, views: ivs[6 ..< ivs.count].flatMap{$0},addBottomConstraint: true)
        }
    }
    
    
    /// 配置子视图一行的image view
    ///
    /// - Parameters:
    ///   - topAttri: 顶部的约束
    ///   - views: views description
    private func configureSubImageViews(topAttri:MASViewAttribute,views:[UIView],addBottomConstraint:Bool){
        for i in 0 ..< views.count{
            if i == 0 {
                views[i].mas_remakeConstraints(){
                    $0.top.equalTo()(topAttri).offset()(self.edge)
                    $0.leading.equalTo()(self.mas_leading).offset()(self.edge)
                    $0.width.equalTo()(self.multipleImagesDefaultsSize)
                    $0.height.equalTo()(self.multipleImagesDefaultsSize)
                    if addBottomConstraint{
                        $0.bottom.equalTo()(self.mas_bottom).offset()(-self.edge).priority()(100)
                    }
                }
            }else{
                views[i].mas_remakeConstraints(){
                    $0.centerY.equalTo()(views[i - 1].mas_centerY)
                    $0.width.equalTo()(self.multipleImagesDefaultsSize)
                    $0.height.equalTo()(self.multipleImagesDefaultsSize)
                    $0.leading.equalTo()(views[i - 1].mas_trailing).offset()(self.imagesSpace)
                }
            }
        }
    }
}


// MARK: - 交互
extension PublicationContentView{
    func tapOnImageArray(tap:UITapGestureRecognizer){
        guard  let iv = tap.view as? UIImageView else {
            fatalError()
        }
        guard  let index = imageVs?.indexOf(iv) else {
            fatalError()
        }
        guard let path = publication.imageAndText?.imagePaths?[index] else{
            fatalError()
        }
        delegate?.publicationContentView(self, didSelectedImageAndText: publication.imageAndText!, with: path)
    }
    func tapOnImage(tap:UITapGestureRecognizer){
        switch publication.type {
        case .linker:
            delegate?.publicationContentView(self, didSelectedLinker: publication.linker!)
        case .resource:
            delegate?.publicationContentView(self, didSelectedResource: publication.resource!)
        default:
            fatalError()
        }
    }
}
