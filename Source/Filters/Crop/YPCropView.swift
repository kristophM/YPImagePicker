//
//  YPCropView.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 12/02/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import Stevia

class YPCropView: UIView {
    
    let imageView = UIImageView()
    let topCurtain = UIView()
    let cropArea = UIView()
    let bottomCurtain = UIView()
    let gridView = GridView()
    var shouldShowGrid = false
    let cropInstructions = UILabel()

    convenience init(image: UIImage, ratio: Double, shouldShowGrid: Bool) {
        self.init(frame: .zero)
        self.shouldShowGrid = shouldShowGrid
        setupViewHierarchy()
        setupLayout(with: image, ratio: ratio)
        applyStyle()
        imageView.image = image
    }
    
    private func setupViewHierarchy() {
        if shouldShowGrid == true {
            sv(
                imageView,
                topCurtain,
                cropArea,
                bottomCurtain,
                gridView,
                cropInstructions
            )
        } else {
            sv(
                imageView,
                topCurtain,
                cropArea,
                bottomCurtain
            )
        }
    }
    
    private func setupLayout(with image: UIImage, ratio: Double) {
        layout(
            0,
            |topCurtain|,
            |cropArea|,
            |bottomCurtain|,
            0
        )
        
        let r: CGFloat = CGFloat(1.0 / ratio)
        cropArea.Height == cropArea.Width * r
        cropArea.top(0)
        
        // Fit image differently depnding on its ratio.
        let imageRatio: Double = Double(image.size.width / image.size.height)
        if ratio > imageRatio {
            let scaledDownRatio = UIScreen.main.bounds.width / image.size.width
            imageView.width(image.size.width * scaledDownRatio )
            imageView.centerInContainer()
        } else if ratio < imageRatio {
            imageView.Height == cropArea.Height
            imageView.centerInContainer()
        } else {
            imageView.followEdges(cropArea)
        }
        
        // Fit imageView to image's bounds
        imageView.Width == imageView.Height * CGFloat(imageRatio)
        
        // Grid view
        if shouldShowGrid == true {
            equal(sizes: gridView, cropArea)
            alignCenter(gridView, with: cropArea)
        }
        // Crop instructions
        if let cropText = CameraConfig.shared.cropText {
            cropInstructions.Top == cropArea.Bottom + 50
            cropInstructions.left(50)
            cropInstructions.right(50)
        }
    }
    
    private func applyStyle() {
        backgroundColor = .black
        clipsToBounds = true
        imageView.style { i in
            i.isUserInteractionEnabled = true
            i.isMultipleTouchEnabled = true
        }
        topCurtain.style(curtainStyle)
        cropArea.style { v in
            v.backgroundColor = .clear
            v.isUserInteractionEnabled = false
        }
        bottomCurtain.style(curtainStyle)
        if shouldShowGrid == true {
            gridView.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        }
        if let cropText = CameraConfig.shared.cropText {
            cropInstructions.attributedText = cropText
            cropInstructions.textAlignment = .center
        }
    }
    
    func curtainStyle(v: UIView) {
        v.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        v.isUserInteractionEnabled = false
    }
}
