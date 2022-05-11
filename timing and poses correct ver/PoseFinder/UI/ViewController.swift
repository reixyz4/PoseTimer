/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The implementation of the application's view controller, responsible for coordinating
 the user interface, video feed, and PoseNet model.
*/

import AVFoundation
import UIKit
import VideoToolbox



class ViewController: UIViewController {
    /// The view the controller uses to visualize the detected poses.
    @IBOutlet private var previewImageView: PoseImageView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var sitTimeLabel: UILabel!
    
    @IBOutlet weak var standTimeLabel: UILabel!
    
    
    @IBOutlet weak var sitcountlabel: UILabel!
    @IBOutlet weak var standcountlabel: UILabel!
    
    @IBOutlet weak var posecountlabel: UILabel!

    
    private let videoCapture = VideoCapture()

    private var poseNet: PoseNet!

    /// The frame the PoseNet model is currently making pose predictions from.
    private var currentFrame: CGImage?

    /// The algorithm the controller uses to extract poses from the current frame.
    private var algorithm: Algorithm = .multiple

    /// The set of parameters passed to the pose builder when detecting poses.
    private var poseBuilderConfiguration = PoseBuilderConfiguration()

    private var popOverPresentationManager: PopOverPresentationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        


        // For convenience, the idle timer is disabled to prevent the screen from locking.
        UIApplication.shared.isIdleTimerDisabled = true

        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()
        super.viewDidLoad()
       
    }
    
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.delegate = self

            self.videoCapture.startCapturing()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Reinitilize the camera to update its output stream with the new orientation.
        setupAndBeginCapturingVideoFrames()
    }

    @IBAction func onCameraButtonTapped(_ sender: Any) {
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }

    @IBAction func onAlgorithmSegmentValueChanged(_ sender: UISegmentedControl) {
        guard let selectedAlgorithm = Algorithm(
            rawValue: sender.selectedSegmentIndex) else {
                return
        }

        algorithm = selectedAlgorithm
    }
    
    var timer:Timer = Timer()
    var count:Int = 0
    var n:Int = 0
    var pplcount: Int = 0
    var timerCounting:Bool = false
   

    @objc func timerCounter(count: Int) -> String
    {
      
    self.count = self.count + 1
        let time = secondsToHoursMinutesSeconds(seconds: self.count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
      return timeString
      
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
    
    
    
    
    
}

// MARK: - Navigation

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let uiNavigationController = segue.destination as? UINavigationController else {
            return
        }
        guard let configurationViewController = uiNavigationController.viewControllers.first
            as? ConfigurationViewController else {
                    return
        }

        configurationViewController.configuration = poseBuilderConfiguration
        configurationViewController.algorithm = algorithm
        configurationViewController.delegate = self

        popOverPresentationManager = PopOverPresentationManager(presenting: self,
                                                                presented: uiNavigationController)
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = popOverPresentationManager
    }
}

// MARK: - ConfigurationViewControllerDelegate

extension ViewController: ConfigurationViewControllerDelegate {
    func configurationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateConfiguration configuration: PoseBuilderConfiguration) {
        poseBuilderConfiguration = configuration
    }

    func configurationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateAlgorithm algorithm: Algorithm) {
        self.algorithm = algorithm
    }
}

// MARK: - VideoCaptureDelegate

extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        poseNet.predict(image)
    }
}

// MARK: - PoseNetDelegate

extension ViewController: PoseNetDelegate {
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
            // Release `currentFrame` when exiting this method.
            self.currentFrame = nil
        }

        guard let currentFrame = currentFrame else {
            return
        }

        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)

        let poses = algorithm == .single
            ? [poseBuilder.pose]
            : poseBuilder.poses

        previewImageView.show(poses: poses, on: currentFrame)
       var posecount = 0
        var standcount = 0
        var sitcount = 0
        
        func sit(){
            let count2 = 0
            sitTimeLabel.text = "Sit Timer: " + timerCounter(count: count2)
        }
        func stand(){
            let count3 = 0
            standTimeLabel.text = "Stand Timer: " + timerCounter(count: count3)
        }
        
        posecount = 0
        ///label.text = "nobody detected"
        for pose in poses{
            let count1 = 0
            timerLabel.text = "Duration: " + timerCounter(count: count1)
            posecount += 1
        ///declarations
            let LShldr2Hip = pose[.leftShoulder].position.distance(to:pose[.leftHip].position)
            let LAnk2Hip = pose[.leftAnkle].position.distance(to:pose[.leftHip].position)
            let RShldr2Hip = pose[.rightShoulder].position.distance(to:pose[.rightHip].position)
            let RAnk2Hip = pose[.rightAnkle].position.distance(to:pose[.rightHip].position)
            let RHip2KneeAngle = atan2(pose[.rightHip].position.y - pose[.rightKnee].position.y, pose[.rightHip].position.x - pose[.rightKnee].position.x)
            
            let RKnee2AnkAngle = atan2(pose[.rightKnee].position.y - pose[.rightAnkle].position.y, pose[.rightKnee].position.x - pose[.rightAnkle].position.x)
            let LKnee2Hip = pose[.leftKnee].position.distance(to:pose[.leftHip].position)
            let LAnk2Knee = pose[.leftAnkle].position.distance(to:pose[.leftKnee].position)
            let RKnee2Hip = pose[.rightKnee].position.distance(to:pose[.rightHip].position)
            let RAnk2Knee = pose[.rightAnkle].position.distance(to:pose[.rightKnee].position)
            let RShldr2HipAngle = atan2(pose[.rightShoulder].position.y - pose[.rightHip].position.y, pose[.rightShoulder].position.x - pose[.rightHip].position.x)
            
    
            
            var angleHipRadians = RHip2KneeAngle - RShldr2HipAngle
            while angleHipRadians < 0 {
                angleHipRadians += CGFloat(2 * Double.pi)}
            let angleHipDegree = Int(angleHipRadians * 180 / .pi)
                
            var angleKneeRadians = RHip2KneeAngle - RKnee2AnkAngle
            while angleKneeRadians < 0 {
                angleKneeRadians += CGFloat(2 * Double.pi)}
            let angleKneeDegree = Int(angleKneeRadians * 180 / .pi)
            
            
            ///1. bent knee ankle check for standing (Right)
           if angleKneeDegree > 340 || angleKneeDegree < 10 {
              
               standcount += 1
               stand()
           }
            
            ///4. considering angle of hip
            else if angleHipDegree > 350 && angleHipDegree < 10 {
               
                standcount += 1
                stand()
            }
                
            else if angleHipDegree > 20 && angleHipDegree < 80 {
                
                sitcount += 1
                sit()
            }
                
            else if angleHipDegree > 130 && angleHipDegree < 170 {
               
                sitcount += 1
                sit()
            }
            
            
            
        /// 2. shoulder to hip length longer than hip to ankle confirm sitting

     
            
            else if (LAnk2Hip < LShldr2Hip && RAnk2Hip < RShldr2Hip) {
            
                sitcount += 1
                sit()
            }
            
        ///  3. hip to knee distance shorter than knee to ankle distance confirm sitting
        
            
            else if (LKnee2Hip < LAnk2Knee && RKnee2Hip < RAnk2Knee) {
                
                sitcount += 1
                sit()
                
            }
  
            posecountlabel.text = "No. of People: " + String(posecount)
            sitcountlabel.text = "Sitting: " + String(sitcount)
            standcountlabel.text = "Standing: " + String(standcount)
            
        }
        if posecount == 0 {
            posecountlabel.text = "No. of People: 0"
            sitcountlabel.text = "Sitting: 0"
            standcountlabel.text = "Standing: 0" 
        }
       
        
        }
             
            
            
        }

