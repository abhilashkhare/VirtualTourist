//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Abhilash Khare on 4/2/18.
//  Copyright © 2018 Abhilash Khare. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class PhotoAlbumViewController : UIViewController,MKMapViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate{
    
    @IBOutlet var mapView : MKMapView!
    @IBOutlet var collectionView : UICollectionView!
    var pin : Pin!
    var photos : [Photo]!
    var dataController : DataController!
    var imageURLString : [String] = []
    
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try? fetchedResultsController.performFetch()
        } catch{
            fatalError("Fetch could not be performed \(error.localizedDescription)")
        }
        
        let fetchedObjects = fetchedResultsController.fetchedObjects
        if fetchedObjects?.count == 0 {
            getPhotosFromFlickr()
        } else
            if fetchedObjects?.count != 0{
            print("Count of images \(fetchedObjects?.count)")
            
                for image in fetchedObjects! {
                    let fetchedImage  = image
                    self.photos.append(fetchedImage)
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = Values.lat
        annotation.coordinate.longitude = Values.lon
        mapView.addAnnotation(annotation)
        mapView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        print("Pin did load \(pin)")
        setupFetchedResultsController()
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
        }
        return pinView
    }
    
    func getPhotosFromFlickr( )
    {
        DispatchQueue.main.async {
            FlickerClient.sharedInstance().getPhotosFromFlicker { (success, result, error) in
                if success == false {
                    print("Error retrieving photos")
                }
                else if success == true {
                    print ("success")
                    print(result!)
                    if let photos = result!["photos"] as! [String:AnyObject]? {
                        if let photoArray = photos["photo"] as! [[String:AnyObject]]?{
                            
                            for images in photoArray{
                                let url_m = images["url_m"] as! String
                                self.imageURLString.append(url_m)
                            }
                            
                        }
                    }
                    for i in 0...self.imageURLString.count-1{
                        print(self.imageURLString[i])
                        if let imageData = try? Data(contentsOf: URL(string: self.imageURLString[i])!) {
                            let image = Photo(context: self.dataController.viewContext)
                            image.image = imageData
                            image.pin = self.pin
                            try? self.dataController.viewContext.save()
                        }
                    }
                    
                }
                
            }
            
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
         print("Pin \(pin)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as! ImageViewCell
        
        let photo = photos[indexPath.row]
        if let selectPhoto  = photo.image{
            cell.imageView.image =  UIImage(data: selectPhoto as Data)
        }
        
        return cell
    }
    
}
