//
//  GridView.swift
//  YPImagePicker
//
//  Created by Kristoph Matthews on 9/13/18.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import Stevia

class GridView: UIView {
    let backgroundView = UIView()
    let vertLine0 = UIView()
    let vertLine1 = UIView()
    let horizLine0 = UIView()
    let horizLine1 = UIView()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // View Hierarchy
        sv(
            backgroundView.sv(
                vertLine0,
                vertLine1,
                horizLine0,
                horizLine1
            )
        )
        
        // Layout
        backgroundView.fillContainer()
        // Vertical lines
        vertLine0.fillVertically()
        vertLine1.fillVertically()
        vertLine0.centerVertically()
        vertLine1.centerVertically()
        vertLine0.width(1)
        vertLine1.width(1)
        vertLine0.left(33%)
        vertLine1.right(33%)
        
        // Horizontal lines
        horizLine0.fillHorizontally()
        horizLine1.fillHorizontally()
        horizLine0.height(1)
        horizLine1.height(1)
        horizLine0.top(33%)
        horizLine1.bottom(33%)
        
        // Style
        let clearColor = UIColor.white.withAlphaComponent(0)
        backgroundView.backgroundColor = clearColor
        self.backgroundColor = clearColor
        for v in [vertLine0, vertLine1, horizLine0, horizLine1] {
            v.backgroundColor = .white
        }
        
        // disable user interaction
        self.isUserInteractionEnabled = false
        self.backgroundView.isUserInteractionEnabled = false
    }
}
