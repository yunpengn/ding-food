//
//  ReviewTableViewController.swift
//  ding
//
//  Created by Chen Xiaoman on 25/3/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

import FirebaseDatabaseUI

class ReviewTableViewController: UIViewController, UITableViewDelegate {

    @IBOutlet private var reviewTableView: UITableView!
    
    /// The Firebase data source for the listing of reviews.
    var dataSource: FUITableViewDataSource?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
    }
    
    /// Binds Firebase data source to table view.
    private func configureTableView() {
        
        let orderPath = OrderHistory.path
        let childPath = Review.path + "/id"
        
        // Configures the table view.
        let query = DatabaseRef.getNodeRef(of: orderPath)
            .queryOrdered(byChild: childPath).queryEqual(toValue: "-L9mmrtVzyMwdayWXitW")
        dataSource = FUITableViewDataSource(query: query, populateCell: populateReviewCell)
        dataSource?.bind(to: reviewTableView)
        reviewTableView.delegate = self
    }
    
    /// Populates a `ReviewTableViewCell` with the given data from database.
    /// - Parameters:
    ///    - tableView: The table view as the listing of reviews.
    ///    - indexPath: The index path of this cell.
    ///    - snapshot: The snapshot of the corresponding model object from database.
    /// - Returns: a `ReviewTableViewCell` to use.
    private func populateReviewCell(tableView: UITableView,
                                          indexPath: IndexPath,
                                          snapshot: DataSnapshot) -> ReviewTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.tableViewIdentifier ,
                                                            for: indexPath) as? ReviewTableViewCell else {
                                                                fatalError("Unable to dequeue cell.")
        }
        
        guard let orderHistory = OrderHistory.deserialize(snapshot) else {
            return cell
        }
        
        // Loads the order infomation.
        cell.load(orderHistory)
        
        return cell
    }

}
