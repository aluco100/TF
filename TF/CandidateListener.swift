//
//  CandidateListener.swift
//  TF
//
//  Created by Alfredo Luco on 08-12-15.
//  Copyright © 2015 Alfredo Luco. All rights reserved.
//

import Foundation
protocol CandidateListener{
    func candidatesReload(candidates: [CandidateLocation]) -> Void
}