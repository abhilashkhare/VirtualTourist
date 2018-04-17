//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Abhilash Khare on 4/4/18.
//  Copyright © 2018 Abhilash Khare. All rights reserved.
//

import Foundation

class FlickerClient{
    
    let session = URLSession.shared
    var pageNumber = 0
    
    func getPhotosFromFlicker(_ completionHandlerForGetPhotos : @escaping (_ success : Bool, _ result : AnyObject?, _ error : String?) -> Void){
        
        let parameters = [Constants.API.METHOD : Constants.API.METHOD_VALUE as AnyObject,
                          Constants.API.API_KEY : Constants.API.APIKEY_VALUE as AnyObject,
                          Constants.API.LAT : Values.lat as AnyObject,
                          Constants.API.LON : Values.lon as AnyObject,
                          Constants.API.FORMAT : Constants.API.FORMAT_VALUE as AnyObject,
                          Constants.API.NOJSONCALLBACK : Constants.API.NOJSONCALLBACK_VALUE as AnyObject ,
                          Constants.API.RADIUS : Constants.API.RADIUS_VALUE as AnyObject,
                          Constants.API.EXTRAS : Constants.API.MEDIUMURL as AnyObject,
                        //  Constants.API.PAGE : Constants.API.PAGE_VALUE as AnyObject,
                          Constants.API.PERPAGE : Constants.API.PERPAGE_VALUE as AnyObject] as [String : AnyObject]
        
        taskForGETMethod(parameters) { (result, error) in
            
            if error != nil{
                completionHandlerForGetPhotos(false,nil,error)
                print("error")
            } else
                if error == nil{
                    
                    if let photos = result!["photos"] as! [String:AnyObject]? {
                        if let pages = photos["pages"] as? Int {
                            let randomIndex = Int(arc4random_uniform(UInt32(pages)))
                            print("Random Index \(randomIndex)")
                            Constants.API.PAGE_VALUE = String(randomIndex)
                            print("Constants.API.PAGE_VALUE \(Constants.API.PAGE_VALUE)")
                            let parameters = [Constants.API.METHOD : Constants.API.METHOD_VALUE as AnyObject,
                                              Constants.API.API_KEY : Constants.API.APIKEY_VALUE as AnyObject,
                                              Constants.API.LAT : Values.lat as AnyObject,
                                              Constants.API.LON : Values.lon as AnyObject,
                                              Constants.API.FORMAT : Constants.API.FORMAT_VALUE as AnyObject,
                                              Constants.API.NOJSONCALLBACK : Constants.API.NOJSONCALLBACK_VALUE as AnyObject ,
                                              Constants.API.RADIUS : Constants.API.RADIUS_VALUE as AnyObject,
                                              Constants.API.EXTRAS : Constants.API.MEDIUMURL as AnyObject,
                                                Constants.API.PAGE : Constants.API.PAGE_VALUE as AnyObject,
                                Constants.API.PERPAGE : Constants.API.PERPAGE_VALUE as AnyObject] as [String : AnyObject]
                            
                            self.taskForGETMethod(parameters) { (result, error) in
                                if result != nil{
                                    completionHandlerForGetPhotos(true,result,nil)

                                } else
                                if error != nil{
                                    completionHandlerForGetPhotos(false,nil,error)

                                }
                            }
                            
                        }
                    }
        
            }
            
        }
        
    }
    
    
    func taskForGETMethod(_ parameters : [String : AnyObject] , completionHandlerForGETMethod : @escaping ( _ result : AnyObject? , _ error : String?)-> Void)  {
        let URL = parametersToURL(parameters)
        print(URL)
        let request = URLRequest(url: parametersToURL(parameters))
        
  
        let task = session.dataTask(with: request){(data,response,error) in
            
            func sendError(_ error: String) {
                print(error)
                completionHandlerForGETMethod("NULL" as AnyObject, error)
            }
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            var parsedResult : AnyObject? = nil
            
            do{
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                completionHandlerForGETMethod(parsedResult,nil)
            
            } catch {
                completionHandlerForGETMethod(nil,error.localizedDescription)
            }
            
        }
        task.resume()
    }
    
    func parametersToURL(_ parameters : [String : AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.API.APIScheme
        components.host = Constants.API.APIHOST
        components.path = Constants.API.APIPATH
        components.queryItems = [URLQueryItem]()
        
        for (key,value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        return components.url!
    }
    
    
    class func sharedInstance() -> FlickerClient {
        struct Singleton {
            static var sharedInstance = FlickerClient()
        }
        return Singleton.sharedInstance
    }
    
    
}
