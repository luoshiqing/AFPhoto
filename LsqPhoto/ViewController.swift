//
//  ViewController.swift
//  LsqPhoto
//
//  Created by lsq on 2017/11/17.
//  Copyright © 2017年 罗石清. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
 
    }

    @IBAction func action(_ sender: UIButton) {
        
        let lsqPhoto = LsqPhotoController()

        self.present(lsqPhoto, animated: true, completion: nil)

//        let slsld = LsqImagePreview(images: [], select: 0, view: sender)
//        self.view.addSubview(slsld)
    }
    
}

