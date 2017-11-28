//
//  ReviewImageViewController.swift
//  ESTShipper
//
//  Created by lsq on 2017/6/6.
//  Copyright © 2017年 湖南润安危物联科技发展有限公司. All rights reserved.
//

import UIKit

class ReviewImageViewController: UIViewController ,UIScrollViewDelegate{

    deinit {
        print("ReviewImageViewController->看大图控制器释放")
    }
    fileprivate var images = [Any]()
    fileprivate var selectIndex = 0
    //显示第几张图片的文本
    fileprivate var showIndexLabel: UILabel?
    
    init(images: [Any], selectIndex: Int){
        super.init(nibName: nil, bundle: nil)
        self.images = images
        self.selectIndex = selectIndex
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate var mainScrollView: UIScrollView!
    fileprivate let mainTag = 123456
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.setUI()
        self.setShowIndexView()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func setShowIndexView(){
        showIndexLabel = UILabel(frame: CGRect(x: 0, y: 15, width: 60, height: 20))
        showIndexLabel?.textColor = UIColor.white
        showIndexLabel?.font = UIFont.systemFont(ofSize: 15)
        showIndexLabel?.center.x = self.view.center.x
        //设置默认值
        let current = self.selectIndex + 1
        let allNumber = self.images.count
        let text = "\(current)/\(allNumber)"
        showIndexLabel?.text = text
        self.view.addSubview(showIndexLabel!)
    }
    func setUI(){
        let width = self.view.frame.width
        let height = self.view.frame.height
        mainScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        mainScrollView.delegate = self
        mainScrollView.backgroundColor = UIColor.black
        mainScrollView.tag = mainTag
        mainScrollView.bounces = false
        self.view.addSubview(mainScrollView)
        
        var originx: CGFloat = 0
        for i in 0..<self.images.count {
            let myImg = self.images[i]
            let imgW = UIScreen.main.bounds.width
            //-----------
            if let img = myImg as? UIImage{
                let size = img.size
                //图片进行比例缩放，按照屏幕宽度
                //计算图片的高度
                let imgH = UIScreen.main.bounds.width * size.height / size.width
                let x: CGFloat = CGFloat(i) * width
                
                let rect = CGRect(x: x, y: 0, width: imgW, height: mainScrollView.frame.height)
                let scrollView = UIScrollView(frame: rect)
                scrollView.backgroundColor = UIColor.black
                let imgY = (scrollView.frame.height - imgH) / 2
                let imageView = UIImageView(frame: CGRect(x: 0, y: imgY, width: imgW, height: imgH))
                imageView.backgroundColor = UIColor.black
                imageView.image = img
                
                imageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismiss(_:)))
                imageView.addGestureRecognizer(tap)
                scrollView.bounces = false
                scrollView.addSubview(imageView)
                
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.dismiss(_:)))
                scrollView.addGestureRecognizer(tap1)
                
                originx = scrollView.frame.minX + scrollView.frame.width
                scrollView.minimumZoomScale = 0.8
                scrollView.maximumZoomScale = 2.0
                scrollView.delegate = self
                
                self.mainScrollView.addSubview(scrollView)
            }else if let img = myImg as? String{
                let x = CGFloat(i) * imgW
                let rect = CGRect(x: x, y: 0, width: mainScrollView.frame.width, height: mainScrollView.frame.height)
                let scrollView = UIScrollView(frame: rect)
                
                scrollView.minimumZoomScale = 0.8
                scrollView.maximumZoomScale = 2.0
                scrollView.delegate = self
                scrollView.backgroundColor = UIColor.black
                scrollView.bounces = false
                
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.dismiss(_:)))
                scrollView.addGestureRecognizer(tap1)
                
                let imgY = (scrollView.frame.height - imgW) / 2
                let imageView = UIImageView(frame: CGRect(x: 0, y: imgY, width: imgW, height: imgW))
                imageView.backgroundColor = UIColor.black
                
                imageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismiss(_:)))
                imageView.addGestureRecognizer(tap)
                
                scrollView.addSubview(imageView)
                originx = scrollView.frame.minX + scrollView.frame.width
                self.mainScrollView.addSubview(scrollView)
                if let url = URL(string: img){
//                    imageView.sd_setImage(with: url, completed: { (imgg, error, type, url) in
//                        if let img = imgg{
//                            //图片进行比例缩放，按照屏幕宽度
//                            //计算图片的高度
//                            let size = img.size
//                            let imgH = ScreenWidth * size.height / size.width
//                            //回到主线程
//                            DispatchQueue.main.async(execute: {
//                                let imgY = (scrollView.frame.height - imgH) / 2
//                                imageView.frame = CGRect(x: 0, y: imgY, width: imgW, height: imgH)
//                            })
//                        }else{
//                            //回到主线程
//                            DispatchQueue.main.async(execute: {
//                                let img = UIImage(named: "pic_jc")!
//                                let imgY = (scrollView.frame.height - img.size.height) / 2
//                                let imgX = (scrollView.frame.width - img.size.width) / 2
//                                imageView.frame = CGRect(x: imgX, y: imgY, width: img.size.width, height: img.size.height)
//                                imageView.image = img
//                            })
//                        }
//                    })
                }
            }else{
                print("数据类型不是String和UIImage格式")
            }
        }
        self.mainScrollView.isScrollEnabled = true
        self.mainScrollView.isPagingEnabled = true
        self.mainScrollView.contentSize = CGSize(width: originx, height: self.mainScrollView.frame.height)
        //设置初始位置
        self.mainScrollView.contentOffset.x = width * CGFloat(self.selectIndex)
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        for imageView in scrollView.subviews{
            if imageView is UIImageView {
                return imageView
            }
        }
        return nil
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageView = scrollView.subviews.first as! UIImageView
        self.centerShow(scrollview: scrollView, imageview: imageView)
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.minimumZoomScale >= scale {
            scrollView.setZoomScale(0.8, animated: true)
        }
        if scrollView.maximumZoomScale <= scale {
            scrollView.setZoomScale(2.0, animated: true)
        }
    }
    func centerShow(scrollview:UIScrollView, imageview:UIImageView){
        // 居中显示
        let offsetX = (scrollview.bounds.size.width > scrollview.contentSize.width) ? (scrollview.bounds.size.width - scrollview.contentSize.width) * 0.5 : 0.0;
        let offsetY = (scrollview.bounds.size.height > scrollview.contentSize.height) ?
            (scrollview.bounds.size.height - scrollview.contentSize.height) * 0.5 : 0.0;
        imageview.center = CGPoint(x: scrollview.contentSize.width * 0.5 + offsetX, y: scrollview.contentSize.height * 0.5 + offsetY)
    }
    @objc func dismiss(_ send: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let tag = scrollView.tag
        if tag == self.mainTag{
            let offSetX = scrollView.contentOffset.x
            let index = Int(offSetX / self.view.frame.width)
            let text = "\(index + 1)/\(self.images.count)"
            self.showIndexLabel?.text = text
        }
    }
    
}
