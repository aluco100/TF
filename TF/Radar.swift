//
//  Radar.swift
//  TF
//
//  Created by Alfredo Luco on 28-11-15.
//  Copyright © 2015 Alfredo Luco. All rights reserved.
//

import Foundation
import QuadratTouch
import CoreLocation

class Radar {
    var candidatos: [CandidateLocation]
    var session: Session
    private static var instance: Radar? = nil
    static let lock = dispatch_queue_create("instance.lock", nil)
    private init(){
        candidatos = []
        
        let clientID: String = "L001HQEGGIHFOKQXAWAIM20FZG4MLMXX04JC3ALESBEEVFPT"
        let clientSecret: String = "HR2TZ1AGRUXMPQEOP3N3AGUX2WAY3UQAQFKFD54YOHOSAZ2N"
        let url: String = "coevent://callback"
        let client = Client(clientID: clientID, clientSecret: clientSecret, redirectURL:url)
        var configuration = Configuration(client: client)
        configuration.debugEnabled = true
        configuration.mode = nil
        Session.setupSharedSessionWithConfiguration(configuration)
        session = Session.sharedSession()
        
    }
    
    internal static func getInstance() -> Radar{
        dispatch_sync(lock){
            if(instance == nil){
                instance = Radar()
            }
        }
        return instance!
    }
    
    //funciones getter
    
    internal func getVenues()->[CandidateLocation]{
        return self.candidatos
    }
    
    internal func getNearlyPlaces(coordinates: CLLocationCoordinate2D, callback: ()->Void){
        let ejes: String = "\(coordinates.latitude),\(coordinates.longitude)"
        let parameters = [Parameter.ll:ejes]
        let searchTask = self.session.venues.explore(parameters) {
            (result) -> Void in
            if let response = result.response {
                for i in 0...response["groups"]!.count-1{
                    let group = response["groups"]![i]
                    for j in 0...group["items"]!!.count-1 {
                        var name = ""
                        var twitter: String? = ""
                        var lat: CLLocationDegrees?
                        var long: CLLocationDegrees?
                        let venue = group["items"]!![j]["venue"]
                        if(venue!!["contact"] != nil){
                            let object = (venue!!["name"])!
                            let object2 = venue!!["contact"]
                            let object3 = venue!!["location"]
                            if(object2??["twitter"] != nil && object3??["lat"] != nil){
                                name = object as! String
                                twitter = (object2!!["twitter"] as? String)
                                lat = (object3!!["lat"] as? CLLocationDegrees)
                                long = (object3!!["lng"] as? CLLocationDegrees)
                            }
                            if (twitter != nil && twitter != ""){
                                let coordenada: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                                let venue: CandidateLocation = CandidateLocation(Venue: name, Twitter: twitter, Coordinates: coordenada)
                                self.candidatos.append(venue)
                            }
                            
                        }

                    }
                }
            }
            callback()
        }
        searchTask.start()
        
    }
}