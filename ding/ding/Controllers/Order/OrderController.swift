//
//  OrderTableViewController.swift
//  ding
//
//  Created by Chen Xiaoman on 22/3/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

import DingBase
import FirebaseDatabaseUI

/**
 The controller for order view.

 - Author: Group 3 @ CS3217
 - Date: March 2018
 */
class OrderController: UIViewController {
    @IBOutlet weak private var ongoingOrders: UICollectionView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    /// Uses an explicit outlet to fix conflicit when there are more than one navigation
    /// controller in the parent control hierarchy.
    @IBOutlet weak private var currentNavigationItem: UINavigationItem!
    /// The view showing that the user has no order.
    @IBOutlet weak private var noFoodView: UIView!

    /// A collection that records all the ids of `Order`s that the users have been notified.
    private static var notified = Set<String>()
    
    /// The Firebase data source for the listing of stalls.
    var dataSource: FUICollectionViewDataSource?
    /// Indicates whether the collection view has finished loading data.
    private var loaded = false

    /// A dictionary of mapping from cell's index path to the
    /// 'Order' object represented.
    var orders: [Int: Order] = [:]
    
    /// A dictionary of mapping from cell's index path to the
    /// 'OrderHistory' object represented.
    var orderHistorys: [Int: OrderHistory] = [:]
    
    /// A boolean value indicates whether the order showing is
    /// 'OrderHistory' or not. Default is showing 'Order'
    /// which is all on-going orders
    var isShowingHistory = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Shows navigation bar with shopping cart icon, but without back.
        navigationController?.setNavigationBarHidden(false, animated: animated)

        startLoading()
        
        checkInternetConnection()
        
        /// Performs permission checking.
        guard checkPermission() else {
            return
        }

        /// Starts to load data of ongoing orders.
        configureCollectionView()

        /// Changes the navigation title according to whether show history.
        if isShowingHistory {
            currentNavigationItem.title = "Order History"
        } else {
            currentNavigationItem.title = "On-going Orders"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stops sending updates to the collection view (to avoid app crash).
        dataSource?.unbind()
        // Stops the loading indicator (such that the timeout thread will not be triggered later).
        loadingIndicator.stopAnimating()
        stopCheckingInternetConnection()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.ongoingOrderToShoppingCartId else {
            return
        }
        if UIView.onPhone {
            segue.destination.modalPresentationStyle = .none
        }
    }

    /// Binds Firebase data source to collection view.
    private func configureCollectionView() {
        // Chooses between showing Order or OrderHistory.
        var orderPath = Order.path
        var childPath = Order.custemerIdPath
        if isShowingHistory {
            orderPath = OrderHistory.path
            childPath = OrderHistory.orderPath + Order.custemerIdPath
        }
        
        // Configures the order list's query.
        let query = DatabaseRef.getNodeRef(of: orderPath)
            .queryOrdered(byChild: childPath).queryEqual(toValue: authorizer.userId)
        // Checks whether the order list is empty first.
        query.observe(.value, with: checkEmptyOrder)
        // Configures the collection view
        loadCollectionViewData(with: query)
    }
    
    /// Checks if the user has any order.
    /// If not, stops the loading indicator and shows empty order image.
    private func checkEmptyOrder(snapshot: DataSnapshot) {
        if snapshot.exists() {
            // The order list is not empty
            noFoodView.isHidden = true
        } else {
            // The order list is empty
            stopLoading()
            noFoodView.isHidden = false
        }
    }
    
    /// Populate data in Firebase to collection view.
    private func loadCollectionViewData(with query: DatabaseQuery) {
        dataSource = FUICollectionViewDataSource(query: query, populateCell: populateOngoingOrderCell)
        dataSource?.bind(to: ongoingOrders)
        ongoingOrders.delegate = self
    }

    /// Populates a `OngoingOrderCell` with the given data from database.
    /// - Parameters:
    ///    - collectionView: The collection view as the listing of ongoing orders.
    ///    - indexPath: The index path of this cell.
    ///    - snapshot: The snapshot of the corresponding model object from database.
    /// - Returns: a `StallListingCell` to use.
    private func populateOngoingOrderCell(collectionView: UICollectionView,
                                          indexPath: IndexPath,
                                          snapshot: DataSnapshot) -> OngoingOrderCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OngoingOrderCell.identifier,
                                                            for: indexPath) as? OngoingOrderCell else {
            fatalError("Unable to dequeue cell.")
        }

        // Stops the loading indicator.
        if !loaded {
            stopLoading()
        }
        
        var currentOrder: Order
        // Deserialize from the correct class
        // Whether Order or OrderHistory
        if isShowingHistory {
            guard let orderHistory = OrderHistory.deserialize(snapshot) else {
                return cell
            }
            currentOrder = orderHistory.order
            // Stores this OrderHistory for further retrieval.
            orderHistorys[indexPath.totalItem(in: collectionView)] = orderHistory
        } else {
            guard let order = Order.deserialize(snapshot) else {
                return cell
            }
            currentOrder = order
        }
        
        // Loads the order infomation.
        cell.load(currentOrder)
        
        // Loads the related stall overview.
        let path = "\(StallOverview.path)/\(currentOrder.stallId)"
        DatabaseRef.observeValueOnce(of: path, onChange: cell.loadStoreOverview)
            
        // Stores this order for further retrieval.
        orders[indexPath.totalItem(in: collectionView)] = currentOrder

        // Notifies when the order is ready and it has not been notified before.
        if currentOrder.status == .ready && !OrderController.notified.contains(currentOrder.id) {
            notifyOrderStatus(currentOrder)
            OrderController.notified.insert(currentOrder.id)
        }

        return cell
    }
    
    /// Stops the loading indicator and changes the `loaded` status.
    private func stopLoading() {
        loaded = true
        loadingIndicator.stopAnimating()
    }
    
    /// Starts the loading indicator and changes the `loaded` status.
    private func startLoading() {
        loaded = false
        loadingIndicator.startAnimating()
    }

    /// Pushes a notification when an order becomes ready.
    /// - Parameter order: The order becoming ready.
    private func notifyOrderStatus(_ order: Order) {
        NotificationController.notify(id: order.id, title: "Your order is \(order.status.rawValue)",
                                      subtitle: "", body: order.description)
    }
}
