//
//  PlayerControllerView.swift
//  ZhangShi
//
//  Created by Liuming Qiu on 16/7/15.
//  Copyright © 2016年 ZW. All rights reserved.
//

import UIKit

/**
 播放器的状态
 
 - pause:       暂停中
 - playing:     下在播放
 */
enum PlayerStatus {
    case Pause
    case Playing
    
    /**
     改变自身的状态
     */
    mutating func change(){
        switch self {
        case .Pause:
            self = .Playing
        case .Playing:
            self = .Pause
            
        }
    }
}

/**
 手势方向
 
 - Horizontal: 水平
 - Vertical:   垂直
 */
enum GestureDirection {
    case Horizontal
    case Vertical
}

protocol PlayerControllerView_Delegate:class {
    func playerControllerView(cv:PlayerControllerView,panWithDirection direction:GestureDirection,addOrReduce add:Bool)
    func playerControllerView(cv:PlayerControllerView,panWithDirection direction:GestureDirection,endState state:UIGestureRecognizerState)
    func playerControllerView(cv:PlayerControllerView,didClickPlayPauseButtonWithStatus status:PlayerStatus)
    func playerControllerView(cv:PlayerControllerView,changeSliderValue value:Float)
    func playerControllerViewClickOnReplay(cv:PlayerControllerView)
    func playerControllerView(cv:PlayerControllerView,didClickOnBigSmallButton button:UIButton)
}

class PlayerControllerView: UIView {
    
    /**
     控制
     
     - Schedule: 进度控制
     - Volume:   音量控制
     */
    enum ControlModel {
        case Schedule
        case Volume
    }
        /// 错误信息的固定内容
    let fixErrorLabel = "error"
    // MARK: - UI
        /// 显示错误信息
    @IBOutlet weak var errorL: UILabel!
        /// 加载转轮
    @IBOutlet weak var loadingIndicatorV: UIActivityIndicatorView!
        /// 播放按钮
    @IBOutlet weak var playB: UIButton!
        /// 已播放的时间
    @IBOutlet weak var time0L: UILabel!
        /// 未播放时间
    @IBOutlet weak var time1L: UILabel!
        /// 放大,缩小按钮
    @IBOutlet weak var bigSmallB: UIButton!
        /// 滑条,播放进度
    @IBOutlet weak var slider: PlayerSlider!
        /// 缓存的进度
    @IBOutlet weak var loadedV: LoadedView!
        /// 底部控制按钮的容器
    @IBOutlet weak var bottomBarV: UIView!
        /// 重新加载
    @IBOutlet weak var replayB: UIButton!
        /// 进度控制容器
    @IBOutlet weak var scheduleControlContainerV: UIView!
        /// 进度控制图片
    @IBOutlet weak var scheduleControlIV: UIImageView!
        /// 进度控制总时长
    @IBOutlet weak var scheduleControlTotalL: UILabel!
        /// 进度控制当前时长
    @IBOutlet weak var scheduleControlCurrentL: UILabel!
    
    
    // MARK: - property
    /// 计时器
    var timer:NSTimer!
        /// 播放器的状态
    private(set) var status:PlayerStatus = .Pause
    
        /// 是否加载状态中
    private(set) var loading:Bool = false
    
        /// 当前被手势控制的
    private var controlModel:ControlModel? {
        didSet{
            if controlModel == .Schedule {
                scheduleControlContainerV.hidden = false
            }else if controlModel == nil{
                scheduleControlContainerV.hidden = true
            }
        }
    }
    
    weak var delegate:PlayerControllerView_Delegate?
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    
    private func setupUI(){
        errorL?.hidden = true
        loadingIndicatorV?.hidden = true
        
        addGesture()
        hideBar()
    }
    
    
    // MARK: - 更新UI
    /**
     设置当前显示的控制进度
     
     - parameter cs:  当前时长
     - parameter ts:  总时长
     - parameter add: 是否是增长,或减小
     */
    func setScheduleControlWithCurrentSeconds(cs:Int,totalSeconds ts:Int,add:Bool){
        guard controlModel == .Schedule else{
            return
        }
        scheduleControlIV.image = UIImage(named: add ? "Forward" : "go-back")
        scheduleControlTotalL.text = "\(ts / 60):\(ts % 60)"
        scheduleControlCurrentL.text = "\(cs / 60):\(cs % 60)"
    }
        /// 错误信息,可以用来设置错误信息
    var errorText:String?{
        get{
            return errorL.text
        }
        set{
            
            if newValue == nil{
                errorL.text = fixErrorLabel
            }else{
                errorL.text = newValue
                loadingVideo(false, changeBarHidden: true)
            }
            
            errorL.hidden = newValue == nil
            replayB.hidden = newValue == nil
            bottomBarV.userInteractionEnabled = newValue == nil
        }
    }
    
    
    /**
     改变播放状态
     */
    func changeStatusWithStatus(status:PlayerStatus){
        self.status = status
        updatePlayButton()
    }
    /**
     更新播放按钮
     */
    func updatePlayButton(){
        switch status {
        case .Pause:
            playB.setImage(UIImage(named: "play2"), forState: UIControlState.Normal)
        case .Playing:
            playB.setImage(UIImage(named: "stop"), forState: UIControlState.Normal)
        }
    }
    
    /**
     指示bottom bar 是显示出来的,没有隐藏
     
     - returns: Bool
     */
    func bottomBarIsShow() -> Bool{
        return self.bottomBarV?.alpha == 1.0
    }
    
    /**
     隐藏控制台
     */
    func hideBar(){
        if self.bottomBarV?.alpha != 0.0{
            UIView.animateWithDuration(0.5) { [weak self] in
                self?.bottomBarV?.alpha = 0.0
            }
        }
        removeTimer()
    }
    /**
     显示控制台
     */
    func showBar(){
        if self.bottomBarV.alpha != 1.0{
            UIView.animateWithDuration(0.5) { [weak self] in
                self?.bottomBarV.alpha = 1.0
            }
        }
        addTimer()
    }
    
    /**
     加载中
     
     - parameter loading: 是否正在加载
     */
    func loadingVideo(loading:Bool,changeBarHidden:Bool = true){
        self.loading = loading
        self.bottomBarV?.userInteractionEnabled = !loading
        if changeBarHidden{
            loading ? hideBar() : showBar()
        }
        loading ? self.loadingIndicatorV?.startAnimating() : self.loadingIndicatorV?.stopAnimating()
    }
    
    /**
     设置播放进度条
     
     - parameter value: 当前进度
     
     - returns: 是否成功
     */
    func setPlayProgressWithValue(value:Float) -> Bool{
        guard value >= 0 && value <= 1.0 else{
            return false
        }
        slider.setValue(value, animated: true)
        return true
    }
    
    /**
     更新播放时间
     
     - parameter s:        当前时间
     - parameter duration: 总时长
     */
    func updateTime0And1WithCurrentSeconds(s:Double,duration:Double){
        let cSec = Int(s) % 60
        let cMin = Int(s) / 60
        
        var cSecStr = "\(cSec)"
        if cSec < 10{ cSecStr = "0" + cSecStr }
        
        var cMinStr = "\(cMin)"
        if cMin < 10{ cMinStr = "0" + cMinStr }
        
        time0L.text = cMinStr + ":" + cSecStr
        
        let d = duration - s
        
        let dSec = Int(d) % 60
        let dMin = Int(d) / 60
        
        var dSecStr = "\(dSec)"
        if dSec < 10{ dSecStr = "0" + dSecStr }
        
        var dMinStr = "\(dMin)"
        if dMin < 10{ dMinStr = "0" + dMinStr }
        
        time1L.text = dMinStr + ":" + dSecStr        
    }
    
    // MARK: - 定时器
    private func addTimer(){
        removeTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(5,
                                                       target: self,
                                                       selector: #selector(PlayerControllerView.hideBarWithTimer(_:)),
                                                       userInfo: nil,
                                                       repeats: false)
    }
    /**
     隐藏 Bar
     
     - parameter timer: 定时器
     */
    func hideBarWithTimer(timer:NSTimer){
        hideBar()
    }
    
    /**
     移除定时器
     */
    func removeTimer(){
        guard timer != nil else{
            return
        }
        if timer.valid{
            timer.invalidate()
        }
        timer = nil
    }

}

// MARK: - gesture
extension PlayerControllerView{
    
    /**
     增加手势
     */
    func addGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlayerControllerView.tapToShowOrHideBarWithGesture(_:)))
        self.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(PlayerControllerView.panToChangeVolume(_:)))
        self.addGestureRecognizer(pan)
    }
    
    func tapToShowOrHideBarWithGesture(gesture:UITapGestureRecognizer){
        bottomBarIsShow() ? hideBar() : showBar()
    }
    
    func panToChangeVolume(pan:UIPanGestureRecognizer){
        let point = pan.translationInView(pan.view)
        let x = point.x
        let y = point.y
        
        let absX = abs(x)
        let absY = abs(y)
        
        var angle:CGFloat?
        if absX != 0 && absY != 0{
            angle = asin(absY / absX)
        }
        

        if absX == 0 || angle >= CGFloat(M_PI * 7 / 18){ // 40度的方向
            if absY >= 10 && pan.state == .Changed && controlModel == ControlModel.Volume{
                delegate?.playerControllerView(self, panWithDirection: GestureDirection.Vertical, addOrReduce: y < 0)
                pan.setTranslation(CGPoint.zero, inView: pan.view)
            }
            if pan.state == .Began || pan.state == .Ended || pan.state == .Cancelled{
                if pan.state == .Began{
                    controlModel = .Volume
                }else{
                    controlModel = nil
                }
                delegate?.playerControllerView(self, panWithDirection: .Vertical, endState: pan.state)
            }

        }else if absY == 0 || angle <= CGFloat(M_PI / 9) {
            if absX >= 10 && pan.state == .Changed && controlModel == ControlModel.Schedule{
                delegate?.playerControllerView(self, panWithDirection: .Horizontal, addOrReduce: x > 0)
                pan.setTranslation(CGPoint.zero, inView: pan.view)
            }
            if pan.state == .Began || pan.state == .Ended || pan.state == .Cancelled{
                if pan.state == .Began{
                    controlModel = .Schedule
                }else{
                    controlModel = nil
                }
                delegate?.playerControllerView(self, panWithDirection: .Horizontal, endState: pan.state)
            }
        }else// if pan.state == .Ended || pan.state == .Cancelled
        {
            if controlModel != nil{
                switch controlModel! {
                case .Volume:
                    delegate?.playerControllerView(self, panWithDirection: .Vertical, endState: pan.state)
                case .Schedule:
                    delegate?.playerControllerView(self, panWithDirection: .Horizontal, endState: pan.state)
                }
                controlModel = nil
            }
        }
        
    }
    
    @IBAction func playSlider(sender: PlayerSlider) {
        delegate?.playerControllerView(self, changeSliderValue: sender.value)
    }
    
    @IBAction func playPauseB(sender: UIButton) {
        changeStatusWithStatus(self.status == .Playing ? .Pause : .Playing)
        delegate?.playerControllerView(self, didClickPlayPauseButtonWithStatus: status)
    }
    
    @IBAction func tapAtReplayB(sender: UIButton) {
        delegate?.playerControllerViewClickOnReplay(self)
    }

    @IBAction func tapBigOrSmallB(sender: UIButton) {
        delegate?.playerControllerView(self, didClickOnBigSmallButton: sender)
    }
}
