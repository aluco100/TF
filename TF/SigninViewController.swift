//
//  SigninViewController.swift
//  TF
//
//  Created by Alfredo Luco on 30-11-15.
//  Copyright © 2015 Alfredo Luco. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController {

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.init(patternImage: UIImage(named: "slide01.jpg")!)
        super.viewDidLoad()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "Signin"){
            let destination = segue.destinationViewController as! ViewController
            dispatch_async(dispatch_get_main_queue(), {()-> Void in
                destination.provider.getAuth()
                destination.provider.registerTweetsListener(destination)
            })
        }
    }

}
