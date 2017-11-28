//
//  LsqPhotoController.swift
//  LsqPhoto
//
//  Created by lsq on 2017/11/17.
//  Copyright © 2017年 罗石清. All rights reserved.
//

import UIKit
import AVFoundation

class LsqPhotoController: UIViewController {
    deinit {
        print("LsqPhotoController->释放")
    }
    
    public var maxImages = 8

    fileprivate var positon = AVCaptureDevice.Position.back//摄像头位置
    fileprivate var topViewHeight: CGFloat = 50//顶部视图高度
    fileprivate var bottomHeight: CGFloat = 100//底部视图高度
    fileprivate var toggleBtn: UIButton?//切换摄像头按钮
    fileprivate var photoImgsView: PhotoImgsView?//展示拍摄的照片视图
    fileprivate var imageArray = [UIImage]()//保存拍摄的照片
    fileprivate var flashModel = AVCaptureDevice.FlashMode.auto//是否开启闪光灯
    fileprivate var flashBtn: UIButton?//控制闪光灯的按钮
    var session = AVCaptureSession()
    var videoInput: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var perviewLayer: AVCaptureVideoPreviewLayer?
    
    var cameraShowView: UIView?
    var imageShowView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.loadOtherBtn()
        
        self.loadSession()
        self.loadCamearShowView()
        
        self.setUpCameraLayer()
        
        self.loadShowImgsView()
    }
    fileprivate var statusHeight: CGFloat = -1
    override var prefersStatusBarHidden: Bool{
        if self.statusHeight == -1 {
            self.statusHeight = UIApplication.shared.statusBarFrame.height
        }
        return true
    }
    
    fileprivate func loadOtherBtn(){
        //顶部视图
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.topViewHeight))
        topView.backgroundColor = UIColor.black
        
        self.view.addSubview(topView)
        //闪光灯
        flashBtn = UIButton(frame: CGRect(x: 15, y: (topView.frame.height - 44) / 2, width: 70, height: 44))
        //默认为自动
        flashBtn?.setImage(UIImage(named: "shanguangdeng2"), for: .normal)
        flashBtn?.setTitle("自动", for: .normal)
        flashBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        flashBtn?.setTitleColor(UIColor.white, for: .normal)
        flashBtn?.addTarget(self, action: #selector(self.someBtnAct(_:)), for: .touchUpInside)
        flashBtn?.tag = 100
        topView.addSubview(flashBtn!)
        
        //切换摄像头
        toggleBtn = UIButton(frame: CGRect(x: topView.frame.width - 44 - 15, y: (topView.frame.height - 44) / 2, width: 44, height: 44))
        toggleBtn?.setImage(UIImage(named: "xiang"), for: .normal)
        toggleBtn?.addTarget(self, action: #selector(self.someBtnAct(_:)), for: .touchUpInside)
        toggleBtn?.tag = 0
        topView.addSubview(toggleBtn!)
        
        //底部视图
        let bottomView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - self.bottomHeight, width: self.view.frame.width, height: self.bottomHeight))
        bottomView.backgroundColor = UIColor.black
        self.view.addSubview(bottomView)
        //拍照按钮
        let shutterBtn = UIButton(frame: CGRect(x: (bottomView.frame.width - 60) / 2, y: (bottomView.frame.height - 60) / 2, width: 60, height: 60))
        shutterBtn.setImage(UIImage(named: "paizhao"), for: .normal)
        shutterBtn.addTarget(self, action: #selector(self.someBtnAct(_:)), for: .touchUpInside)
        shutterBtn.tag = 1
        bottomView.addSubview(shutterBtn)
        
        let btnWidht: CGFloat = 50
        let btnHeight: CGFloat = 35
        let cancelBtn = UIButton(frame: CGRect(x: 15, y: (bottomView.frame.height - btnHeight) / 2, width: btnWidht, height: btnHeight))
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.addTarget(self, action: #selector(self.someBtnAct(_:)), for: .touchUpInside)
        cancelBtn.tag = 2
        bottomView.addSubview(cancelBtn)
        
        let okBtn = UIButton(frame: CGRect(x: bottomView.frame.width - 15 - btnWidht, y: (bottomView.frame.height - btnHeight) / 2, width: btnWidht, height: btnHeight))
        okBtn.setTitle("完成", for: .normal)
        okBtn.setTitleColor(UIColor.white, for: .normal)
        okBtn.addTarget(self, action: #selector(self.someBtnAct(_:)), for: .touchUpInside)
        okBtn.tag = 3
        bottomView.addSubview(okBtn)
        
    }
    @objc fileprivate func someBtnAct(_ send: UIButton){
        let tag = send.tag
        switch tag {
        case 0://切换摄像头
            self.toggleCamera()
        case 1://拍照
            self.shutterCamera()
        case 2://取消
            self.dismiss(animated: true, completion: nil)
        case 3://完成
            print("完成")
        case 100://闪光灯
            print("当前为自动，转换为关闭")
            self.flashModel = .off
            self.flashBtn?.tag = 101
            self.flashBtn?.setTitle("关闭", for: .normal)
            self.setFlashLightModel()
        case 101:
            print("当前为关闭，转换为打开")
            self.flashModel = .on
            self.flashBtn?.tag = 102
            self.flashBtn?.setTitle("打开", for: .normal)
            self.setFlashLightModel()
        case 102:
            print("当前为打开，转换为自动")
            self.flashModel = .auto
            self.flashBtn?.tag = 100
            self.flashBtn?.setTitle("自动", for: .normal)
            self.setFlashLightModel()
        default:
            break
        }
    }
    //设置闪光灯
    fileprivate func setFlashLightModel(){
        guard let device = self.getCamera(with: .back) else {return}
        do {
            try device.lockForConfiguration()
            if device.hasFlash && device.isFlashModeSupported(self.flashModel){
                device.flashMode = self.flashModel
            }else{
                print("设备不支持闪光灯")
            }
            device.unlockForConfiguration()
        } catch  {
            print(error)
        }
    }

    //TODO:展示已拍摄照片
    fileprivate func loadShowImgsView(){
        let rect = CGRect(x: 0, y: self.cameraShowView!.frame.height - 100 - 10, width: self.cameraShowView!.frame.width, height: 100)
        photoImgsView = PhotoImgsView(frame: rect)
        
        photoImgsView?.imageTouchHandle = { [weak self](imgs,index,cell) in
            let reviewImgVC = ReviewImageViewController(images: imgs, selectIndex: index)
            self?.present(reviewImgVC, animated: true, completion: nil)
        }
        photoImgsView?.deleteHandle = { [weak self] (indexPath) in
            self?.imageArray.remove(at: indexPath.row)
        }
        
        self.cameraShowView?.addSubview(photoImgsView!)
    }
    
    
    //这是切换镜头的按钮方法
    fileprivate func toggleCamera(){
        let cameraCount = AVCaptureDevice.devices(for: .video).count
        if cameraCount > 1 {
            var newVideoInput: AVCaptureDeviceInput?
            
            guard var postion = self.videoInput?.device.position else{return}
            
            switch postion{
            case .back:
                postion = .front
                self.flashBtn?.isHidden = true
            case .front:
                postion = .back
                self.flashBtn?.isHidden = false
            default:
                break
            }
            
            guard let device = self.getCamera(with: postion) else{return}
            
            do{
                newVideoInput = try AVCaptureDeviceInput(device: device)
            }catch{
                return
            }
            guard let videoInput = newVideoInput else{return}
            
            self.session.beginConfiguration()
            self.session.removeInput(self.videoInput!)
            if self.session.canAddInput(videoInput){
                self.session.addInput(videoInput)
                self.videoInput = videoInput
            }else{
                self.session.addInput(self.videoInput!)
            }
            
            self.session.commitConfiguration()
        }
        
    }
    //这是拍照的方法
    fileprivate func shutterCamera(){
        
        if self.imageArray.count >= self.maxImages {
            let alert = UIAlertController(title: "温馨提示", message: "当前最多拍摄\(self.maxImages)张照片", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        guard let videoConnection = self.stillImageOutput?.connection(with: AVMediaType.video) else {return}
        
        self.stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (imageDataSampleBuffer, error) in
            
            if self.imageArray.count >= self.maxImages{
                print("已经是最大了")
                return
            }
            
            guard let imageBuffer = imageDataSampleBuffer else{
                return
            }
            guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer) else{
                return
            }
            guard let image = UIImage(data: imageData) else{return}
            let sc = UIScreen.main.bounds
            let size = CGSize(width: sc.width, height: sc.height)
            let status = self.statusHeight
            let rect = CGRect(x: 0, y: self.topViewHeight + status, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.topViewHeight - self.bottomHeight)
            
            guard let endImg = image.scale(to: size)?.cut(with: rect) else{return}

            self.imageArray.append(endImg)
            //刷新
            self.photoImgsView?.images = self.imageArray
            
        })
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.session.startRunning()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.session.stopRunning()
    }
    
    func loadSession(){
        

        guard let captureDevice = self.getCamera(with: self.positon) else {
            return
        }
        
        do {
            self.videoInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            print(error)
        }
        if self.videoInput == nil {
            print("...videoInput...")
            return
        }
        
        self.stillImageOutput = AVCaptureStillImageOutput()
        if self.stillImageOutput == nil {
            print("...stillImageOutput...")
            return
        }
        
        let outputSets = [AVVideoCodecJPEG:AVVideoCodecKey]
        
        self.stillImageOutput?.outputSettings = outputSets
        
        if self.session.canAddInput(self.videoInput!){
            self.session.addInput(self.videoInput!)
        }
        if self.session.canAddOutput(self.stillImageOutput!) {
            self.session.addOutput(self.stillImageOutput!)
        }
        self.session.sessionPreset = .high
        
    }
    func loadCamearShowView(){
        let rect = CGRect(x: 0, y: self.topViewHeight, width: self.view.frame.width, height: self.view.frame.height - self.topViewHeight - self.bottomHeight)
        self.cameraShowView = UIView(frame: rect)
        self.view.addSubview(self.cameraShowView!)
    }
    
    func getCamera(with position: AVCaptureDevice.Position)->AVCaptureDevice?{
        
        let devices = AVCaptureDevice.devices()
        
        for device in devices{
            
            if device.position == position{
                if position == .back{//如果是后置摄像头，则设置闪光灯。否则不设置
                    try? device.lockForConfiguration()
                    if device.hasFlash && device.isFlashModeSupported(self.flashModel){
                        device.flashMode = self.flashModel
                    }
                    device.unlockForConfiguration()
                }
                
                return device
            }
        }
        return nil
    }
    
    func setUpCameraLayer(){
        if self.perviewLayer == nil {
            self.perviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            let viewLayer = self.cameraShowView!.layer
            viewLayer.masksToBounds = true
            
            let bounds = self.cameraShowView!.bounds
            self.perviewLayer?.frame = bounds
            self.perviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            viewLayer.addSublayer(self.perviewLayer!)
     
        }
    }
    

}
