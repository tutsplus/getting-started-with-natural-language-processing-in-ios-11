//
//  TweetCell.swift
//  TwitterNLPExample
//
//  Created by Doron Katz on 11/30/17.
//  Copyright © 2017 Doron Katz. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.numberOfLines = 0
        textLabel?.font = .systemFont(ofSize: 14)
        detailTextLabel?.textColor = .darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

