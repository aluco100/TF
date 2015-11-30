//
//  TweetsListener.swift
//  TF
//
//  Created by Alfredo Luco on 28-11-15.
//  Copyright © 2015 Alfredo Luco. All rights reserved.
//

import Foundation
import SwifteriOS

protocol TweetsListener{
    func onTweetsReload(tweets: [JSONValue]) -> Void
}