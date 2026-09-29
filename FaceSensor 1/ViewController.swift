//
//  ViewController.swift
//  FaceSensor 1
//
//  Created by VICTOR J. DEUTSCH on 8/31/18.
//  Copyright © 2018 VICTOR J. DEUTSCH. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import WatchConnectivity

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {  }
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) {}
    @IBOutlet var lLabel: UILabel!
    @IBOutlet var rLabel: UILabel!

    var imageView: UIImageView!
    var currentAnimation = 0
    var counter = 0
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureVideoDataOutput()
    let cameraPosition = AVCaptureDevice.Position.back
    var requests: [VNDetectFaceRectanglesRequest] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let captureSession = AVCaptureSession ()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()
        let previewLayer =  AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: ""))
        captureSession.addOutput(dataOutput)
        setupVisionDetection()
        imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.center = CGPoint(x: 210, y: 350)
        view.tintColor = UIColor.red
        view.addSubview(imageView)
        func sendWatchMessage() {
            return
        }
        if (WCSession.default.isReachable) {
            let message = ["": ""]
            WCSession.default.sendMessage(message, replyHandler:
                nil)
        }
        sendWatchMessage()
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let instructions = "With FaceSensor, the proximity of another person can be determined via haptic feedback. Simply hold iPhone in hand or place in shirt pocket with camera facing outward. Generally, a single click indicates front sector, double click indicates leftward sector, and triple click indicates rightward sector. Intensity of iPhone haptics will increase with closer proximity of the person. Several cycles may be necessary for proper placement. To aid with sector indication, configure your Apple Watch to - Wake for 70 Seconds. - Please note, children may be closer than they appear."
        let beamoat = UIAlertController(title: "FaceSensor is for stationary use only.", message: instructions, preferredStyle: .alert)
        beamoat.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(beamoat, animated: true)
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection:  AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let requestOptions: [VNImageOption: Any] = [:]
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer:imageBuffer,orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print (error)
        }
    }
    func setupVisionDetection() {
        rLabel.isHidden = true
        lLabel.isHidden = true
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaces)
        // Built against a newer SDK, Vision would default to a newer face detector
        // whose boxes are sized differently; the 2018 build used revision 2, so keep it.
        faceDetectionRequest.revision = VNDetectFaceRectanglesRequestRevision2
        self.requests = [faceDetectionRequest];
    }
    func handleFaces(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let result = (request.results as? [VNFaceObservation])?.first else { return }
            Thread.sleep(forTimeInterval:1.2)
            self.imageView.transform = CGAffineTransform.identity
            let bb = result.boundingBox
    //Left Sector
            if bb.midX < 0.3 {
                self.rLabel.isHidden = true
                self.lLabel.isHidden = false
                if bb.width >= 0.22 {
                    self.imageView.transform = CGAffineTransform.identity
                    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
                                   animations: { [unowned self] in
                                    switch self.currentAnimation {
                                    case 0:
                                        self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                                    default:
                                        break
                                    }
                    })
                    if (WCSession.default.isReachable) {
                        let message = ["": ""]
                        WCSession.default.sendMessage(message, replyHandler:
                            nil)
                        Thread.sleep(forTimeInterval: 0.2)
                        WCSession.default.sendMessage(message, replyHandler: nil)
                    }
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()
                    Thread.sleep(forTimeInterval: 0.2)
                    _ = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()
              } else
                    if bb.width > 0.10 && bb.width < 0.22 {
                        self.imageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                        self.imageView.transform = CGAffineTransform.identity
                        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
                                       animations: { [unowned self] in
                                        switch self.currentAnimation {
                                        case 0:
                                            self.imageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                                        default:
                                            break
                                        }
                        })
                        if (WCSession.default.isReachable) {
                            let message = ["": ""]
                            WCSession.default.sendMessage(message, replyHandler:
                                nil)
                            Thread.sleep(forTimeInterval: 0.2)
                            WCSession.default.sendMessage(message, replyHandler: nil)
                        }
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                        Thread.sleep(forTimeInterval: 0.2)
                        _ = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                } else
                        if bb.width <= 0.10 {
                            self.imageView.transform = CGAffineTransform.identity
                            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: [],
                                           animations: { [unowned self] in
                                            switch self.currentAnimation {
                                            case 0:
                                                self.imageView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                                            default:
                                                break
                                            }
                            })
                            if (WCSession.default.isReachable) {
                                let message = ["": ""]
                                WCSession.default.sendMessage(message, replyHandler:
                                    nil)
                           
                                Thread.sleep(forTimeInterval: 0.2)
                                WCSession.default.sendMessage(message, replyHandler: nil)
                            }
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.prepare()
                            generator.impactOccurred()
                            Thread.sleep(forTimeInterval: 0.2)
                            _ = UIImpactFeedbackGenerator(style: .light)
                            generator.prepare()
                            generator.impactOccurred()
                   } else {return}
            } else
// sector - middle
                if bb.midX >= 0.3 && bb.midX <= 0.7 {
                    self.rLabel.isHidden = true
                    self.lLabel.isHidden = true
                    if bb.width >= 0.22 {
                        self.imageView.transform = CGAffineTransform.identity
                        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
                                       animations: { [unowned self] in
                                        switch self.currentAnimation {
                                        case 0:
                                            self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                                        default:
                                            break
                                        }
                        })
                        if (WCSession.default.isReachable) {
                            let message = ["": ""]
                            WCSession.default.sendMessage(message, replyHandler:
                                nil)
                        }
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.prepare()
                        generator.impactOccurred()
                    } else
                        if bb.width > 0.10 && bb.width < 0.22 {
                            self.imageView.transform = CGAffineTransform.identity
                            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
                                           animations: { [unowned self] in
                                            switch self.currentAnimation {
                                            case 0:
                                                self.imageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                                            default:
                                                break
                                            }
                            })
                            if (WCSession.default.isReachable) {
                                let message = ["": ""]
                                WCSession.default.sendMessage(message, replyHandler:
                                    nil)
                            }
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.prepare()
                            generator.impactOccurred()
                        } else
                            if bb.width <= 0.10 {
                                self.imageView.transform = CGAffineTransform.identity
                                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: [],
                                               animations: { [unowned self] in
                                                switch self.currentAnimation {
                                                case 0:
                                                    self.imageView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                                                default:
                                                    break
                                                }
                                })
                                if (WCSession.default.isReachable) {
                                    let message = ["": ""]
                                    WCSession.default.sendMessage(message, replyHandler:
                                        nil)
                                }
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.prepare()
                                generator.impactOccurred()
                           } else {return}
                } else
// sector - right
                    if bb.midX > 0.7 {
                        self.rLabel.isHidden = false
                        self.lLabel.isHidden = true
                        if bb.width >= 0.22 {
                            self.imageView.transform = CGAffineTransform.identity
                            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
                                           animations: { [unowned self] in
                                            switch self.currentAnimation {
                                            case 0:
                                                self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                                                
                                            default:
                                                break
                                            }
                            })
                            if (WCSession.default.isReachable) {
                                let message = ["": ""]
                                WCSession.default.sendMessage(message, replyHandler:
                                    nil)
                                Thread.sleep(forTimeInterval: 0.17)
                                WCSession.default.sendMessage(message, replyHandler: nil)
                                Thread.sleep(forTimeInterval: 0.17)
                                WCSession.default.sendMessage(message, replyHandler: nil)
                                Thread.sleep(forTimeInterval: 0.17)
                                WCSession.default.sendMessage(message, replyHandler: nil)
                            }
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.prepare()
                            generator.impactOccurred()
                            Thread.sleep(forTimeInterval: 0.17)
                            _ = UIImpactFeedbackGenerator(style: .heavy)
                            generator.prepare()
                            generator.impactOccurred()
                            Thread.sleep(forTimeInterval: 0.17)
                            _ = UIImpactFeedbackGenerator(style: .heavy)
                            generator.prepare()
                            generator.impactOccurred()
} else
                            if bb.width > 0.10 && bb.width < 0.22 {
                                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
                                               animations: { [unowned self] in
                                                switch self.currentAnimation {
                                                case 0:
                                                    self.imageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
                                                default:
                                                    break
                                                }
                                })
                                if (WCSession.default.isReachable) {
                                    let message = ["": ""]
                                    WCSession.default.sendMessage(message, replyHandler:
                                        nil)
                                    Thread.sleep(forTimeInterval:0.17)
                                    WCSession.default.sendMessage(message, replyHandler: nil)
                                    Thread.sleep(forTimeInterval:0.17)
                                    WCSession.default.sendMessage(message, replyHandler: nil)
                                    Thread.sleep(forTimeInterval:0.17)
                                    WCSession.default.sendMessage(message, replyHandler: nil)
                                }
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.prepare()
                                generator.impactOccurred()
                                Thread.sleep(forTimeInterval: 0.17)
                                _ = UIImpactFeedbackGenerator(style: .medium)
                                generator.prepare()
                                generator.impactOccurred()
                                Thread.sleep(forTimeInterval: 0.17)
                                _ = UIImpactFeedbackGenerator(style: .medium)
                                generator.prepare()
                                generator.impactOccurred()
                            } else
                                if bb.width <= 0.10 {
                                    self.imageView.transform = CGAffineTransform.identity
                                    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: [],
                                                   animations: { [unowned self] in
                                                    switch self.currentAnimation {
                                                    case 0:
                                                        self.imageView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                                                    default:
                                                        break
                                                    }
                                    })
                                    if (WCSession.default.isReachable) {
                                        let message = ["": ""]
                                        WCSession.default.sendMessage(message, replyHandler:
                                            nil)
                                        Thread.sleep(forTimeInterval:0.17)
                                        WCSession.default.sendMessage(message, replyHandler: nil)
                                        Thread.sleep(forTimeInterval:0.17)
                                        WCSession.default.sendMessage(message, replyHandler: nil)
                                        Thread.sleep(forTimeInterval:0.17)
                                        WCSession.default.sendMessage(message, replyHandler: nil)
                                    }
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.prepare()
                                    generator.impactOccurred()
                                    Thread.sleep(forTimeInterval: 0.17)
                                    _ = UIImpactFeedbackGenerator(style: .light)
                                    generator.prepare()
                                    generator.impactOccurred()
                                    Thread.sleep(forTimeInterval: 0.17)
                                    _ = UIImpactFeedbackGenerator(style: .light)
                                    generator.prepare()
                                    generator.impactOccurred()
                                } else {return}
            }
        }
    }
}
