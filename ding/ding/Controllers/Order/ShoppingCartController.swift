//
//  ShoppingCartController.swift
//  ding
//
//  Created by Yunpeng Niu on 29/03/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

import Eureka

/**
 The controller for the shopping cart.

 - Author: Group 3 @ CS3217
 - Date: March 2018
 */
class ShoppingCartController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        for (stallId, cart) in ShoppingCart.shoppingCarts {
            let section = Section(cart.stall.name)
            section.tag = stallId
            form +++ section
            for (foodId, food) in cart.food {
                section <<< StepperRow { row in
                    row.title = food.food.name
                    row.value = Double(food.quantity)
                    row.tag = foodId
                }.onChange { row in
                    if let stallId = row.section?.tag, let foodId = row.tag, let value = row.value {
                        ShoppingCart.change(foodId, from: stallId, quantity: Int(value))
                    }
                }
            }
        }
    }
}
