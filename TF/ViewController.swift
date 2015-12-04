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
    var tweets:[JSONValue] = []
    var hashtags:[String] = []
    var users:[String] = []
    var radar: Radar = Radar()
    var placemngr: PlaceManager = PlaceManager(_radar: nil, _swifter: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        placemngr = PlaceManager(_radar: radar, _swifter: provider)
        
        Table.delegate = self
        Table.dataSource = self
        
        //imprimir las coordenadas
        let userstandar: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if(userstandar.objectForKey("coordinates") != nil){
            let alert = UIAlertController(title: "Title", message: "Candidatos Encontrados", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            let coordenadas = userstandar.objectForKey("coordinates") as? [CLLocationCoordinate2D]
            for i in coordenadas!{
                print("lat: \(i.latitude)  long: \(i.longitude)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onTweetsReload(tweets: [JSONValue]) -> Void{
        dispatch_async(dispatch_get_main_queue()) {
            self.Table.reloadData()
        }
    }
    
    @IBAction func getAuthorization(sender: AnyObject) {
       
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tweets = provider.getTweets()
        hashtags = provider.getHashtags()
        users = provider.getUsers()
        //return hashtags.count
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        
        //cell.textLabel?.text = hashtags[indexPath.row]
        //cell.textLabel?.text = tweets[indexPath.row]["text"].string
        cell.textLabel?.text = users[indexPath.row]
        
        return cell
    }
    
    
    
}

