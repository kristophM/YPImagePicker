//
//  YPPhotoSaver.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 10/11/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import Photos

public class YPPhotoSaver {
    public class func trySaveImage(_ image: UIImage, inAlbumNamed: String, rawImageURL: URL? = nil, completion: @escaping (String) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            if let album = album(named: inAlbumNamed) {
                saveImage(image, toAlbum: album, withRawImageURL: rawImageURL, completion: completion)
            } else {
                createAlbum(withName: inAlbumNamed) {
                    if let album = album(named: inAlbumNamed) {
                        saveImage(image, toAlbum: album, completion: completion)
                    }
                }
            }
        }
    }
    
    fileprivate class func saveImage(_ image: UIImage, toAlbum album: PHAssetCollection, withRawImageURL rawImageURL: URL? = nil, completion: @escaping (String) -> Void) {
        var localIdentifer: String!
        PHPhotoLibrary.shared().performChanges({
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            var enumeration: NSArray!
            if let rawImageURL = rawImageURL {
                // Add the compressed (HEIF) data as the main resource for the Photos asset.
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: UIImageJPEGRepresentation(image, 1.0)!, options: nil)
                // Add the RAW (DNG) file as an altenate resource.
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = true
                creationRequest.addResource(with: .alternatePhoto, fileURL: rawImageURL, options: options)
                let placeholder = creationRequest.placeholderForCreatedAsset!
                localIdentifer = placeholder.localIdentifier
                enumeration = [placeholder]
            } else {
                let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let placeholder = changeRequest.placeholderForCreatedAsset!
                localIdentifer = placeholder.localIdentifier
                enumeration = [placeholder]
            }
            albumChangeRequest?.addAssets(enumeration)
        }, completionHandler: { (success, error) in
            if success == true {
                completion(localIdentifer)
            }
        })
    }
    
    fileprivate class func createAlbum(withName name: String, completion:@escaping () -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        }, completionHandler: { success, _ in
            if success {
                completion()
            }
        })
    }
    
    fileprivate class func album(named: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", named)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                 subtype: .any,
                                                                 options: fetchOptions)
        return collection.firstObject
    }
}
