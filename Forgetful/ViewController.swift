//
//  ViewController.swift
//  ForgetStuff
//
//  Created by Bradley Knaysi on 12/23/17.
//  Copyright © 2017 Bradley Knaysi. All rights reserved.
//  Source: Brian Voong, Glen Hinkle

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var classificationLabel: UILabel!
    @IBAction func PhotoButton_TouchUpInside(_ sender: Any) {
        performSegue(withIdentifier: "takenPhoto_Segue", sender: self)
    }
    
    var takenPhoto: UIImage!
    var photoOutput: AVCapturePhotoOutput!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var dataOutput: AVCaptureVideoDataOutput!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
    
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        // single input from camera
        
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(captureInput)
        captureSession.startRunning()
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        // one output for ML model and takenPhoto feature
        
        dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    // originally used wrong captureOutput... used didDrop sampleBuffer (caused no info)
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // setting variable to CVPixelBuffer
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let context = CIContext(options: nil)
        takenPhoto = UIImage(pixelBuffer: pixelBuffer, context: context)
        //takenPhoto = rotateImage(image: takenPhoto)
        
        
        // try? prevents needing do-catch
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }

        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            // can check error here
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            // Most likely object
            let firstObservationString = firstObservation.identifier + ": " + String(firstObservation.confidence)
            
            // calls label update on main thread
            DispatchQueue.main.async {
                self.classificationLabel.text = firstObservationString
            }
            
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "takenPhoto_Segue" {
            if let takenPhotoVC = segue.destination as? TakenPhotoViewController {
            
                // set new ViewController to current camera view
                takenPhotoVC.image = takenPhoto
            }
        }
    }
    
    // Outside sources: May help project... need to test
//    func rotateImage(image:UIImage)->UIImage
//    {
//        var rotatedImage = UIImage();
//        switch image.imageOrientation
//        {
//        case UIImageOrientation.right:
//            rotatedImage = UIImage(CGImage:image.CGImage!, scale: 1, orientation:UIImageOrientation.down);
//
//        case UIImageOrientation.down:
//            rotatedImage = UIImage(CGImage:image.CGImage!, scale: 1, orientation:UIImageOrientation.left);
//
//        case UIImageOrientation.left:
//            rotatedImage = UIImage(CGImage:image.CGImage!, scale: 1, orientation:UIImageOrientation.up);
//
//        default:
//            rotatedImage = UIImage(CGImage:image.CGImage!, scale: 1, orientation:UIImageOrientation.right);
//        }
//        return rotatedImage;
//    }
}
extension UIImage { // get source (not mine)
    /**
     Creates a new UIImage from a CVPixelBuffer, using Core Image.
     */
    convenience init?(pixelBuffer: CVPixelBuffer, context: CIContext) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let rect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer),
                          height: CVPixelBufferGetHeight(pixelBuffer))
        if let cgImage = context.createCGImage(ciImage, from: rect) {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
