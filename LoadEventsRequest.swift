//
//  LoadEventsRequest.swift
//  Evenz
//
//  Created by Dmitry Savin on 12/21/15.
//  Copyright © 2015 Engineering Idea. All rights reserved.
//

import Foundation
import Alamofire

/// Request to load events
class LoadEventsRequest: ServerRequest {
    
    /// Cities for events filtring.
    var cities: [City] = []
    
    /// Property for event categories.
    var eventCategories: [EventCategory]?
    
    /// Dates for events filtring.
    var dates: Array <NSDate>?
    
    /// Page of events on server.
    var page: Int?
    
    /// Total amount of pages on server.
    var pagesCount: Int?
    
    /// Location for search events
    var location: CLLocation?
    
    /// Radius for search events
    var radius: Int?
    
    var request: Request?
    
    
    //MARK: - Interface -
    
    convenience init(
        dates: Array <NSDate>,
        eventCategories: [EventCategory]?,
        cities: [City]?,
        page: Int?) {
            
        self.init()

        self.dates = dates
        self.eventCategories = eventCategories
        self.cities = cities ?? []
        self.page = page
    }
    
    func resumeWithCompletionClosure(closure: (LoadEventRequest)->()) {
        
        let eventCategoriesIds = self.eventCategories?.map( { $0.categoryId } ).joinWithSeparator(",")
        let eventCitiesNames = self.cities.map( { $0.name } ).joinWithSeparator(",")
        
        var parameters = [String: AnyObject]()
        parameters["keyword"] = ""
        parameters["category"] = eventCategoriesIds
        
        parameters["dates"] = self.dates
        parameters["page_number"] = page
        
        if location != nil && radius != nil {
            let miles = String(format: "%i%@", radius!, "mi")
            parameters["within"] = miles
            parameters["longitude"] = location?.coordinate.longitude
            parameters["latitude"] = location?.coordinate.latitude
        } else {
            parameters["city"] = eventCitiesNames
        }
        
        request = Alamofire.request(.GET, self.baseUrlString + "/Search", parameters: parameters)
            .responseJSON { response in switch response.result {
                
                case .Success(let responseObject):
                    if let responseDictionary = responseObject as? NSDictionary {
                        self.parseResponse(responseDictionary)
                    }
                    
                    closure(self)
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    self.error = error
                }
        }
    }
    
    override func cancel() {
        request?.cancel()
    }
    
    
    //MARK: - Privates -
    
    private func parseResponse(dictionary: NSDictionary) {
        let pagenationDictionary = dictionary["pagination"] as? NSDictionary
        
        if let result = pagenationDictionary!["page_count"] as? Int {
            pagesCount = result
        }
        
        if let result = pagenationDictionary!["page_number"] as? Int {
            page = result
        }
        
        if let eventsInfo = dictionary.valueForKey("events") as? NSArray {
            for eventInfo in eventsInfo {
                if let e = eventInfo as? [String: AnyObject] {
                    let event = Event(objectFromDictionary: e)
                    self.objects.append(event)
                }
            }
        }
    }
}
