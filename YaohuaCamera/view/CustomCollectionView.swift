//
//  CustomCollectionView.swift
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

import Foundation

class CustomCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        self.delaysContentTouches = false
        for view in self.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delaysContentTouches = false
            }
        }
        super.layoutSubviews()
    }
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}
