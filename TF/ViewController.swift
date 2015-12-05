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
class ViewController: UIViewController,CLLocationManagerDelegate, UITableViewDelegate,TweetsListener, UITableViewDataSource {
    
    //outlets
    @IBOutlet weak var Table: UITableView!
    
    
    //variables
    var contador: Int = 0
    var provider: TwitterManager = TwitterManager()
    var radar: Radar = Radar()
    var placemngr: PlaceManager = PlaceManager(_radar: nil, _swifter: nil)
    
    var tweets:[JSONValue] = []
    var hashtags:[String] = []
    var users:[String] = []
    var candidatos: [CandidateLocation] = []
    var selected: CandidateLocation = CandidateLocation(Venue: "", Twitter: "", Coordinates: CLLocationCoordinate2D())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "slide02.jpg")!).colorWithAlphaComponent(0.9)
        
        placemngr = PlaceManager(_radar: radar, _swifter: provider)
        
        Table.delegate = self
        Table.dataSource = self
        Table.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        
        //ejemplo candidato
        let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -33.019832, longitude: -71.550787)
        let cand: CandidateLocation = CandidateLocation(Venue: "Museo Fonk", Twitter: "museofonck", Coordinates: cord)
        candidatos.append(cand)
        
        //imprimir las coordenadas
        let userstandar: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if(userstandar.objectForKey("candidates") != nil){
            let user_data = userstandar.objectForKey("candidates") as? NSData
            let aux = NSKeyedUnarchiver.unarchiveObjectWithData(user_data!) as! [CandidateLocation]
            for i in aux{
                candidatos.append(i)
            }
        }
        
    }

    func onTweetsReload(tweets: [JSONValue]) -> Void{
        dispatch_async(dispatch_get_main_queue()) {
            self.Table.reloadData()
        }
    }
    
    @IBAction func getAuthorization(sender: AnyObject) {
        let userstandars : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let candidates: [CandidateLocation]? = userstandars.objectForKey("candidates") as? [CandidateLocation]
        if(candidates != nil){
            let alert = UIAlertController(title: "Title", message: "Candidatos Encontrados", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Title", message: "Aun no hay candidatos", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tweets = provider.getTweets()
        hashtags = provider.getHashtags()
        users = provider.getUsers()
        //return hashtags.count
        //return tweets.count
        return candidatos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = Table.dequeueReusableCellWithIdentifier("candidato", forIndexPath: indexPath)
        //cell.textLabel?.text = hashtags[indexPath.row]
        //cell.textLabel?.text = tweets[indexPath.row]["text"].string
        //cell.textLabel?.text = users[indexPath.row]
        cell.textLabel?.text = candidatos[indexPath.row].getVenue()
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "VenueSegue"){
            let indexPath = self.Table.indexPathForSelectedRow!
            self.selected = candidatos[indexPath.row]
            let destination = segue.destinationViewController as? MapViewController
            //add point
            let point : MKPointAnnotation = MKPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: selected.getCoordinates().latitude, longitude: selected.getCoordinates().longitude)
            point.title = selected.getVenue()
            destination?.point = point
            
            //set the region
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: point.coordinate, span: span)
            destination?.region = region
            
        }
    }
    
    
}

