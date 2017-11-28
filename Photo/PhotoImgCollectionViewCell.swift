//
//  PhotoImgCollectionViewCell.swift
//  LsqPhoto
//
//  Created by lsq on 2017/11/20.
//  Copyright © 2017年 罗石清. All rights reserved.
//

import UIKit

class PhotoImgCollectionViewCell: UICollectionViewCell {
    
    public var imageView: UIImageView?
    fileprivate var deleteBtn: UIButton?
    
    public var deleteHandle: ((UIButton)->Swift.Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadSomeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadSomeView(){
        
        imageView = UIImageView(frame: self.bounds)
        imageView?.contentMode = .scaleAspectFill
        self.addSubview(imageView!)
        
        let deleteWH: CGFloat = 30
        deleteBtn = UIButton(frame: CGRect(x: self.frame.width - deleteWH, y: 0, width: deleteWH, height: deleteWH))
        deleteBtn?.setImage(UIImage(named: "delete"), for: .normal)
        deleteBtn?.addTarget(self, action: #selector(self.deleteAct(_:)), for: .touchUpInside)
        self.addSubview(deleteBtn!)
    }
    
    @objc fileprivate func deleteAct(_ send: UIButton){
        self.deleteHandle?(send)
    }
}
