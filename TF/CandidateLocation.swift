//
//  CandidateLocation.swift
//  TF
//
//  Created by Alfredo Luco on 28-11-15.
//  Copyright © 2015 Alfredo Luco. All rights reserved.
//

import Foundation
import CoreLocation

class CandidateLocation: NSObject, NSCoding {
    private var venue: String
    private var twitter: String?
    private var coordinates: CLLocationCoordinate2D
    
    
    init(Venue: String, Twitter: String?, Coordinates: CLLocationCoordinate2D){
        self.venue = Venue
        self.twitter = Twitter
        self.coordinates = Coordinates
    }
    
     required convenience init?(coder aDecoder: NSCoder) {
        let venue = aDecoder.decodeObjectForKey("Candidate_venue")
        let twitter = aDecoder.decodeObjectForKey("Candidate_twitter")
        let lat = aDecoder.decodeDoubleForKey("Candidate_latitude")
        let long = aDecoder.decodeDoubleForKey("Candidate_longitude")
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.init(Venue: (venue as? String)!, Twitter: twitter as? String, Coordinates: coordinate)
        
    }
    
    internal func getVenue()->String{
        return self.venue
    }
    
    internal func getTwitter()->String?{
        return self.twitter
    }
    
    internal func getCoordinates()->CLLocationCoordinate2D{
        return self.coordinates
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.venue, forKey: "Candidate_venue")
        aCoder.encodeObject(self.twitter, forKey: "Candidate_twitter")
        aCoder.encodeDouble(self.coordinates.latitude, forKey: "Candidate_latitude")
        aCoder.encodeDouble(self.coordinates.longitude, forKey: "Candidate_longitude")
    }
}