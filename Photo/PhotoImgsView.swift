//
//  PhotoImgsView.swift
//  LsqPhoto
//
//  Created by lsq on 2017/11/20.
//  Copyright © 2017年 罗石清. All rights reserved.
//

import UIKit

class PhotoImgsView: UIView, UICollectionViewDelegate ,UICollectionViewDataSource{

    public var images = [UIImage](){  
        didSet{
            self.myCollectionView?.reloadData()
        }
    }
 
    public var imageTouchHandle: (([UIImage],Int,PhotoImgCollectionViewCell)->Swift.Void)?//图片点击回调
    public var deleteHandle: ((IndexPath)->Swift.Void)?//图片删除回调
    
    fileprivate var myCollectionView: UICollectionView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.loadCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCollectionView(){
        let space: CGFloat = 5
        //---UICollectionView---
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //计算cell的宽度
        let width = self.frame.height
        
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = space //上下间隔
        layout.minimumInteritemSpacing = space //左右间隔
        layout.headerReferenceSize = CGSize(width: space, height: space ) //头部间距
        layout.footerReferenceSize = CGSize(width: space, height: space) //尾部间距
        layout.sectionInset.left = 15
        layout.sectionInset.right = 15
        //------
        
        let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        myCollectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        myCollectionView?.backgroundColor = UIColor.clear
        myCollectionView?.delegate = self
        myCollectionView?.dataSource = self
        self.addSubview(myCollectionView!)
        
        myCollectionView?.register(PhotoImgCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoImgCollectionViewCell")
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identify:String = "PhotoImgCollectionViewCell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identify, for: indexPath) as! PhotoImgCollectionViewCell
        
        cell.imageView?.image = self.images[indexPath.row]
        
        cell.deleteHandle = { [weak self](btn) in
            self?.deleteHandle?(indexPath)
            //删除cell
            self?.myCollectionView?.performBatchUpdates({
                self?.images.remove(at: indexPath.row)
                self?.myCollectionView?.deleteItems(at: [indexPath])
            }, completion: { (completion) in
                self?.myCollectionView?.reloadData()
            })
            
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //图片点击回调
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoImgCollectionViewCell
        self.imageTouchHandle?(self.images,indexPath.row,cell)
    }
    
    

}
