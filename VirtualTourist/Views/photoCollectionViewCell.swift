//
//  photoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Abdullah Althobetey on 10/12/17.
//  Copyright © 2017 Abdullah Althobetey. All rights reserved.
//

import UIKit

class photoCollectionViewCell: UICollectionViewCell
{
    @IBOutlet private weak var photoView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var photoURL: URL? {
        
        didSet {
            
            if photoView.image == nil
            {
                activityIndicator.startAnimating()
                downloadPhoto(completionHandler: { (image) in
                    self.photoView.image = image
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }
    
    override var isSelected: Bool {
        
        didSet {
            photoView.alpha = isSelected ? 0.5 : 1.0
        }
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        photoView.image = nil
    }
    
    private func downloadPhoto(completionHandler: @escaping (UIImage?) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            
            do
            {
                let data = try Data(contentsOf: self.photoURL!)
                let image = UIImage(data: data)
                
                DispatchQueue.main.async {
                    completionHandler(image)
                }
            }
            catch let error
            {
                print(error.localizedDescription)
            }
        }
    }
}
