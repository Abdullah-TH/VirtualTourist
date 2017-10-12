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
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photoURL: URL? {
        
        didSet {
            
            if photoView.image == nil
            {
                downloadPhoto(completionHandler: { (image) in
                    self.photoView.image = image
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }
    
    override func awakeFromNib()
    {
        activityIndicator.startAnimating()
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