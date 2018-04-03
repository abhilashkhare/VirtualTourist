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
    @IBOutlet weak var deletePinButton: UIButton!
    
    var dataController : DataController!
    var pins : [Pin] = []
    var annotations = [MKPointAnnotation]()
    let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
    
    var longPressGestureRecognizer : UILongPressGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
       deletePinButton.isHidden = true
       deletePinButton.isEnabled = false
    
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
//            selectPin(selectedPin as! Pin)
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
    

    
//    func selectPin(_ selectedPin : Pin){
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
//        viewController.pin = selectedPin
//        viewController.dataController = self.dataController
//        self.navigationController?.pushViewController(viewController, animated: true)
//    }


 
    
}

