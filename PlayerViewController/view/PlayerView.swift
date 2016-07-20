//
//  PlayerView.swift
//  ZhangShi
//
//  Created by Liuming Qiu on 16/7/14.
//  Copyright © 2016年 ZW. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    var player:AVPlayer?{
        get{
            return (self.layer as? AVPlayerLayer)?.player
        }
        set{
            (self.layer as? AVPlayerLayer)?.player = newValue
        }
    }
    

    override class func layerClass() -> AnyClass{
        return AVPlayerLayer.classForCoder()
    }
    
    func setupPlayerWithVideo(video:Video_M){
        guard let url = NSURL(string: video.playURL)else{
            return
        }
        let item = AVPlayerItem(URL: url)
        player = AVPlayer(playerItem: item)
        (self.layer as? AVPlayerLayer)
    }
}
