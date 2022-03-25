//
//  LocalSearchService.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Foundation
import Combine
import MapKit
import Contacts

class LocalSearchService: ObservableObject {
    static let instance = LocalSearchService()
    
    @Published var locationsList: [SearchResult] = []
    
//    let localSearchPublisher = Pas
    
    func performSearch(from text: String, withCompletion completion: @escaping ((_ result: SearchResult) -> (Void))) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.pointOfInterestFilter = .includingAll
        searchRequest.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let response = response else { return }
            
            for item in response.mapItems {
                
                let result = SearchResult(id: UUID(), mapItem: item)
                completion(result)
                
            }
        }
    }
}

struct SearchResult: Identifiable {
    var id: UUID
    var mapItem: MKMapItem
    
    func itemDisplayName() -> String {
        if let name = mapItem.name,
        let city = mapItem.placemark.postalAddress?.city,
        let state = mapItem.placemark.postalAddress?.state {
        return "\(name) ・ \(city), \(state)"
        }
        return ""
    }
}

 
