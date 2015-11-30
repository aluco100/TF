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
    init(){
        candidatos = []
        
        let clientID: String = "L001HQEGGIHFOKQXAWAIM20FZG4MLMXX04JC3ALESBEEVFPT"
        let clientSecret: String = "HR2TZ1AGRUXMPQEOP3N3AGUX2WAY3UQAQFKFD54YOHOSAZ2N"
        let url: String = "coevent://callback"
        let client = Client(clientID: clientID, clientSecret: clientSecret, redirectURL:url)
        let configuration = Configuration(client: client)
        Session.setupSharedSessionWithConfiguration(configuration)
        
        session = Session.sharedSession()
        
    }
    
    //funciones getter
    
    internal func getVenues()->[CandidateLocation]{
        return self.candidatos
    }
    
    internal func getNearlyPlaces(coordinates: CLLocationCoordinate2D, callback: ()->Void){
        let ejes: String = "\(coordinates.latitude),\(coordinates.longitude)"
        let parameters = [Parameter.ll:ejes]
        let searchTask = self.session.venues.search(parameters) {
            (result) -> Void in
            if let response = result.response {
                print(response)
                
                for i in 0...response["venues"]!.count-1{
                    let venue:AnyObject = response["venues"]![i]
                    var name = ""
                    var twitter: String? = ""
                    var lat: CLLocationDegrees?
                    var long: CLLocationDegrees?
                    if(venue["contact"] != nil){
                        let object: NSArray = (venue["categories"])! as! NSArray
                        let object2: NSArray? = (venue["contact"])! as? NSArray
                        let object3 : NSArray? = venue["location"] as? NSArray
                        if(object.count != 0 && object2 != nil  && object3 != nil){
                            name = (object[0]["name"] as! String)
                            twitter = (object2![0]["twitter"] as? String)
                            lat = (object3![0]["lat"] as? CLLocationDegrees)
                            long = (object3![0]["long"] as? CLLocationDegrees)
                            print(name)
                        }
                        if (twitter != nil && twitter != ""){
                            let coordenada: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                            let venue: CandidateLocation = CandidateLocation(Venue: name, Twitter: twitter, Coordinates: coordenada)
                            self.candidatos.append(venue)
                        }
                        
                    }
                }
            }
            callback()
        }
        searchTask.start()
        
    }
}