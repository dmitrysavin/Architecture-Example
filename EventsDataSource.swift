//
//  EventsDataSource.swift
//  Evenz
//
//  Created by Serg Melnik on 12/21/15.
//  Copyright © 2015 Engineering Idea. All rights reserved.
//

import UIKit

/// Data source for events.
class EventsDataSource: DataSource {
    
    /// Property for array of events.
    var eventCategories: [EventCategory]?
    
    /// Cities for events filtring.
    var cities: [City] = []

    /// Dates for events filtring.
    var dates: Array <NSDate>?
    
    /// Page of events.
    var page = 1
    
    /// Location for search events
    var location: CLLocation?
    
    /// Radius for search events
    var radius: Int?
    
    private var loadEventRequest: LoadEventRequest?
    
    
    //MARK: - Interface -
    
    /// Triggers server request to load events.
    func reloadData() {
        sections.removeAll()
        
        loadEventRequest?.cancel()
        
        page = 1
        loading = true
        sections.removeAll()
        
        notifyListenersWillLoadItems()
        
        loadEventRequest = LoadEventRequest(
            startDate: startDate,
            endDate: endDate,
            eventCategories: eventCategories,
            cities: cities,
            page: page)
        loadEventRequest?.location = location
        loadEventRequest?.radius = radius
        
        loadEventRequest?.resumeWithCompletionClosure({ [weak self] (request: LoadEventRequest) -> () in
            if self?.isReqeustValid(request) == false {
                return
            }
            
            self?.loading = false
            
            if request.objects.count > 0 {
                self?.sections.append(request.objects)
            }
            
            self?.notifyListenersDidLoadItems()
            
            if request.pagesCount > self?.page {
                self?.loadNextPage()
            }
        })
    }
    
    
    //MARK: - Private -
    
    private func loadNextPage() {
        page += 1
        
        notifyListenersWillLoadItems()
        
        loadEventRequest = LoadEventRequest(
            dates: dates!,
            eventCategories: eventCategories,
            cities: cities,
            page: page)
        loadEventRequest?.location = location
        loadEventRequest?.radius = radius

        loadEventRequest?.resumeWithCompletionClosure({ [weak self] (request: LoadEventRequest) -> () in
            if self?.isReqeustValid(request) == false {
                self?.notifyListenersDidLoadItems()
                return
            }

            if request.objects.count > 0 {
                self?.sections.append(request.objects)
            }
            
            self?.notifyListenersDidLoadItems()
        
            if request.pagesCount > self?.page {
                self?.loadNextPage()
            }
        })
    }
    
    private func isReqeustValid(request: LoadEventRequest) -> Bool {
        var result: Bool
        if request.location != nil && request.radius != nil {
            if !request.location!.sameLocation(location!, thresholdMeters: 5.0) && radius != request.radius {
                result = false
            } else if location == nil && radius == nil {
                result = false
            } else {
                result = true
            }
        } else {
            if location != nil && radius != nil {
                result = false
            } else if cities.first != request.cities.first {
                result = false
            } else {
                result = true
            }
        }
        
        return result
    }
}
