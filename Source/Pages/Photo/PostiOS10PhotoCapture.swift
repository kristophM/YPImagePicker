//
//  PostiOS10PhotoCapture.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 08/03/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

@available(iOS 10.0, *)
class PostiOS10PhotoCapture: NSObject, YPPhotoCapture, AVCapturePhotoCaptureDelegate {
    var videoDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    let sessionQueue = DispatchQueue(label: "YPCameraVCSerialQueue", qos: .background)
    let session = AVCaptureSession()
    var deviceInput: AVCaptureDeviceInput?
    var device: AVCaptureDevice? { return deviceInput?.device }
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    var output: AVCaptureOutput { return photoOutput }
    var vOutput: AVCaptureVideoDataOutput { return videoOutput }
    var isCaptureSessionSetup: Bool = false
    var isPreviewSetup: Bool = false
    var previewView: UIView!
    var videoLayer: AVCaptureVideoPreviewLayer!
    var currentFlashMode: YPFlashMode = .off
    var hasFlash: Bool {
        guard let device = device else { return false }
        return device.hasFlash
    }
    var block: ((Data, URL?, [String: Any]?) -> Void)?
    
    // Raw file manipulation
    var rawImageFileURL: URL?
    var compressedFileData: Data?
    var metadata: [String: Any]?
    
    
    // MARK: - Configuration
    
    private func newSettings() -> AVCapturePhotoSettings {
        guard let availableRawFormat = self.photoOutput.availableRawPhotoPixelFormatTypes.first, #available(iOS 11.0, *) else {
            return AVCapturePhotoSettings() // TODO: INCOMPLETE
        }
        // Use the current device's first available RAW format.
        var settings = AVCapturePhotoSettings(rawPixelFormatType: availableRawFormat, processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc])
        
//         Catpure Highest Quality possible.
        settings.isHighResolutionPhotoEnabled = true
    
        
        // RAW capture is incompatible with digital image stabilization.
        settings.isAutoStillImageStabilizationEnabled = false
        
        
        // Set flash mode.
        if let deviceInput = deviceInput {
            if deviceInput.device.isFlashAvailable {
                switch currentFlashMode {
                case .auto:
                    if photoOutput.supportedFlashModes.contains(.auto) {
                        settings.flashMode = .auto
                    }
                case .off:
                    if photoOutput.supportedFlashModes.contains(.off) {
                        settings.flashMode = .off
                    }
                case .on:
                    if photoOutput.supportedFlashModes.contains(.on) {
                        settings.flashMode = .on
                    }
                }
            }
        }
        return settings
    }
    
    func configure() {
        photoOutput.isHighResolutionCaptureEnabled = true
        
        // Improve capture time by preparing output with the desired settings.
        photoOutput.setPreparedPhotoSettingsArray([newSettings()], completionHandler: nil)
        
        // Video output will be used to apply filter
        if let videoDelegate = videoDelegate {
            videoOutput.setSampleBufferDelegate(videoDelegate, queue: sessionQueue)
        }
    }
    
    // MARK: - Flash
    
    func tryToggleFlash() {
        // if device.hasFlash device.isFlashAvailable //TODO test these
        switch currentFlashMode {
        case .auto:
            currentFlashMode = .on
        case .on:
            currentFlashMode = .off
        case .off:
            currentFlashMode = .auto
        }
    }
    
    // MARK: - Shoot

    func shoot(completion: @escaping (Data, URL?, [String: Any]?) -> Void) {
        
        
        block = completion
    
        // Set current device orientation
        setCurrentOrienation()
        
        let settings = newSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation() else { print("Error capturing photo: \(error!)"); return }
        
        // TODO: Temp
        if let imgSrc = CGImageSourceCreateWithData(data as CFData, nil) {
            if let metadata = CGImageSourceCopyPropertiesAtIndex(imgSrc, 0, nil) as? [String : Any] {
                self.metadata = metadata
            }
        }
        
        if photo.isRawPhoto {
            // Save the RAW (DNG) file data to a URL.
            let dngFileURL = self.makeUniqueTempFileURL(extension: "dng")
            do {
                try data.write(to: dngFileURL)
                self.rawImageFileURL = dngFileURL
            } catch {
                fatalError("couldn't write DNG file to URL")
            }
        } else {
            self.compressedFileData = photo.fileDataRepresentation()!
        }
    }
        
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        guard let buffer = photoSampleBuffer else { return }
        if let data = AVCapturePhotoOutput
            .jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer,
                                         previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
            block?(data, nil, metadata)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        guard error == nil else { print("Error capturing photo: \(error!)"); return }
        guard let rawURL = self.rawImageFileURL, let compressedData = self.compressedFileData
            else { return }

        block?(compressedData, rawURL, metadata)
    }
    
//    func handlePhotoLibraryError(success: Bool, error: Error?) {
//        guard error == nil else { print("Error handling photoLibrary \(error!)"); return}
//        block(self.compressedFileData!, )
//    }
    
    func makeUniqueTempFileURL(extension type: String) -> URL {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let uniqueFilename = ProcessInfo.processInfo.globallyUniqueString
        let urlNoExt = temporaryDirectoryURL.appendingPathComponent(uniqueFilename)
        let url = urlNoExt.appendingPathExtension(type)
        return url
    }
}
