//
//  UIColor+Extensions.swift
//  Giphy Demo
//
//  Created by Roman on 12.04.2023.
//

import Foundation
import UIKit

extension UIColor {
    class func randomColor() -> UIColor {
        func randomComponent() -> CGFloat {
            let precision: UInt32 = 255
            return CGFloat(arc4random_uniform(precision + 1)) / CGFloat(precision)
        }
        return UIColor(red: randomComponent(),
                       green: randomComponent(),
                       blue: randomComponent(),
                       alpha: 1)
    }
}
