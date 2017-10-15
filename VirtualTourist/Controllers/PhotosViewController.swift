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
                    if self.photoURLs!.isEmpty
                    {
                        self.collectionView.isHidden = true
                    }
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

extension PhotosViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var width = collectionView.bounds.width
        width = width / 3.0 // width of each three cells
        
        // spacing between a cell and other cell, or edge, is 6
        // between three cells, there are 4 such spacing |1[]2[]3[]4|
        // so each cell should be subtracted by 6 for the spacing
        // but there is one (6 point space) remained
        // this space should be distributed among the three cells: 6/3 = 2
        // so each cell is subtracted by 6 + 2 = 8
        width = width - 8
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }
}







