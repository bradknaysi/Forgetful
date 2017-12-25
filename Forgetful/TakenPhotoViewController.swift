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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takenPhotoView.image = image

        // Do any additional setup after loading the view.
    }
}
