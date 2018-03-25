//
//  OrderTableViewCell.swift
//  ding
//
//  Created by Chen Xiaoman on 22/3/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    @IBOutlet private var foodImage: UIImageView!
    @IBOutlet private var foodName: UILabel!
    @IBOutlet private var date: UILabel!
    @IBOutlet private var status: UILabel!
    
    public static let tableViewIdentifier = "OrderTableViewCell"

}
