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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
