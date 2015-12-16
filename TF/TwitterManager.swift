//
//  authProvider.swift
//  CommuteEvent
//
//  Created by Alfredo Luco on 26-09-15.
//  Copyright (c) 2015 Alfredo Luco. All rights reserved.
//
//
//


/*
###################Preguntas###############
-Que se pone en el callback url de la api de twitter



*/

import Foundation
import SwifteriOS
import SafariServices
import UIKit

class TwitterManager{
    private var swifter: Swifter
    private var consumerKey: String
    private var consumerSecret: String
    private var callbackUrl: NSURL
    private var tweets: [JSONValue]
    private var hashtags: [String]
    private var users: [String]
    private var tweetslistenercontainer: [TweetsListener]
    
    private static var instance: TwitterManager? = nil
    
    static let lock = dispatch_queue_create("instance.lock", nil)
    
    internal static func getInstance() -> TwitterManager{
        dispatch_sync(lock){
            if(instance == nil){
                instance = TwitterManager()
            }
        }
        return instance!
    }

    
    init(){
        self.consumerKey = "NYYbKwT9gwjwpeSCIGc5f6hBY"
        self.consumerSecret = "IpeZzoM2JXRzeSvOZZlSni87DRtRdQf6Wpy1Jueis5xrPIdjTJ"
        self.swifter = Swifter(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
        self.callbackUrl = NSURL(string: "coevent://callback")!
        self.tweets = []
        self.hashtags = []
        self.users = []
        self.tweetslistenercontainer = []
    }
    
    //metodo de autorizacion
    
    internal func getAuth(callback:(error: NSError?)->Void){
        swifter.authorizeWithCallbackURL(self.callbackUrl,
            success: { (accessToken, response) -> Void in
                callback(error: nil)
            },
            failure: { (error) -> Void in
                callback(error: error)
            },
            openQueryURL: nil,
            closeQueryURL: nil
        )
    }
    
    
    //metodsos getter
    
    internal func getHomeTimeline(callback: (tweets: [JSONValue], error: NSError?)->Void){
        let limit: Int = 100;
        //mas parametros que los vistos en el repositorio
        self.swifter.getStatusesHomeTimelineWithCount(limit, trimUser: nil, contributorDetails: true, includeEntities: true, success: {
            (data: [JSONValue]?) in
            self.tweets = data!
            self.signalEvent()
            callback(tweets: self.tweets, error: nil)
            
            }, failure: {
                (error: NSError) in
                callback(tweets: self.tweets, error: error)
                //en caso de error
                //print(error)
        })
        
    }
    
    internal func getTweets() -> [JSONValue]{
        
        return self.tweets
    }
    
    internal func getHashtags()->[String]{
        if(self.tweets.count < 1){
            return []
        }
        for i in 0...self.tweets.count - 1 {
            let t = self.tweets[i]["entities"]["hashtags"]
            let count = t.array!.count
            if (count > 0) {
                for j in 0...count - 1
                {
                    self.hashtags.append(t.array![j]["text"].string!);
                }
            }
        }
        
        return self.hashtags
    }
    
    internal func getUsers()->[String]{
        if(self.tweets.count < 1){
            return []
        }
        for i in 0...self.tweets.count - 1{
            let u = self.tweets[i]["entities"]["user_mentions"]
            let count = u.array!.count
            if(count > 0)
            {
                for j in 0...count - 1 {
                    self.users.append(u.array![j]["name"].string!)
                }
            }
            
        }
        return self.users
    }
    
    internal func registerTweetsListener(registrant: TweetsListener){
        self.tweetslistenercontainer.append(registrant)
    }
    
    internal func signalEvent(){
        for i:TweetsListener in self.tweetslistenercontainer
        {
            i.onTweetsReload(self.tweets)
        }
    }
    
    internal func follow(name: String){
        self.swifter.postCreateFriendshipWithScreenName(name, follow: true, success: {
            (user: Dictionary<String, JSONValue>?) -> Void in
            print("user: \(user)")
            self.signalEvent()
            }, failure: {
                (error: NSError) -> Void in
                print("error: \(error)")
        })
    }
    
    internal func getCandidateFromTweetUser(name: String?)->CandidateLocation?{
        if(name == nil){
            return nil
        }
        let userdefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if(userdefaults.objectForKey("candidates") != nil){
            let user_data = userdefaults.objectForKey("candidates") as? NSData
            let aux = NSKeyedUnarchiver.unarchiveObjectWithData(user_data!) as! [CandidateLocation]
            for i in aux{
                if(i.getTwitter() == name){
                    print("twitter: \(i.getTwitter())")
                    return i
                }
            }
        }
        return nil
    }
    
}