//
//  TakenPhotoViewController.swift
//  ForgetStuff
//
//  Created by Bradley Knaysi on 12/23/17.
//  Copyright © 2017 Bradley Knaysi. All rights reserved.
//  Source: Arafin Russell

import UIKit

class TakenPhotoViewController: UIViewController {
    
    // Set new viewController's class in ViewControllerScene hierarchy
    @IBOutlet weak var takenPhotoView: UIImageView!
    var image: UIImage!
    
    @IBAction func savePhotoButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(takenPhotoView.image!,self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            // add way to popToRootViewController(animated: true)
            // means back to viewController
            return
        } else {
            let ac = UIAlertController(title: "Save error occured", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Alright...", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        takenPhotoView.image = image

        // Do any additional setup after loading the view.
    }
}
