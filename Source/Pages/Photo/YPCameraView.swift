//
//  YPCameraView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia

class YPCameraView: UIView, UIGestureRecognizerDelegate {
    
    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    let previewViewContainer = UIView()
    let buttonsContainer = UIView()
    let flipButton = UIButton()
    let shotButton = UIButton()
    let flashButton = UIButton()
    let timeElapsedLabel = UILabel()
    let progressBar = UIProgressView()
    var filterView: FilterView?
    

    convenience init(overlayView: UIView? = nil) {
        self.init(frame: .zero)
        
        setup(overlayView: overlayView)
    }
    
    convenience init(filterView: FilterView? = nil) {
        self.init(frame: .zero)
        
        // Set filterView if applicable
        if let filterView = filterView {
            self.filterView = filterView
        }
        // Don't show previewView
        previewViewContainer.alpha = 0.001 // (instead of zero, to allow for touch events)
        
        setup(overlayView: filterView)
    }
    
    fileprivate func setup(overlayView: UIView?) {
        if let overlayView = overlayView {
            // View Hierarchy
            sv(
                previewViewContainer,
                overlayView,
                progressBar,
                timeElapsedLabel,
                flashButton,
                flipButton,
                buttonsContainer.sv(
                    shotButton
                )
            )
        } else {
            // View Hierarchy
            sv(
                previewViewContainer,
                progressBar,
                timeElapsedLabel,
                flashButton,
                flipButton,
                buttonsContainer.sv(
                    shotButton
                )
            )
        }
        
        // Layout
        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        layout(
            0,
            |-sideMargin-previewViewContainer-sideMargin-|,
            -2,
            |progressBar|,
            0,
            |buttonsContainer|,
            0
        )
        previewViewContainer.heightEqualsWidth()
        
        overlayView?.followEdges(previewViewContainer)
        
        |-(15+sideMargin)-flashButton.size(42)
        flashButton.Bottom == previewViewContainer.Bottom - 15
        
        flipButton.size(42)-(15+sideMargin)-|
        flipButton.Bottom == previewViewContainer.Bottom - 15
        
        timeElapsedLabel-(15+sideMargin)-|
        timeElapsedLabel.Top == previewViewContainer.Top + 15
        
        shotButton.centerVertically()
        shotButton.size(84).centerHorizontally()
        
        // Style
        backgroundColor = YPConfig.colors.photoVideoScreenBackground
        previewViewContainer.backgroundColor = .black
        timeElapsedLabel.style { l in
            l.textColor = .white
            l.text = "00:00"
            l.isHidden = true
            l.font = .monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.medium)
        }
        progressBar.style { p in
            p.trackTintColor = .clear
            p.tintColor = .red
        }
        flashButton.setImage(YPConfig.icons.flashOffIcon, for: .normal)
        flipButton.setImage(YPConfig.icons.loopIcon, for: .normal)
        shotButton.setImage(CameraConfig.shared.shotButton, for: .normal)
        
        
        // Selective showing of controls
        flashButton.alpha = YPConfig.photo.controls.contains(.flash) ? 1 : 0
        flipButton.alpha = YPConfig.photo.controls.contains(.flip) ? 1: 0
    }
}

class FilterView: UIView {
    // A UIImageView with an optional Grid view on top
    private var imageView = UIImageView()
    var gridView = GridView()
    var image: UIImage? {
        didSet {
            imageView.image = image
            gridView.backgroundColor = UIColor.white.withAlphaComponent(0.001) // Bug: Cannot put alpha of zero here, so put a really small value
        }
    }
    convenience init(frame: CGRect, withGrid: Bool = false) {
        self.init(frame: frame)
        // Adds grid layer on top (if applicable) and config layout
        if withGrid == true {
            sv(
                imageView,
                gridView
            )
            gridView.fillContainer()
        } else {
            sv(imageView)
        }
        imageView.fillContainer()
        
    }
    
    @objc func didTap(_ sender: UITapGestureRecognizer) {
        print("tapped")
    }
}
