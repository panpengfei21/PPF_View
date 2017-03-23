//
//  ViewController.swift
//  CollectionV
//
//  Created by Liuming Qiu on 2017/3/21.
//  Copyright © 2017年 ZW. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    var timer:CarouselTimer!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let carousel = CarouselView(frame: CGRect(x: 10, y: 20, width: 200, height: 300),imageViewSide:200,scrollDirection:.horizontal)
        carousel.delegate = self
        carousel.register()
        view.addSubview(carousel)
        
        let indexV = IndexView(amountOfIndexs: 10)
        carousel.addSubview(indexV!)
        carousel.indexView = indexV
        
        timer = CarouselTimer()
        timer.next = carousel
        timer.start()
    }
    deinit {
        timer.stop()
    }
}

extension DemoViewController:CarouselView_delegate{
    func carouselView(cv: CarouselView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
    }
    func carouselViewWillBeginDragging(cv: CarouselView) {
        timer.pause()
    }

    func carouselViewWillEndDragging(cv:CarouselView){
        timer.resume()
    }

    func carouselView(cv: CarouselView, registerFor collectionView: UICollectionView) {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "reuse cell")
    }
    func carouselView(cv: CarouselView, numberOfItemsIn collectionView: UICollectionView) -> Int {
        return 10
    }
    func carouselView(cv: CarouselView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuse cell", for: indexPath)
        if cell.contentView.subviews.count == 0{
            cell.contentView.backgroundColor = UIColor.red
            let label = UILabel()
            cell.contentView.addSubview(label)
        }
        let label = cell.contentView.subviews.first! as! UILabel
        label.text = "indexPath:\(indexPath)"
        label.sizeToFit()
        
        return cell
    }
}

