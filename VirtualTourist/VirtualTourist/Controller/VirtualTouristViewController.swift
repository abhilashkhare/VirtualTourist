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

class VirtualTouristViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deletePinsLabel: UILabel!
    
    var dataController : DataController!
    var pins : [Pin] = []
    var annotations = [MKPointAnnotation]()
    let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
    var toggleDelete : Bool = false
    
    var longPressGestureRecognizer : UILongPressGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
       deletePinsLabel.isHidden = true
       deletePinsLabel.isEnabled = false
    
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,action: #selector(addAnnotations(longPressgestureRecongizer :)))
        longPressGestureRecognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPressGestureRecognizer)

        
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            print("Pin count \(pins.count)")
            for i in pins{
                let lat = i.lat
                print("lat \(lat)")
                let lon = i.lon
                print("lon \(lon)")
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = lat
                annotation.coordinate.longitude = lon
                annotations.append(annotation)
            }
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.annotations)
            }
            
        }
    }


    @IBAction func pressEdit(_ sender: Any) {
        if(editButton.title == "Edit"){
        deletePinsLabel.isHidden = false
        deletePinsLabel.isEnabled = true
        editButton.title = "Done"
        toggleDelete = true
        
            
    }
    else{
    deletePinsLabel.isHidden = true
    deletePinsLabel.isEnabled = false
    editButton.title = "Edit"
    toggleDelete = false
    }
    }
    

 
    
    @objc func addAnnotations(longPressgestureRecongizer : UILongPressGestureRecognizer){
        
        if longPressgestureRecongizer.state == UIGestureRecognizerState.began {
            var touchPoint = longPressgestureRecongizer.location(in: mapView)
            var newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
           let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            annotations.append(annotation)

            let pin = Pin(context: self.dataController.viewContext)
            pin.lat = annotation.coordinate.latitude
            pin.lon = annotation.coordinate.longitude
            try? dataController.viewContext.save()
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            
            
        }
        else {
            pinView!.annotation = annotation
            pinView!.pinTintColor = .red
        }
        
        return pinView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didselect")
        print("toggledelete  \(toggleDelete)")
//            selectPin(selectedPin as! Pin)
        if(toggleDelete == false){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            if let lat = view.annotation?.coordinate.latitude  {
                viewController.pin?.lat = lat
            }
            if let lon = view.annotation?.coordinate.longitude {
                viewController.pin?.lon = lon
            }
            viewController.dataController = self.dataController
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        
        else if (toggleDelete == true){
            if let lat = view.annotation?.coordinate.latitude, let lon = view.annotation?.coordinate.longitude{
                if let result = try? dataController.viewContext.fetch(fetchRequest){
                    for i in result {
                        if((i.lat == lat) && (i.lon == lon)){
                            dataController.viewContext.delete(i)
                            try? dataController.viewContext.save()
                            let annotation = MKPointAnnotation()
                            annotation.coordinate.latitude = lat
                            annotation.coordinate.longitude = lon
                            print("annotation.coordinate.latitude \(annotation.coordinate.latitude)")
                            print("lat \(lat)")
                            print("annotation.coordinate.longitude \(annotation.coordinate.longitude)")
                            print("lon \(lon)")

                            mapView.removeAnnotation(annotation)
                        }
                    }
            }
         }
        }
    }

    


    
}

