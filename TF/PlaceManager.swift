//
//  PlaceManager.swift
//  TF
//
//  Created by Alfredo Luco on 28-11-15.
//  Copyright © 2015 Alfredo Luco. All rights reserved.
//

import Foundation
import UIKit

class PlaceManager: NSObject ,IGLocationManagerDelegate {
    private var radar: Radar?
    private var swifter: TwitterManager?
    private var candidates: [CandidateLocation] = []
    
    required init(_radar: Radar?, _swifter: TwitterManager?){
        super.init()
        
        let api_key: String = "23ddd9035c998b244a9f7fc488c6ee88"
        IGLocationManager.initWithDelegate(self, secretAPIKey: api_key)
        IGLocationManager.startUpdatingLocation()
        
        self.radar = _radar
        self.swifter = _swifter
        
    }
    
    internal func getVenues()->[CandidateLocation]{
        return self.candidates
    }
    
    func igLocationManager(manager: IGLocationManager!, didUpdateLocation igLocation: IGLocation!) {
        print("description: \(igLocation.description)")
        if(igLocation.motionState == .Seeking){
            let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: igLocation.latitude, longitude: igLocation.longitude)
            //self.saveCoordinates(coordinates)
            self.radar?.getNearlyPlaces(coordinates, callback: { ()-> Void in
                let candidates: [CandidateLocation]? = (self.radar?.getVenues())
                if(candidates != nil){
                    for i in candidates!{
                        print("twitter: \(i.getTwitter())")
                        self.candidates.append(i)
                        let twitter = i.getTwitter()
                        self.swifter?.follow(twitter!)
                    }
                }
            })
        }
    }
    
    internal func saveCoordinates(coordinates: CLLocationCoordinate2D){
        let userdefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if(userdefaults.objectForKey("coordinates") != nil){
            var aux = userdefaults.objectForKey("coordinates") as? [CLLocationCoordinate2D]
            for i in aux!{
                if(i.latitude == coordinates.latitude && i.longitude == coordinates.longitude){
                    return
                }else{
                    aux?.append(coordinates)
                    userdefaults.setObject(aux as? AnyObject, forKey: "coordinates")
                }
            }
        }else{
            var aux:[CLLocationCoordinate2D] = []
            aux.append(coordinates)
            userdefaults.setObject(aux as? AnyObject, forKey: "coordinates")
        }

    }
    
}