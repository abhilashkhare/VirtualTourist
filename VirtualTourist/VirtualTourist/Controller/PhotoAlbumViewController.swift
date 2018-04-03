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

class PhotoAlbumViewController : UIViewController,MKMapViewDelegate,UICollectionViewDelegate{

    @IBOutlet var mapView : MKMapView!
    @IBOutlet var collectionView : UICollectionView!
    var pin : Pin!
    var dataController : DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let lat = pin?.lat {
            print("Pin Lat \(lat)")
        }
    }
}
