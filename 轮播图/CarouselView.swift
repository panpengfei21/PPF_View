//
//  CarouselView.swift
//  CollectionV
//
//  Created by Liuming Qiu on 2017/3/22.
//  Copyright © 2017年 ZW. All rights reserved.
//

import UIKit

protocol CarouselView_delegate:class {
    func carouselView(cv:CarouselView,registerFor collectionView:UICollectionView)
    func carouselView(cv:CarouselView,numberOfItemsIn collectionView:UICollectionView) -> Int
    func carouselView(cv:CarouselView,collectionView:UICollectionView,cellForItemAt indexPath:IndexPath) -> UICollectionViewCell
    func carouselView(cv:CarouselView,collectionView:UICollectionView, didSelectItemAt indexPath: IndexPath)
    func carouselViewWillBeginDragging(cv:CarouselView)
    func carouselViewWillEndDragging(cv:CarouselView)
}


class CarouselView: UIView, Nextable{

    /// 显示图片可变的边的长度,,水平滚动的话是宽,垂直滚动是高
    fileprivate var imageViewSide:CGFloat!
    /// 滚动方向 默认是水平
    fileprivate var scrollDirection = UICollectionViewScrollDirection.horizontal
    /// item 之间的距离
    private var itemSpace:CGFloat = 1
    /// 当前的索引
    var currentIndex:Int = 0{
        didSet{
            indexView?.index = currentIndex
        }
    }
    /// 要显示的内容
    weak var collectionView:UICollectionView!
    
    /// 索引
    weak var indexView:IndexView?
    /// 代理
    weak var delegate:CarouselView_delegate!
        
    init(frame: CGRect,imageViewSide:CGFloat,scrollDirection:UICollectionViewScrollDirection = .horizontal) {
        super.init(frame: frame)
        initialize(imageViewSide: imageViewSide,scrollDirection:scrollDirection)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize(imageViewSide: bounds.width)
    }
    
    
    /// 初始化
    ///
    /// - Parameters:
    ///   - imageViewSide: 图的尺寸
    ///   - scrollDirection: 滚动方向
    private func initialize(imageViewSide:CGFloat,scrollDirection:UICollectionViewScrollDirection = .horizontal){
        self.scrollDirection = scrollDirection
        self.imageViewSide = imageViewSide
        createView()
        addConstraints()
    }
    
    
    /// 创建视图
    private func createView(){
        if collectionView == nil{
            collectionView = {
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = self.scrollDirection
                var edgeInsets = UIEdgeInsets.zero
                switch layout.scrollDirection{
                case .horizontal:
                    
                    layout.minimumInteritemSpacing = itemSpace
                    layout.itemSize = CGSize(width: self.imageViewSide, height: bounds.height)
                    edgeInsets.left = (bounds.width - self.imageViewSide) / 2
                    edgeInsets.right = edgeInsets.left
                case .vertical:
                    layout.minimumLineSpacing = itemSpace
                    layout.itemSize = CGSize(width: bounds.width, height: self.imageViewSide)
                    edgeInsets.top = (bounds.height - self.imageViewSide) / 2
                    edgeInsets.bottom = edgeInsets.top
                }
                layout.sectionInset = edgeInsets
                
                let cv = UICollectionView(frame: bounds, collectionViewLayout: layout)
                cv.showsVerticalScrollIndicator = false
                cv.showsHorizontalScrollIndicator = false
                cv.delegate = self
                cv.dataSource = self
                cv.backgroundColor = UIColor.gray
                cv.translatesAutoresizingMaskIntoConstraints = false
                
                self.addSubview(cv)
                return cv
            }()
        }
    }
    
    
    /// 加约束
    private func addConstraints(){
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    
    /// 注册collection view 的复用 cell
    public func register(){
        guard let del = self.delegate else{
            fatalError("carouel view 的 delegate 没有设置")
        }
        del.carouselView(cv: self, registerFor: collectionView)
    }
    
    
    /// 重载数据
    public func reload(){
        collectionView.reloadData()
    }
    
    
    /// 到下一个cell
    public func next(){
        let number = collectionView.numberOfItems(inSection: 0)
        guard  number > 1 else{
            return
        }
        var target:Int
        if number - 1 == currentIndex {
            target = 0
        }else{
            target = currentIndex + 1
        }
        currentIndex = target
        let indexPath = IndexPath(item: target, section: 0)
        let position:UICollectionViewScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        collectionView.scrollToItem(at: indexPath, at: position, animated: true)
    }
    
}


extension CarouselView:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let del = delegate else{
            fatalError("carouel view 的 delegate 没有设置")
        }
        return del.carouselView(cv: self, numberOfItemsIn: collectionView)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let del = delegate else{
            fatalError("carouel view 的 delegate 没有设置")
        }
        return del.carouselView(cv: self, collectionView: collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.carouselView(cv: self, collectionView: collectionView, didSelectItemAt: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate.carouselViewWillBeginDragging(cv: self)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate.carouselViewWillEndDragging(cv: self)
        let offset = scrollView.contentOffset
        let center = CGPoint(x: offset.x + bounds.width / 2, y: offset.y + bounds.height / 2)
        var visiCell = collectionView.visibleCells
        guard visiCell.count > 0 else{
            return
        }
        visiCell.sort(){
            let indexPath0 = collectionView.indexPath(for: $0)!
            let indexPath1 = collectionView.indexPath(for: $1)!
            return indexPath0.row < indexPath1.row
        }
        
        let cell = visiCell.filter(){
            return $0.frame.contains(center)
        }
        let originCell:UICollectionViewCell
        if velocity == CGPoint.zero{//无加速时,谁在中间就到谁那里,或到排在第一个的cell那里
            if cell.count == 1{
                originCell = cell.first!
            }else{
                originCell = visiCell.first!
            }
        }else{// 有加速时,正加速:就到可见cell的最后一个,负加速就到可见cell的第一个
            var isFirst:Bool
            switch scrollDirection {
            case .horizontal:
                isFirst = velocity.x < 0
            case .vertical:
                isFirst = velocity.y < 0
            }
            originCell = isFirst ? visiCell.first! : visiCell.last!
        }
        currentIndex = collectionView.indexPath(for: originCell)!.row
        let origin = originCell.frame.origin

        var targetPoint:CGPoint
        switch self.scrollDirection {
        case .horizontal:
            targetPoint = CGPoint(x: origin.x - (bounds.width - imageViewSide) / 2, y: 0)
        case .vertical:
            targetPoint = CGPoint(x: 0, y: origin.y - (bounds.height - imageViewSide) / 2)
        }
        targetContentOffset.initialize(from: [targetPoint])
    }
    
    
}




















