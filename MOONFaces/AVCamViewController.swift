//
//  AVCamViewController.swift
//  MOONFaces
//
//  Created by 徐一丁 on 2020/7/7.
//  Copyright © 2020 徐一丁. All rights reserved.
//

import UIKit
import AVFoundation

class AVCamViewController: UIViewController {
    
    //MARK: Interface
    
    private enum State {
        case success
        case notAuthorized
        case configurationFailed
    }
    private var state: State = .success
    
    private let sessionQueue = DispatchQueue(label: "com.avcam.session.queue")
    private var isSessionRunning = false
    private let session = AVCaptureSession()
    
    private var videoDeviceInput: AVCaptureDeviceInput!
    
    var windowOrientation: UIInterfaceOrientation {
        return view.window?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViewsForAVCam(box: view)
        
        preview.session = session
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.state = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            state = .notAuthorized
        }
        
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            switch self.state {
            case .success:
//                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            case .notAuthorized:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("没有摄像头权限", comment: "")
                    let alert = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "跳转设置", style: .default, handler: { (_) in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("配置 session 时出错", comment: "")
                    let alert = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.state == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
//                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    //MARK: Data
    
    private func configureSession() {
        if state != .success {
            return
        }
        
        session.beginConfiguration()
        
        /*
         Do not create an AVCaptureMovieFileOutput when setting up the session because
         Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
         */
        session.sessionPreset = .photo
        
        // Video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                //背后双摄
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                //背后广角
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                //前摄
                defaultVideoDevice = frontCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                state = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if self.windowOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    
                    self.preview.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                state = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            state = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    //MARK: View
    
    override func viewDidLayoutSubviews() {
        preview.frame = view.bounds
        
    }
    
    private func loadViewsForAVCam(box: UIView) {
        box.addSubview(preview)
        
        loadConstraintsForAVCam(box: box)
    }
    
    private func loadConstraintsForAVCam(box: UIView) {
        
    }
    
    private var preview = AVCamPreviewView()
    
    //MARK: Event
    
}

extension AVCaptureVideoOrientation {
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}
