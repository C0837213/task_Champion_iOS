//
//  Extensions.swift
//  task_Champion_iOS
//
//  Created by Onurcan Sever on 2022-01-27.
//

import UIKit

extension UIColor {
    static let crystalWhite = UIColor(red: 233/255, green: 236/255, blue: 244/255, alpha: 1)
    static let lightCharcoal = UIColor(red: 36/255, green: 44/255, blue: 75/255, alpha: 1)
}

extension Item {
    override public func awakeFromInsert() {
        setPrimitiveValue(Date(), forKey: "createdAt")
    }
}

