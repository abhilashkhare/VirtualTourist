//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Abhilash Khare on 4/2/18.
//  Copyright © 2018 Abhilash Khare. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit

class PhotoAlbumViewController : UIViewController,MKMapViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate{
    
    @IBOutlet var mapView : MKMapView!
    @IBOutlet var collectionView : UICollectionView!
    @IBOutlet var newCollectionButton : UIButton!
    var pin : Pin!
    var photos = [Photo]()
    var dataController : DataController!
    var imageURLString : [String] = []
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    var fetchedResultsController : NSFetchedResultsController<Photo>!
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@",  argumentArray: [self.pin])
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try? fetchedResultsController.performFetch()
        } catch{
            fatalError("Fetch could not be performed \(error.localizedDescription)")
        }
        
        let fetchedObjects = fetchedResultsController.fetchedObjects
        print(fetchedObjects?.count)
            if fetchedObjects?.count != 0{
            print("Count of images \(fetchedObjects?.count)")
            
                for image in fetchedObjects! {
                    let fetchedImage  = image
                    self.photos.append(fetchedImage)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
        }
        if fetchedObjects?.count == 0 {
            getPhotosFromFlickr()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = Values.lat
        annotation.coordinate.longitude = Values.lon
        mapView.addAnnotation(annotation)
        mapView.delegate = self
        print("Pin did load \(pin)")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        

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
                    if self.imageURLString.count > 0 {
                    for i in 0...self.imageURLString.count-1{
                        print(self.imageURLString[i])
                        if let imageData = try? Data(contentsOf: URL(string: self.imageURLString[i])!) {
                            let image = Photo(context: self.dataController.viewContext)
                            image.image = imageData
                            self.photos.append(image)
                        
                            image.pin = self.pin
                            try? self.dataController.viewContext.save()
                        }
                    }
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        
                    }
                    else
                    {
                        print("No Pics found")
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
        
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        DispatchQueue.main.async {
            self.setupFetchedResultsController()
            self.collectionView.reloadData()
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            print("numberOfItemsInSection \(photos.count)")
            return photos.count
   
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as! ImageViewCell
        cell.activityIndicatorView.hidesWhenStopped = true
        cell.activityIndicatorView.startAnimating()
        cell.activityIndicatorView.isHidden = false
        let photo = photos[indexPath.row]
        if let selectPhoto  = photo.image{
            cell.activityIndicatorView.stopAnimating()
            cell.imageView.image =  UIImage(data: selectPhoto as Data)
        }
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
      let alert = UIAlertController(title: nil, message: "Delete Picture ? ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in
            self.dataController.viewContext.delete(self.photos[indexPath.row])
            self.photos.remove(at: indexPath.row )
            
            DispatchQueue.main.async {
                do {
                    try self.dataController.viewContext.save()
                    self.collectionView.deleteItems(at: [indexPath])
                    collectionView.reloadData()
                }
                catch{
                    print("Error \(error.localizedDescription)")
                }
                
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    @IBAction func tapNewCollection( _ sender : Any){

        DispatchQueue.main.async {
        self.photos = []
        self.imageURLString = []
        self.collectionView.reloadData()
        }
        
        for item in photos {
            self.dataController.viewContext.delete(item)
            
        }
        print("Photo count \(photos.count)")

        try? dataController.viewContext.save()
        
        getPhotosFromFlickr()
        self.collectionView.reloadData()
    }
    

}
