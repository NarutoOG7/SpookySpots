//
//  CoreDataManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 7/28/22.
//

import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    
    let currentTripContainer = NSPersistentContainer(name: "Current Trip")
    
    init() {
        currentTripContainer.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
}
