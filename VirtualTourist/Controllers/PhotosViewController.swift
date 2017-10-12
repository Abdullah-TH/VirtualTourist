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
    var photoURLs: [URL]?
    
    // MARK: ViewController's Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureMapView()
        setPlaceNameAsTitle()
        initiatePhotosDownload()
    }
    
    // MARK: Helper Functions
    
    private func configureMapView()
    {
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
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
            else
            {
                self.title = "Unknown"
            }
            
            if let countryName = placeMark.country
            {
                self.title = "\(countryName), \(self.title ?? "")"
            }
            
        })
    }
    
    private func initiatePhotosDownload()
    {
        let epsilon = 0.01
        let minLong = annotation.coordinate.longitude - epsilon
        let minLat = annotation.coordinate.latitude - epsilon
        let maxLong = annotation.coordinate.longitude + epsilon
        let maxLat = annotation.coordinate.latitude + epsilon
        FlickrClient.getPhotosBy(minLong: minLong, minLat: minLat, maxLong: maxLong, maxLat: maxLat) { (error, urls) in
            
            if error == nil
            {
                self.photoURLs = urls
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            else
            {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension PhotosViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoURLs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! photoCollectionViewCell
        cell.photoURL = photoURLs?[indexPath.row]
        return cell
    }
}







