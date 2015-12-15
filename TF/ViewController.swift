//
//  ViewController.swift
//  TF
//
//  Created by Alfredo Luco on 28-11-15.
//  Copyright © 2015 Alfredo Luco. All rights reserved.
//

import UIKit
import MapKit
import QuadratTouch
import SwifteriOS
class ViewController: UIViewController,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, CandidateListener, TweetsListener {
    
    //outlets
    @IBOutlet weak var Table: UITableView!
    
    
    //variables
    var provider: TwitterManager = TwitterManager()
    var radar: Radar = Radar.getInstance()
    var placemngr: PlaceManager = PlaceManager(_radar: nil, _swifter: nil)
    
    var tweets:[JSONValue] = []
    var hashtags:[String] = []
    var users:[String] = []
    var candidatos: [CandidateLocation] = []
    var selected: CandidateLocation? = CandidateLocation(Venue: "", Twitter: "", Coordinates: CLLocationCoordinate2D())
    var twitterSelected: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider.getAuth({
            (error: NSError?) -> Void in
            if(error == nil){
                self.provider.registerTweetsListener(self)
                self.placemngr = PlaceManager(_radar: self.radar, _swifter: self.provider)
                self.provider.getHomeTimeline({
                    (tweets: [JSONValue], error: NSError?) -> Void in
                    
                })
            }else {
                print("error viewDidLoad: \(error)")
            }
        })
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "slide02.jpg")!).colorWithAlphaComponent(0.9)
        
        
        Table.delegate = self
        Table.dataSource = self
        Table.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        
        //imprimir las coordenadas
        let userstandar: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if(userstandar.objectForKey("candidates") != nil){
            let user_data = userstandar.objectForKey("candidates") as? NSData
            let aux = NSKeyedUnarchiver.unarchiveObjectWithData(user_data!) as! [CandidateLocation]
            for i in aux{
                print("candidate twitter: \(i.getTwitter())")
                candidatos.append(i)
            }
        }
        
    }

    func onTweetsReload(tweets: [JSONValue]) {
        self.tweets = tweets
        dispatch_async(dispatch_get_main_queue()) {
            self.Table.reloadData()
        }
    }
    
    func candidatesReload(candidates: [CandidateLocation]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.Table.reloadData()
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        hashtags = provider.getHashtags()
        users = provider.getUsers()
        //return hashtags.count
        return tweets.count
        //return candidatos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = Table.dequeueReusableCellWithIdentifier("candidato", forIndexPath: indexPath)
        //cell.textLabel?.text = hashtags[indexPath.row]
        cell.textLabel?.text = tweets[indexPath.row]["text"].string
        //cell.textLabel?.text = tweets[indexPath.row]["user"]["screen_name"].string
        //cell.textLabel?.text = users[indexPath.row]
        //cell.textLabel?.text = candidatos[indexPath.row].getVenue()
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "VenueSegue"){
            let indexPath = self.Table.indexPathForSelectedRow!
            twitterSelected = tweets[indexPath.row]["user"]["screen_name"].string
            print("selection : \(twitterSelected?.lowercaseString)")
            self.selected = self.provider.getCandidateFromTweetUser(twitterSelected?.lowercaseString)
            let destination = segue.destinationViewController as? MapViewController
            //add point
            if(self.selected != nil){
                let point : MKPointAnnotation = MKPointAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: selected!.getCoordinates().latitude, longitude: selected!.getCoordinates().longitude)
                point.title = selected!.getVenue()
                destination?.point = point
                
                //set the region
                let span = MKCoordinateSpanMake(0.01, 0.01)
                let region = MKCoordinateRegion(center: point.coordinate, span: span)
                destination?.region = region
            }
            
        }
        
    }
    
    
}

