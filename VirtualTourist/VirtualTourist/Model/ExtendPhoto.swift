//
//  ExtendPhoto.swift
//  VirtualTourist
//
//  Created by Abhilash Khare on 4/17/18.
//  Copyright © 2018 Abhilash Khare. All rights reserved.
//

import Foundation
import CoreData

extension Photo  {
    convenience init(imageURL : String, context : NSManagedObjectContext) {
        self.init(context: context)
        self.url = imageURL
    }
}
