//
//  PlayerViewController.swift
//  ZhangShi
//
//  Created by Liuming Qiu on 16/7/14.
//  Copyright © 2016年 ZW. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AFNetworking

class PlayerViewController: UIViewController {
    // <测试！以下的可能要删除或修改<<<<<<<
//    let urlPath = "http://play13.68mtv.com/play13/60400.mp4"
    let urlPath = "http://play.68mtv.com:8080/play3/45048.mp4"
    // >>>>>>>>

        /// 播放内容的观察环境
    static var itemContext:String = "ItemStatusContext"
    // MARK: -  UI
        /// 播放View
//    @IBOutlet weak var playerContainerV: UIView!
//    @IBOutlet weak var playerV: PlayerView!
    weak var playerContainerV: UIView!
    weak var playerV: PlayerView!
    weak var playerControllerV:PlayerControllerView!
    
    var volumeView:MPVolumeView!
    var volumeSlider:UISlider!
    
    
    // MARK: - property
        /// 视频资料
    var video:Video_M!
        /// 播放哭
    var player:AVPlayer?
        /// 要播放的内容
    var playerItem:AVPlayerItem?
        /// 周期性观察器  1秒观察一次
    var periodicTimeObserverForInterval:AnyObject?
        /// 竖屏
    var portraitOrientation = true

        ///  在后台
    var inBackground = false
    
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let barButton = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PlayerViewController.back))
        self.navigationItem.leftBarButtonItem = barButton
        // Do any additional setup after loading the view.
        self.title = video.name
        
        // <测试！以下的可能要删除或修改<<<<<<<
        video = Video_M(id: "dd", category: "fds", playURL: urlPath)
        // >>>>>>>>
        
        setupUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        
        self.playerControllerV.loadingVideo(true, changeBarHidden: false)
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock {[weak self] (status:AFNetworkReachabilityStatus) in
            switch status{
            case .Unknown:
                self?.playerControllerV.errorText = "网络连接:未知状态"
            case .NotReachable:
                self?.playerControllerV.errorText = "网络连接:无网络连接"
            case .ReachableViaWWAN:
                if videoForWifiOnly{
                    self?.playerControllerV.errorText = "网络连接:您设置了只在WIFI环境下观看,如要更改请到'我的学习'->'设置'里更改."
                }else{
                    fallthrough
                }
            case .ReachableViaWiFi:
                self?.setupPlayerWithVideo(self?.video)
            }
        }
        
        
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        pause()
        AFNetworkReachabilityManager.sharedManager().stopMonitoring()
        removeObserver()
    }
    // MARK: - 系统自带的UI处理
    override func updateViewConstraints() {
        if portraitOrientation {
            self.playerContainerV.mas_remakeConstraints(){[weak self] in
                $0.leading.trailing().and().top().equalTo()(self?.view)
                $0.width.equalTo()(self?.playerContainerV.mas_height).multipliedBy()(750.0 / 460.0)
            }
        }else{
            self.playerContainerV.mas_remakeConstraints(){[weak self] in
                $0.center.equalTo()(self?.view)
                $0.width.equalTo()(UIScreen.mainScreen().bounds.height)
                $0.height.equalTo()(UIScreen.mainScreen().bounds.width)
            }
        }
        
        
        self.playerV.mas_remakeConstraints(){[weak self] in
            $0.edges.equalTo()(self?.playerContainerV)
        }
        
        self.playerControllerV.mas_remakeConstraints(){[weak self] in
            $0.edges.equalTo()(self?.playerContainerV)
        }
        
        super.updateViewConstraints()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return !portraitOrientation
    }
    
    // MARK: - UI 处理
    
    /**
     播放器变大或变小(横屏或竖屏)
     
     - parameter big: 是否变大
     */
    func playerChangeBig(big:Bool) {
        guard portraitOrientation != !big else{
            return
        }
        portraitOrientation = !big
        self.navigationController?.setNavigationBarHidden(!portraitOrientation, animated: true)
        
        UIView.animateWithDuration(Double(UINavigationControllerHideShowBarDuration), animations: {[weak self] in
            self?.playerContainerV.transform = CGAffineTransformRotate(self!.playerContainerV.transform, CGFloat(big ? M_PI_2 : -M_PI_2))
            self?.view.layoutIfNeeded()
            }) { [weak self](finish) in
                self?.syncLoaderSlider([], onlyRefresh: true)
        }
    }
    

    
    private func setupUI(){
        if self.playerContainerV == nil{
            let v = UIView()
            v.backgroundColor = UIColor.blackColor()
            self.view.addSubview(v)
            self.playerContainerV = v
        }
        if self.playerV == nil{
            let v = PlayerView()
            self.playerContainerV.addSubview(v)
            self.playerV = v
        }
        if self.playerControllerV == nil{
            if let view = NSBundle.mainBundle().loadNibNamed("PlayerControllerView", owner: nil, options: nil).first as? PlayerControllerView{
                self.playerContainerV.addSubview(view)
                self.playerControllerV = view
                self.playerControllerV.delegate = self
            }
        }
        
        /**
         *  @author 潘 鹏飞, 16-07-19 09:07:08
         *
         *  调用系统调节音量的
         */
        if volumeSlider == nil{
            volumeView = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            for v in volumeView.subviews{
                let c = String(v.classForCoder)
                if c == "MPVolumeSlider"{
                    volumeSlider = v as? UISlider
                    break
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    /**
     后退
     */
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }

}
// MARK: - KVO
extension PlayerViewController{
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let kp = keyPath else{
            return super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        switch kp {
        case "status":
            print(change)
            guard let newStatus = change?[NSKeyValueChangeNewKey] as? NSNumber else{
                return
            }
            print("AVPlayerItemStatus.ReadyToPlay.rawValue : \(AVPlayerItemStatus.ReadyToPlay.rawValue)")
            switch newStatus.integerValue {
            case AVPlayerItemStatus.ReadyToPlay.rawValue:
                if !inBackground{
                    self.playerControllerV.loadingVideo(false)
                    if let duration = durationOfPlayerItem(playerItem),c = self.player?.currentTime().seconds{
                        self.playerControllerV.updateTime0And1WithCurrentSeconds(c, duration: duration)
                    }
                }
            case AVPlayerItemStatus.Failed.rawValue:
                print("error:\(player?.error?.localizedDescription)")
            case AVPlayerItemStatus.Unknown.rawValue:
                print("未知:The item’s status is unknown")
            default:
                print("未知状态:\(newStatus)")
            }
        case "error":
            guard let error = change?[NSKeyValueChangeNewKey] as? NSError else{
                return
            }
            playerControllerV.errorText = error.localizedDescription
        case "loadedTimeRanges":
            guard let ranges = change?[NSKeyValueChangeNewKey] as? [NSValue] else{
                return
            }
            syncLoaderSlider(ranges)
        case "seekableTimeRanges":
            guard let seek = change?[NSKeyValueChangeNewKey] as? [NSValue] else{
                return
            }
            print("seek:\(seek)")
        default:
            print("keyPath:\(keyPath)")
        }
    }
    
    /**
     增加通知
     */
    private func addObserver(){
        print(#function)
        playerItem?.addObserver(self, forKeyPath: "status", options: [.New], context: &PlayerViewController.itemContext) //视频状态
        playerItem?.addObserver(self, forKeyPath: "error", options: [.New], context: &PlayerViewController.itemContext) //视频错误信息
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.New], context: &PlayerViewController.itemContext) //已加载的范围
        playerItem?.addObserver(self, forKeyPath: "seekableTimeRanges", options: [.New], context: &PlayerViewController.itemContext) //可以跳转的范围
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerViewController.playerItemDidReachEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem) //播放到最后
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerViewController.playbackStalled(_:)), name: AVPlayerItemPlaybackStalledNotification, object: playerItem) //卡顿时通知
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerViewController.newAccessLogEntry(_:)), name: AVPlayerItemNewAccessLogEntryNotification, object: playerItem) //新的可访问的资源
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerViewController.didEnterBackground(_:)), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerViewController.willEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        
        
        periodicTimeObserverForInterval = player?.addPeriodicTimeObserverForInterval(CMTime(value: 1, timescale: 1),
                                                                                     queue: nil,
                                                                                     usingBlock: { [weak self](time:CMTime) in
                                                                                        guard let cuT = self?.player?.currentTime() else{
                                                                                            return
                                                                                        }
                                                                                        guard let duT = self?.durationOfPlayerItem(self?.playerItem) else{
                                                                                            return
                                                                                        }
                                                                                        let value = Float(cuT.seconds / duT)
                                                                                        self?.playerControllerV.setPlayProgressWithValue(value)
                                                                                        self?.playerControllerV.updateTime0And1WithCurrentSeconds(cuT.seconds, duration: duT)
            })
        
        
    }
    
    
    /**
     移除通知
     */
    private func removeObserver(){
        playerItem?.removeObserver(self, forKeyPath: "status", context: &PlayerViewController.itemContext)
        playerItem?.removeObserver(self, forKeyPath: "error", context: &PlayerViewController.itemContext)
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: &PlayerViewController.itemContext)
        playerItem?.removeObserver(self, forKeyPath: "seekableTimeRanges", context: &PlayerViewController.itemContext)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemPlaybackStalledNotification, object: playerItem)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemNewAccessLogEntryNotification, object: playerItem)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        player?.removeTimeObserver(periodicTimeObserverForInterval!)
    }
    

    
    // MARK: - 通知手柄
    func willEnterForeground(notification:NSNotification){
        print(#function)
        inBackground = false
    }
    func didEnterBackground(notification:NSNotification){
        print(#function)
        inBackground = true
        pause()
    }
    /**
     播放到最后时
     
     - parameter notification: 通知
     */
    func playerItemDidReachEnd(notification:NSNotification){
        player?.seekToTime(kCMTimeZero)
        playerControllerV.setPlayProgressWithValue(0.0)
        playerControllerV.changeStatusWithStatus(.Pause)
    }
    
    func playbackStalled(notification:NSNotification){
        self.playerControllerV.loadingVideo(true,changeBarHidden:false)
    }
    
    /**
     有新的可访问的内容,卡顿过后更新UI
     
     - parameter no:
     */
    func newAccessLogEntry(no:NSNotification){
        self.playerControllerV.loadingVideo(false,changeBarHidden:false)
        self.playerControllerV.updatePlayButton()
        if self.playerControllerV.status == .Playing{
            play()
        }
    }
    
    /**
     同步已加载的进度条
     
     - parameter timeRange: 范围
     */
    func syncLoaderSlider(timeRange:[NSValue],onlyRefresh refresh:Bool = false){
        print(#function)
        if refresh{
            self.playerControllerV.loadedV.syncUI()
            return
        }
        guard let d = durationOfPlayerItem(playerItem) else{
            return
        }
        let tr = timeRange.map(){
            return $0.CMTimeRangeValue
            }.flatMap(){
                $0
        }
        for t in tr{
            let start = t.start
            let duration = t.duration
            
            let sP = start.seconds / d
            let dP = duration.seconds / d
            
            let range = PPFRange(location: sP, length: dP)
            self.playerControllerV.loadedV.addRange(range)
        }
    }

}

// MARK: - player
extension PlayerViewController{
    /**
     设置播放视频
     
     - parameter video: 视频资料
     */
    func setupPlayerWithVideo(video:Video_M?,reset:Bool = false){
        print(#function)
        print("reset:\(reset)")
        guard !videoForWifiOnly || (videoForWifiOnly && AFNetworkReachabilityManager.sharedManager().reachableViaWiFi) else{
            return
        }
        guard let v = video else{
            return
        }
        guard let url = NSURL(string: v.playURL) else{
            return
        }
        if reset{ removeObserver() }
        
        playerItem = AVPlayerItem(URL: url)
        
        if reset{
            player?.replaceCurrentItemWithPlayerItem(playerItem)
            self.playerControllerV.loadingVideo(true)
            self.playerControllerV.errorText = nil
        }else {
            player = AVPlayer(playerItem: playerItem!)
            playerV.player = player
        }
        addObserver()
    }
    
    
    /**
     播放的时长
     
     - parameter pi: AVPlayerItem
     
     - returns: 时长 (秒)
     */
    func durationOfPlayerItem(pi:AVPlayerItem?) -> Double?{
        guard let time = pi?.tracks.first?.assetTrack.asset?.duration else{
            return nil
        }
        return time.seconds
    }

    /**
     播放
     */
    func play(){
        player?.play()
        playerControllerV.changeStatusWithStatus(.Playing)
    }
    /**
     暂停
     */
    func pause(){
        player?.pause()
        playerControllerV.changeStatusWithStatus(.Pause)
    }
    
    /**
     加音量
     */
    func addVolume(){
        if player?.volume != nil {
            if player!.volume < 1.0{
                player!.volume += 0.05
            }else{
                player!.volume = 1
            }
            volumeSlider.setValue(player!.volume, animated: true)
            volumeSlider.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }
    }
    
    /**
     减音量
     */
    func reducesVolume(){
        if player?.volume != nil //&& player?.volume > 0.0
        {
            if player?.volume > 0.0{
                player?.volume  -= 0.05
            }else{
                player?.volume = 0.0
            }
//            player!.volume -= 0.05
            volumeSlider.setValue(player!.volume, animated: true)
            volumeSlider.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }
    }
    
    

    
    /**
     跳转进度
     
     - parameter rate:              跳转的比例
     - parameter completionHandler: 完成手柄
     */
    func seekToRate(rate:Double,completionHandler: ((Bool) -> Void)? = nil){
        guard rate >= 0 && rate < 1 else{
            return
        }
        guard let duration = durationOfPlayerItem(playerItem) else{
            return
        }
        pause()
        let w = duration * rate
        let time = CMTime(seconds: w, preferredTimescale: 600)
        if let handle = completionHandler{
            player?.seekToTime(time, completionHandler: handle)
        }else{
            player?.seekToTime(time)
        }
    }
    
    /**
     以固定的秒数跳转
     
     - parameter second: 秒数
     */
    func seekCurrentTimeOffsetSecond(second:Double){
        // TODO: 可以加一个功能block,完成时,应该做什么(继续播放)
        pause()
        playerItem?.stepByCount(Int(second))
    }
    
    
    
    
}

// MARK: - PlayerControllerView_Delegate
extension PlayerViewController:PlayerControllerView_Delegate{
    func playerControllerView(cv: PlayerControllerView, panWithDirection direction: GestureDirection, addOrReduce add: Bool) {
        print(#function)
        switch direction {
        case .Horizontal:
            seekCurrentTimeOffsetSecond(add ? 7 : -7)
        case .Vertical:
            if add{
                addVolume()
            }else{
                reducesVolume()
            }
        }
    }
    
    func playerControllerView(cv: PlayerControllerView, didClickPlayPauseButtonWithStatus status: PlayerStatus) {
        switch status {
        case .Pause:
            pause()
        case .Playing: 
            play()
        }
    }
    
    func playerControllerView(cv: PlayerControllerView, changeSliderValue value: Float) {
        seekToRate(Double(value)) { (finish:Bool) in
            
        }
    }
    func playerControllerViewClickOnReplay(cv: PlayerControllerView) {
        setupPlayerWithVideo(video, reset: true)
    }
    
    func playerControllerView(cv: PlayerControllerView, didClickOnBigSmallButton button: UIButton) {
        playerChangeBig(portraitOrientation)
        if portraitOrientation{
            button.setImage(UIImage(named: "big"), forState: UIControlState.Normal)
        }else{
            button.setImage(UIImage(named: "small"), forState: UIControlState.Normal)
        }
    }
}

