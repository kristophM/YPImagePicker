//
//  CameraConfig.swift
//  YPImagePicker
//
//  Created by Kristoph Matthews on 9/28/18.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

public class CameraConfig {
    public static var shared: CameraConfig = CameraConfig(backgroundColor: .black, shotButton: #imageLiteral(resourceName: "shot_button"), showBottomPagerView: true, cropText: nil, navbarTintColor: .blue, navbarBarTintColor: .white, navbarTitleView: nil, backButtonImage: nil, didSelectExit: {})
    
    public var backgroundColor: UIColor
    public var shotButton: UIImage
    public var showBottomPagerView: Bool
    public var cropText: NSAttributedString?
    public var navbarTintColor: UIColor!
    public var navbarBarTintColor: UIColor!
    public var navbarTitleView: UIView!
    public var backButtonImage: UIImage?
    public var didSelectExit: (() -> Void)!
    
    
    
    private init(backgroundColor: UIColor, shotButton: UIImage, showBottomPagerView: Bool, cropText: NSAttributedString?, navbarTintColor: UIColor, navbarBarTintColor: UIColor, navbarTitleView: UIView?, backButtonImage: UIImage? = nil, didSelectExit: (() -> Void) = {}) {
        self.backgroundColor = backgroundColor
        self.shotButton = shotButton
        self.showBottomPagerView = showBottomPagerView
        self.cropText = cropText
        self.backButtonImage = backButtonImage
    }
}
