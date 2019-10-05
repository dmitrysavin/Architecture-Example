//
//  UpdateEventCategoriesFlow.swift
//  Evenz
//
//  Created by Dmitry Savin on 12/23/15.
//  Copyright © 2015 Engineering Idea. All rights reserved.
//

import Foundation

/// Works as facade, which incapsulate all logic of interaction with Event Categories screen.
class UpdateEventCategoriesFlow {
    
    /// Selected event categories.
    var items: [EventCategory] = []
    
    /// Indicates whether save preference option enabled.
    var savePreferenceEnabled: Bool {
        return self.filtersConfiguration!.savePreferenceEnabled
    }
    
    /// Object which works as datasource of selected event categories.
    private var filtersConfiguration: FiltersConfiguration?

    
    //MARK: - Interface -
    
    init() {
        fatalError("init() is not valid initializer.")
    }
    
    /// Initialize `UpdateEventCategoriesFlow` with *FiltersConfiguration* class, 
    /// which works as datasource of selected event categories.
    /// - parameter filtersConfiguration: Object of *FiltersConfiguration* class.
    init(withFiltersConfiguration filtersConfiguration: FiltersConfiguration) {
        self.filtersConfiguration = filtersConfiguration
        self.items = (self.filtersConfiguration?.eventCategories)!
    }

    /// Saves selected `eventCategories` to local storage if `savePreferenceEnabled` property returns true.
    func save() {
        self.filtersConfiguration?.saveEventCategories(self.items)
    }
    
    /// Enable or disable save preference functionality.
    func enableSavePreference(enable: Bool) {
        self.filtersConfiguration?.enableSavePreference(enable)
    }
    
    /// Updates `items` from filter configuration to make it up to date.
    func reloadItems() {
        self.items = (self.filtersConfiguration?.eventCategories)!
    }
}
