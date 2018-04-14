//
//  Stall.swift
//  ding
//
//  Created by Yunpeng Niu on 27/03/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

import FirebaseDatabase

/**
 `StallOverview` represents an overview of a stall, which could be used in the stall
 listing table view.

 - Author: Group 3 @ CS3217
 - Date: March 2018
 */
struct StallOverview: DatabaseObject {
    static let path = "/stall_overviews"
    
    let id: String
    let name: String
    let queueCount: Int
    let averageRating: Double
    let photoPath: String
    let location: String
    let openingHour: String
    let description: String
    let filters: [String: Filter]?

    /// A custom deserialization method to handle the nested `DatabaseObject` structure.
    /// - Parameter snapshot: The `DataSnapshot` containing information about the stall.
    /// - Returns: A `StallOverview` object; or nil if the conversion fails.
    static func deserialize(_ snapshot: DataSnapshot) -> StallOverview? {
        guard var dict = snapshot.value as? [String: Any] else {
            return nil
        }
        dict["id"] = snapshot.key
        if let filterDict = dict["filters"] as? [String: Any] {
            dict["filters"] = prepareNestedDeserialize(filterDict)
        }
        return deserialize(dict)
    }
}