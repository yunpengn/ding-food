//
//  AccountController.swift
//  ding-stall
//
//  Created by Jiang Chunhui on 14/04/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

/**
 The controller that handles the current login user account
 */
class AccountController {

    weak var loginDelegate: LoginDelegate?

    /// Set the uid into `Account` struct
    /// If the id is not empty, it will download the
    /// `StallDetail`, `StallOverview` and `Filters` objects from database
    /// Parameter: uid: the id of current login user account
    func setStallId(_ uid: String) {
        Account.stallId = uid
        guard uid != "" else {
            return
        }
        downloadStall(withId: uid)
    }

    /// Download the stall object from database
    private func downloadStall(withId uid: String) {

        DatabaseRef.observeValueOnce(of: StallDetails.path + "/\(uid)") { snapshot in
            Account.stall = StallDetails.deserialize(snapshot)
            if Account.stall == nil {
                Account.stall = StallDetails(id: uid, menu: nil)
            }
            // Stop observing to avoid memory leak
            DatabaseRef.stopObservers(of: StallDetails.path + "/\(uid)")
        }
        
        DatabaseRef.observeValueOnce(of: StallOverview.path + "/\(uid)") { snapshot in
            Account.stallOverview = StallOverview.deserialize(snapshot)
            guard Account.isCorrectAccount else {
                self.loginDelegate?.handleWrongAccountType()
                return
            }
            DatabaseRef.stopObservers(of: StallOverview.path + "/\(uid)")
        }

        DatabaseRef.observeValueOnce(of: Filter.path) { snapshot in
            Account.allFilters = Filter.deserializeArray(snapshot)
            DatabaseRef.stopObservers(of: Filter.path)
        }
    }
    
}
