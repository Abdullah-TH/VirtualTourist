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
    
    var photo: Photo? {
        
        didSet {
            
            if let photo = photo
            {
                if photo.imageData == nil
                {
                    activityIndicator.startAnimating()
                    downloadPhoto(completionHandler: {
                        
                        do
                        {
                            try CoreDataStack.shared!.saveContext()
                        }
                        catch let error
                        {
                            print(error)
                        }
                        
                        if let imageData = photo.imageData
                        {
                            self.photoView.image = UIImage(data: imageData)
                        }
                        self.activityIndicator.stopAnimating()
                    })
                }
                else
                {
                    self.photoView.image = UIImage(data: photo.imageData!)
                }
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
    
    private func downloadPhoto(completionHandler: @escaping () -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            
            do
            {
                let url = URL(string: self.photo!.imageURL!)!
                let data = try Data(contentsOf: url)
                
                DispatchQueue.main.async {
                    
                    self.photo!.imageData = data
                    completionHandler()
                }
            }
            catch let error
            {
                print(error.localizedDescription)
            }
        }
    }
}
