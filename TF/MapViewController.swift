//
//  MapViewController.swift
//  TF
//
//  Created by Alfredo Luco on 05-12-15.
//  Copyright © 2015 Alfredo Luco. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var point : MKPointAnnotation = MKPointAnnotation()
    var region: MKCoordinateRegion = MKCoordinateRegion()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.addAnnotation(point)
        self.mapView.setRegion(region, animated: true)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
