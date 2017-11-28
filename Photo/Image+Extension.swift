//
//  Image+Extension.swift
//  LsqPhoto
//
//  Created by lsq on 2017/11/20.
//  Copyright © 2017年 罗石清. All rights reserved.
//

import UIKit

extension UIImage {

    func scale(to size: CGSize)->UIImage?{
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    func cut(with rect: CGRect)->UIImage?{
        let sourceRef = self.cgImage
        guard let newImgRef = sourceRef?.cropping(to: rect) else{
            return nil
        }
        let img = UIImage(cgImage: newImgRef)
        return img
    }
    
}
