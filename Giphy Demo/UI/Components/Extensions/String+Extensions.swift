//
//  String+Extensions.swift
//  Giphy Demo
//
//  Created by Roman on 12.04.2023.
//

import Foundation

extension String {
    var cgFloatValue: CGFloat {
        return CGFloat((self as NSString).floatValue)
    }
}
