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
        print(igLocation.description)
        if(igLocation.motionState == .Seeking || igLocation.motionState == .Standing){
            let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: igLocation.latitude, longitude: igLocation.longitude)
            self.saveCoordinates(coordinates)
            self.radar?.getNearlyPlaces(coordinates, callback: { ()-> Void in
                let candidates: [CandidateLocation]? = (self.radar?.getVenues())
                print(candidates)
                if(candidates != nil){
                    for i in candidates!{
                        print("twitter: \(i.getTwitter())")
                        self.candidates.append(i)
                        let twitter = i.getTwitter()
                        self.swifter?.follow(twitter!)
                    }
                    self.saveCandidates(self.candidates)
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
    
    internal func saveCandidates(candidates: [CandidateLocation]?){
        var flag = true
        if(candidates == nil){
            return
        }
        let userdefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let user_data = userdefaults.objectForKey("candidates") as? NSData
            var aux = NSKeyedUnarchiver.unarchiveObjectWithData(user_data!) as! [CandidateLocation]
            for i in candidates!{
                for j in aux{
                    if(i.getVenue() == j.getVenue()){
                        flag = false
                    }
                }
                if(flag){
                    let notification = UILocalNotification()
                    notification.alertBody = "Se ha encontrado un nuevo lugar : \(i.getVenue())"
                    notification.category = "invite"
                    notification.fireDate = NSDate(timeIntervalSinceNow: 5)
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                    aux.append(i)
                }
                flag = true
            }
            let mutable: NSMutableArray = NSMutableArray(array: aux)
            let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(mutable)
            userdefaults.setObject(data, forKey: "candidates")
    }
    
}