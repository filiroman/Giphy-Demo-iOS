//
//  ShimmeringView.swift
//  Giphy Demo
//
//  Created by Roman on 14.04.2023.
//

import Foundation
import UIKit

final class ShimmeringView: UIView {
    private var gradientLayer: CAGradientLayer?
    
    func startShim() {
        guard gradientLayer == nil else { return }
        
        let lightColor = UIColor.white.withAlphaComponent(0.9).cgColor
        let blackColor = UIColor.black.withAlphaComponent(1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        self.gradientLayer = gradientLayer
        gradientLayer.colors = [lightColor, blackColor, lightColor]
        gradientLayer.frame = UIScreen.main.bounds
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations =  [0.0, 0.1, 0.2]
        self.layer.mask = gradientLayer
        
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-0.2, -0.1, 0.0]
        animation.toValue = [1.0, 1.1, 1.2]
        animation.duration = CFTimeInterval(1.5)
        animation.repeatCount = .infinity
        CATransaction.setCompletionBlock { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.layer.mask = nil
        }
        gradientLayer.add(animation, forKey: "shimmeringAnimation")
        CATransaction.commit()
    }
    
    func stopShim() {
        self.layer.mask = nil
        self.gradientLayer = nil
      }
}
