//
//  Stall.swift
//  ding
//
//  Created by Calvin Tantio on 17/3/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

/**
 Represents a food stall registered in the application.
 */
public struct StallDetails: FirebaseObject {
    public static let path = "/stalls"

    public let id: String
    public var name: String
//    public var queue: [Order]
    public var menu: [Food]
//    public var filters: Set<FilterIdentifier>

}
