//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Abhilash Khare on 3/29/18.
//  Copyright © 2018 Abhilash Khare. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VirtualTouristViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deletePinButton: UIButton!
    
    var dataController : DataController!
    var pins : [Pin] = []
    
    var longPressGestureRecognizer : UILongPressGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
       deletePinButton.isHidden = true
       deletePinButton.isEnabled = false
    
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,action: #selector(addAnnotations(longPressgestureRecongizer :)))
        longPressGestureRecognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPressGestureRecognizer)

        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            print(pins.count)
        }
    }


    @IBAction func pressEdit(_ sender: Any) {
        if(editButton.title == "Edit"){
        deletePinButton.isHidden = false
        deletePinButton.isEnabled = true
        editButton.title = "Done"
    }
    else{
    deletePinButton.isHidden = true
    deletePinButton.isEnabled = false
    editButton.title = "Edit"
    }
    }
    @IBAction func deletePinsMethod(_ sender: Any) {
     
    }
    
    @objc func addAnnotations(longPressgestureRecongizer : UILongPressGestureRecognizer){
        
        if longPressgestureRecongizer.state == UIGestureRecognizerState.began {
            var touchPoint = longPressgestureRecongizer.location(in: mapView)
            var newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
            
            let pin = Pin(context: self.dataController.viewContext)
            pin.lat = annotation.coordinate.latitude
            pin.lon = annotation.coordinate.longitude
            try? dataController.viewContext.save()
            
        }
        
    }
 
    
}

