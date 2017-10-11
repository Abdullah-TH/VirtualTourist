//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Abdullah Althobetey on 10/11/17.
//  Copyright © 2017 Abdullah Althobetey. All rights reserved.
//

import UIKit
import MapKit

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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "MapToPhotos"
        {
            let annotation = sender as! MKPointAnnotation
            let photosVC = segue.destination as! PhotosViewController
            photosVC.annotation = annotation
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
    
    // MARK: Actions
    
    @IBAction func mapLongPressed(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == .ended && !isEditing
        {
            let touchLocation = sender.location(in: mapView)
            let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
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
            mapView.removeAnnotation(view.annotation!)
            if mapView.annotations.isEmpty
            {
                setEditing(false, animated: true)
            }
        }
    }
}







