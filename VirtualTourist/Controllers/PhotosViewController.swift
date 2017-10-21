//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Abdullah Althobetey on 10/11/17.
//  Copyright © 2017 Abdullah Althobetey. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController
{
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    
    // MARK: Properties
    
    var pin: Pin!
    var photos = [Photo]()
    
    // MARK: ViewController's Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = true
        configureMapView()
        setPlaceNameAsTitle()
        toolBarButton.isEnabled = false
        if pin.photos!.count == 0
        {
            initiatePhotosDownload()
        }
        else
        {
            for photo in pin.photos!
            {
                photos.append(photo as! Photo)
            }
            toolBarButton.isEnabled = true
        }
    }
    
    // MARK: Actions
    
    @IBAction func toolBarButtonPressed(_ sender: UIBarButtonItem)
    {
        if sender.title == "Remove Selected Photos"
        {
            if let indexPaths = collectionView.indexPathsForSelectedItems
            {
                var deletedPhotos = [Photo]()
                
                collectionView.performBatchUpdates({
                    
                    for indexPath in indexPaths.sorted().reversed()
                    {
                        let deletedPhoto = self.photos.remove(at: indexPath.row)
                        deletedPhotos.append(deletedPhoto)
                    }
                    self.collectionView.deleteItems(at: indexPaths)
                    
                }, completion: { (success) in
                    
                    if success
                    {
                        let stack = CoreDataStack.shared!
                        for deletedPhoto in deletedPhotos
                        {
                            stack.context.delete(deletedPhoto)
                        }
                        
                        do
                        {
                            try stack.saveContext()
                        }
                        catch let error
                        {
                            print(error)
                        }
                        
                        if self.photos.isEmpty
                        {
                            self.collectionView.isHidden = true
                            
                        }
                    }
                })
            }
            
            toolBarButton.title = "New Collection"
        }
        else if sender.title == "New Collection"
        {
            do
            {
                let stack = CoreDataStack.shared!
                for photo in pin.photos!
                {
                    let photo = photo as! Photo
                    stack.context.delete(photo)
                }
                try stack.context.save()
                photos.removeAll()
                collectionView.reloadData()
                initiatePhotosDownload()
            }
            catch let error
            {
                print(error)
            }
        }
    }
    
    // MARK: Helper Functions
    
    private func configureMapView()
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.isUserInteractionEnabled = false
    }
    
    private func setPlaceNameAsTitle()
    {
        let geoCoder = CLGeocoder()
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let minLong = annotation.coordinate.longitude - epsilon
        let minLat = annotation.coordinate.latitude - epsilon
        let maxLong = annotation.coordinate.longitude + epsilon
        let maxLat = annotation.coordinate.latitude + epsilon
        FlickrClient.getPhotosBy(minLong: minLong, minLat: minLat, maxLong: maxLong, maxLat: maxLat) { (error, urls) in
            
            if error == nil
            {
                DispatchQueue.main.async {
                    
                    for url in urls!
                    {
                        let photo = Photo(entity: Photo.entity(), insertInto: CoreDataStack.shared!.context)
                        photo.imageURL = url.absoluteString
                        photo.pin = self.pin
                        self.photos.append(photo)
                        print(photo)
                    }
                    
                    do
                    {
                        try CoreDataStack.shared!.saveContext()
                    }
                    catch let error
                    {
                        print(error)
                    }
                    
                    self.collectionView.reloadData()
                    if self.photos.isEmpty
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
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! photoCollectionViewCell
        let photo = photos[indexPath.row]
        cell.photo = photo
        return cell
    }
}

extension PhotosViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath) as! photoCollectionViewCell
        cell.isSelected = true
        toolBarButton.title = "Remove Selected Photos"
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        if collectionView.indexPathsForSelectedItems!.isEmpty
        {
            toolBarButton.title = "New Collection"
        }
    }
    
    
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var width = collectionView.bounds.width
        width = width / 3.0 // width of each cell in a row of three cells
        
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







