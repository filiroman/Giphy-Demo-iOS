//
//  MosaicCell.swift
//  Giphy Demo
//
//  Created by Roman on 12.04.2023.
//

import UIKit
import Gifu

class MosaicCell: UICollectionViewCell {

    @IBOutlet weak var shimmeringView: ShimmeringView!
    @IBOutlet weak var imageView: GIFImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shimmeringView.backgroundColor = UIColor.randomColor()
        shimmeringView.startShim()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.prepareForReuse()
        imageView.image = nil
        
        shimmeringView.startShim()
    }
    
    func setup(withAnimationData data: Data) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.animate(withGIFData: data)
            self?.shimmeringView.stopShim()
        }
    }
}
