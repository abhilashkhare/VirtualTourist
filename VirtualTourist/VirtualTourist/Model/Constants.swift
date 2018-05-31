//
//  Constants.swift
//  VirtualTourist
//
//  Created by Abhilash Khare on 4/5/18.
//  Copyright © 2018 Abhilash Khare. All rights reserved.
//

import Foundation
public struct Constants{

    struct API{
        static let API_KEY = "api_key"
        static let LAT = "lat"
        static let LON = "lon"
        static let RADIUS = "radius"
        static let APIKEY_VALUE = "c4deaa1b0a7b77672f46c6a4b145eccc"
        static let RADIUS_VALUE = "20"
        
        static let APIScheme = "https"
        static let APIHOST = "api.flickr.com"
        static let APIPATH = "/services/rest/"
        static let METHOD = "method"
        static let METHOD_VALUE = "flickr.photos.search"
        
        static let FORMAT = "format"
        static let FORMAT_VALUE = "json"
        static let NOJSONCALLBACK = "nojsoncallback"
        static let NOJSONCALLBACK_VALUE = "1"
        static let EXTRAS  = "extras"
        static let MEDIUMURL = "url_m"
        static let PAGE = "page"
        static var PAGE_VALUE = "1"
        static let PERPAGE = "per_page"
        static let PERPAGE_VALUE = "15"
    }
    
}
