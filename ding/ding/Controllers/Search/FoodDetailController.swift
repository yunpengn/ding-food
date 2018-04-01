//
//  FoodDetailViewController.swift
//  ding
//
//  Created by Chen Xiaoman on 23/3/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

import FirebaseDatabaseUI

/**
 The controller for food details view.

 - Author: Group 3 @ CS3217
 - Date: March 2018
 */
class FoodDetailController: UIViewController {
    /// The view to display information about the food.
    @IBOutlet weak private var foodOverviewView: FoodOverviewView!

    /// The current food object.
    var food: Food?
    /// The id of the current stall.
    var stall: StallOverview?

    /// The text format to display view title.
    private static let titleFormat = "%@ - %@"
    
    override func viewWillAppear(_ animated: Bool) {
        // Displays the food information.
        if let food = food {
            foodOverviewView.load(food: food)
        }

        // Configures the navigation bar.
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "shopping-cart"), style: .plain, target: self, action: #selector(openShoppingCart))
        navigationItem.setRightBarButton(item, animated: animated)
        if let stallName = stall?.name, let foodName = food?.name {
            title = String(format: FoodDetailController.titleFormat, stallName, foodName)
        }
    }

    /// Adds the food to the shopping cart when the button is pressed.
    /// - Parameter sender: The button being pressed.
    @IBAction func addToShoppingCart(_ sender: MenuButton) {
        guard let currentStall = stall, let currentFood = food else {
            return
        }
        ShoppingCart.addOrChange(currentFood, from: currentStall, quantity: 1)
        openShoppingCart()
    }

    /// Opens the shopping cart when the button on the navigation bar is pressed.
    @objc
    func openShoppingCart() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "shoppingCartController")
            as? ShoppingCartController else {
            fatalError("Cannot find the controller.")
        }
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }
}
