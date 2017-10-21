//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Abdullah Althobetey on 10/11/17.
//  Copyright © 2017 Abdullah Althobetey. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController
{
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomRedViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: ViewController's Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        bottomRedViewHeightConstraint.constant = 0
        fetchPins()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "MapToPhotos"
        {
            let annotation = sender as! MKPointAnnotation
            let photosVC = segue.destination as! PhotosViewController
            
            let stack = CoreDataStack.shared!
            let fetch = NSFetchRequest<Pin>(entityName: "Pin")
            let predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", annotation.coordinate.latitude, annotation.coordinate.longitude)
            fetch.predicate = predicate
            do
            {
                let pins = try stack.context.fetch(fetch)
                print(pins.isEmpty)
                if let pin = pins.first
                {
                    photosVC.pin = pin
                }
            }
            catch let error
            {
                let alertController = UIAlertController(title: "Cannot delete pin", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool)
    {
        if mapView.annotations.isEmpty && editing
        {
            let alertController = UIAlertController(title: "Cannot Edit", message: "There are no pins to delete. Tap and hold on the map to add pins", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            super.setEditing(false, animated: true)
        }
        else
        {
            UIView.animate(withDuration: 0.3) {
                
                self.bottomRedViewHeightConstraint.constant = editing ? 80 : 0
                self.mapViewTopConstraint.constant = editing ? -80 : 0
                self.view.layoutIfNeeded()
            }
            super.setEditing(editing, animated: animated)
        }
    }
    
    // MARK: Helper Functions
    
    private func fetchPins()
    {
        let stack = CoreDataStack.shared!
        let fetch = NSFetchRequest<Pin>(entityName: "Pin")
        do
        {
            let pins = try stack.context.fetch(fetch)
            for pin in pins
            {
                let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
            }
        }
        catch let error
        {
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Actions
    
    @IBAction func mapLongPressed(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == .ended && !isEditing
        {
            let touchLocation = sender.location(in: mapView)
            let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            let stack = CoreDataStack.shared!
            let pin = Pin(entity: Pin.entity(), insertInto: stack.context)
            pin.latitude = annotation.coordinate.latitude
            pin.longitude = annotation.coordinate.longitude
            do
            {
                try stack.saveContext()
                mapView.addAnnotation(annotation)
                print(String(format: "latitude == %lf AND longitude == %lf", annotation.coordinate.latitude, annotation.coordinate.longitude))
            }
            catch let error
            {
                let alertController = UIAlertController(title: "Cannot add pin", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
            
        }
    }
}

// MARK: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if !isEditing
        {
            performSegue(withIdentifier: "MapToPhotos", sender: view.annotation!)
            mapView.deselectAnnotation(view.annotation!, animated: true)
        }
        else
        {
            let annotation = view.annotation!
            let stack = CoreDataStack.shared!
            let fetch = NSFetchRequest<Pin>(entityName: "Pin")
            let predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", annotation.coordinate.latitude, annotation.coordinate.longitude)
            fetch.predicate = predicate
            do
            {
                let pins = try stack.context.fetch(fetch)
                print(pins.isEmpty)
                if let pin = pins.first
                {
                    print(pin.latitude, pin.longitude)
                    stack.context.delete(pin)
                    try stack.context.save()
                    mapView.removeAnnotation(view.annotation!)
                    if mapView.annotations.isEmpty
                    {
                        setEditing(false, animated: true)
                    }
                }
            }
            catch let error
            {
                let alertController = UIAlertController(title: "Cannot delete pin", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
}







