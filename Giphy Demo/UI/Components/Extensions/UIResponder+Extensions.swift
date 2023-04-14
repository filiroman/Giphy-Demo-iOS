//
//  UIResponder+Extensions.swift
//  Giphy Demo
//
//  Created by Roman on 14.04.2023.
//

import Foundation
import UIKit

extension UIResponder {
    static var identifier: String {
        return String(describing: Self.self)
    }
}
