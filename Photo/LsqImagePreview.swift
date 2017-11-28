//
//  LsqImagePreview.swift
//  LsqPhoto
//
//  Created by lsq on 2017/11/27.
//  Copyright © 2017年 罗石清. All rights reserved.
//

import UIKit

class LsqImagePreview: UIView {

    deinit {
        print("LsqImagePreview->图片预览视图释放")
    }
    
    fileprivate var images = [UIImage]()
    fileprivate var select = 0
    fileprivate var view = UIView()
    
    convenience init(images: [UIImage], select: Int, view: UIView) {
        self.init(frame: view.frame)
        let ctrView = view.controllerView()
        let rect = self.getRect(with: ctrView)
        self.frame = rect
        self.backgroundColor = UIColor.green
        
        self.images = images
        self.select = select
        self.view = view
        
        self.showBig()
    }
    public func show(){
        self.showBig()
    }
    
    fileprivate func showBig(){
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }) { (isok) in
            print("完成")
            self.viewController()?.navigationController?.navigationBar.isHidden = true
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            self.frame = self.view.frame
        }) { (isok) in
            self.viewController()?.navigationController?.navigationBar.isHidden = false
            self.removeFromSuperview()
        }
        
    }
 

}
extension UIView{
    
    public func viewController()->UIViewController?{
        var next: UIView? = self
        repeat{
            if let nextResponder = next?.next, nextResponder.isKind(of: UIViewController.self){
                return nextResponder as? UIViewController
            }
            next = next?.superview
        }while next != nil
        
        return nil
    }
    public func controllerView()->UIView?{
        var next: UIView? = self
        repeat{
            if let nextResponder = next?.next, nextResponder.isKind(of: UIViewController.self){
                return next
            }
            next = next?.superview
        }while next != nil
        
        return nil
    }
}

extension UIView{
    //计算传入的视图相对窗口的frame
    public func getRelativeWindowFrame()->CGRect{
        let frame = self.convert(CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), to: UIApplication.shared.keyWindow)
        return frame
    }
    public func getRect(with view: UIView?)->CGRect{
        let frame = self.convert(CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), to: view)
        return frame
    }
}

