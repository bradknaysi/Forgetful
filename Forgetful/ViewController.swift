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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
    
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(captureInput)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    // originally used wrong captureOutput... used didDrop sampleBuffer (caused no info)
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // setting variable to CVPixelBuffer
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

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
            
                // capturing camera image with UI labels embeded
                //let img: UIImage = self.view.renderToImage()
                //let img = UIImage.imageWithView(view: self.view)
                let img = self.view.asImage()

                // setting TakenPhotoViewController's UIImageView
                takenPhotoVC.image = img
            }
        }
    }
}
extension UIView {
    
    // New method to improve old UIGraphicsBeginImageContext()
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
