//
//  StallDetails.swift
//  ding
//
//  Created by Calvin Tantio on 17/3/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

import DingBase
import FirebaseDatabase

/**
 `StallDetail` contains stall information that are not shown in `StallOverview`.
 Currently it contains only a collection of  food that this stall has.
 Any two `Food` objects inside `StallDetail` should not have same `id`
 */
public struct StallDetails: DatabaseObject {

    public static var path = "/stalls"

    public let id: String

    /// A dictionary of (food id, food) pair
    public var menu: [String: Food]?

    private var menuPath: String {
        return StallDetails.path + "/\(Account.stallId)" + Food.path
    }

    /// Add the a new kind of food into menu
    /// If the food with same id already exists in menu, it will be overwritten
    /// - Parameter:
    ///    - addedFood: The food to be added in menu
    public mutating func addFood(_ addedFood: Food) {
        if menu == nil {
            menu = [String: Food]()
        }
        menu?[addedFood.id] = addedFood
        DatabaseRef.setChildNode(of: menuPath, to: addedFood)
    }

    /// Delete the certain food by its id. If the food has photo, it will also be removed from storage
    /// do nothing if the food id does not exist in menu.
    /// - Parameter: id: the food id
    public mutating func deleteFood(by id: String) {
        guard let foodToDelete = menu?[id] else {
            return
        }
        // Remove the food photo from storage if applicable
        if let photoPath = foodToDelete.photoPath {
            StorageRef.delete(at: photoPath)
        }
        menu?[id] = nil
        DatabaseRef.deleteChildNode(of: menuPath + "/\(id)")
    }

    /// Overrided function to handle nested structure.
    /// See `DatabaseObject.deserialize(_ snapshot: DataSnapshot)`
    public static func deserialize(_ snapshot: DataSnapshot) -> StallDetails? {
        guard var dict = snapshot.value as? [String: Any] else {
            return nil
        }
        dict["id"] = snapshot.key
        if let menuDict = dict["menu"] as? [String: Any] {
            dict["menu"] = prepareNestedDeserialize(menuDict)
        }
        return deserialize(dict)
    }
}
