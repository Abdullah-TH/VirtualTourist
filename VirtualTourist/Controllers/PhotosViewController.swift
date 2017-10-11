//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Abdullah Althobetey on 10/11/17.
//  Copyright © 2017 Abdullah Althobetey. All rights reserved.
//

import UIKit
import MapKit

class PhotosViewController: UIViewController
{
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    
    var annotation: MKPointAnnotation!
    
    // MARK: ViewController's Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureMapView()
        setPlaceNameAsTitle()
    }
    
    // MARK: Helper Functions
    
    private func configureMapView()
    {
        mapView.addAnnotation(annotation)
        mapView.centerCoordinate = annotation.coordinate
        mapView.isUserInteractionEnabled = false
    }
    
    private func setPlaceNameAsTitle()
    {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if let locationName = placeMark.name
            {
                self.title = locationName
            }
            else if let countryName = placeMark.country
            {
                self.title = countryName
            }
            else
            {
                self.title = "Unknown"
            }
            
        })
    }
}







