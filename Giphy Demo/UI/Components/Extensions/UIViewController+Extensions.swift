//
//  UIViewController+Extensions.swift
//  Giphy Demo
//
//  Created by Roman on 12.04.2023.
//

import Foundation
import UIKit

public extension UIViewController {
    class func make() -> Self {
        let nibName = String(describing: Self.self)
        let bundle = Bundle(for: Self.self)
        return Self(nibName: nibName, bundle: bundle)
    }
    
    func presentSuccess(message: String) {
        presentAlert(title: "Success", message: message)
    }
    
    func presentFailure(message: String) {
        presentAlert(title: "Error", message: message)
    }
    
    func presentAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(.init(title: "OK", style: .cancel))
        present(alertVC, animated: true)
    }
}
