//
//  vc.swift
//  PoseFinder
//
//  Created by DSPLAB on 21/2/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
//
//  vctime.swift
//  PoseFinder
//
//  Created by DSPLAB on 21/2/22.
//  Copyright © 2022 Apple. All rights reserved.
//
/*
import Foundation
import AVFoundation
import UIKit
import Vision

var sequenceHandler = VNSequenceRequestHandler()

class FaceDetectionViewController: UIViewController {
  @IBOutlet var faceView: FaceView!
 /// @IBOutlet var laserView: LaserView!
  @IBOutlet var faceLaserLabel: UILabel!
  
  @IBOutlet weak var timerLabel: UILabel!
  
  @IBOutlet weak var tlistlabel: UILabel!
  @IBOutlet weak var pplcountlabel: UILabel!
  
  
  let session = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  
  var timer:Timer = Timer()
  var count:Int = 0
  var n:Int = 0
  var pplcount: Int = 0
  var timerCounting:Bool = false
  var tlist = [Int]()
//  timerLabel.text = makeTimeString(hours: 0, minutes: 0, seconds: 0)
  
  let dataOutputQueue = DispatchQueue(
    label: "video data queue",
    qos: .userInitiated,
    attributes: [],
    autoreleaseFrequency: .workItem)

  var faceViewHidden = false
  
  var maxX: CGFloat = 0.0
  var midY: CGFloat = 0.0
  var maxY: CGFloat = 0.0

  override func viewDidLoad() {
    super.viewDidLoad()
    configureCaptureSession()
    

    
    maxX = view.bounds.maxX
    midY = view.bounds.midY
    maxY = view.bounds.maxY
    
    session.startRunning()
    
  
  
  }
  
  func detectedFace(request: VNRequest, error: Error?) {
    
    // 1
    
   
    
    guard
    
    let results = request.results as? [VNFaceObservation],
    let result = results.first
      
     /// case self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
        
      else {
        // 2
        faceView.clear()
        tlist.append(self.count)
        self.count = 0
        self.pplcount += 1
       /// self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
       
        return
    }
      
    // 3
    let box = result.boundingBox
    faceView.boundingBox = convert(rect: box)
   
  
   /// self.timerCounter()
   
    // 4
    DispatchQueue.main.async {
      self.faceView.setNeedsDisplay()
      self.timerCounter()
      
     // self.startStop()
      //self.reset()
    }
    
   // n = tlist.count
  
  
  }
  
  @IBAction func reset(_ sender: Any) {
    let alert = UIAlertController(title: " Timer?", message: "Are you sure you would like to reset the Timer?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (_) in
      //do nothing
    }))
    
    alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
      self.count = 0
      self.pplcount = 0
      
      self.timer.invalidate()
      self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
      
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  
  
  @objc func startStop() -> Void
  {
    if(timerCounting)
    {
      timerCounting = false
    //  reset()
      timer.invalidate()
      self.count = 0
      self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
      //  self.pplcount += 1
      
     /// tlist.append()
    ///  let count = tlist.count
    ///  for i in 0..<count {
    ///  self.tlistlabel.text = tlist[i]
      }
    
    else
    {
      timerCounting = true
      
      timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
      
    //  self.pplcount += 1
     // self.pplcountlabel.text = String(self.pplcount)
      
    }
  }
  
/*  func reset()
  {
   
    count = 0
    
    timer.invalidate()
    timerLabel.text = makeTimeString(hours: 0, minutes: 0, seconds: 0)
      

  }
  
 */
  @objc func timerCounter() -> Void
  {
    
    count = count + 1
    let time = secondsToHoursMinutesSeconds(seconds: count)
    let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
    timerLabel.text = timeString
   // pplcountlabel.text = String(pplcount)
    for i in tlist{
    tlistlabel.text = String(i)
      print(i)
    }
  }
  
  func makeTimeString(hours: Int, minutes: Int, seconds : Int) -> String
  {
    var timeString = ""
    timeString += String(format: "%02d", hours)
    timeString += " : "
    timeString += String(format: "%02d", minutes)
    timeString += " : "
    timeString += String(format: "%02d", seconds)
    return String(timeString)
  }
  
  func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)
  {
    return ((seconds / 3600), ((seconds % 3600) / 60),((seconds % 3600) % 60))
  }
  
  
  
  func convert(rect: CGRect) -> CGRect {
    // 1
    let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
    
    // 2
    let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
    
    // 3
    return CGRect(origin: origin, size: size.cgSize)
  }

  
  
}

// MARK: - Gesture methods

extension FaceDetectionViewController {
  @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
    faceView.isHidden.toggle()
 
    faceViewHidden = faceView.isHidden
    
    if faceViewHidden {
      faceLaserLabel.text = "Lasers"
    } else {
      faceLaserLabel.text = "Face"
    }
  }
}

// MARK: - Video Processing methods

extension FaceDetectionViewController {
  func configureCaptureSession() {
    // Define the capture device we want to use
    guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                               for: .video,
                                               position: .front) else {
      fatalError("No front video camera available")
    }
    
    // Connect the camera to the capture session input
    do {
      let cameraInput = try AVCaptureDeviceInput(device: camera)
      session.addInput(cameraInput)
    } catch {
      fatalError(error.localizedDescription)
    }
    
    // Create the video data output
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    
    // Add the video output to the capture session
    session.addOutput(videoOutput)
    
    let videoConnection = videoOutput.connection(with: .video)
    videoConnection?.videoOrientation = .portrait
    
    // Configure the preview layer
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = .resizeAspectFill
    previewLayer.frame = view.bounds
    view.layer.insertSublayer(previewLayer, at: 0)
  }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    // 1
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      return
    }

    // 2
    let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: detectedFace)

    // 3
    do {
      try sequenceHandler.perform(
        [detectFaceRequest],
        on: imageBuffer,
        orientation: .leftMirrored)
    } catch {
      print(error.localizedDescription)
    }

  }
}
*/
