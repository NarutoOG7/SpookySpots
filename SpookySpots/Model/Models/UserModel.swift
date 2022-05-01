//
//  UserModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/30/22.
//

import Foundation

struct UserModel {
    
    var user: User
    var favoriteLocations: [LocationModel]
    var reviews: [ReviewModel]
    
    static let emptyUser = UserModel(user: User(), favoriteLocations: [], reviews: [])
    
    func locationIsFavorited(_ loc: LocationModel) -> Bool {
        self.favoriteLocations.contains(where: { $0.id == loc.id })
    }
    
    mutating func addOrRemoveFromFavorites(_ loc: LocationModel, withCompletion completion: @escaping(_ isFavorited: Bool) -> Void) {
        if locationIsFavorited(loc) {
            removeFromFavorites(loc)
        } else {
            favoriteLocations.append(loc)
            // Firebase add
            FirebaseManager.instance.addLocToFavoritesBucket(loc) { result in
                if result == true {
                    completion(result)
                }
            }
        }
    }
    
    private mutating func removeFromFavorites(_ loc: LocationModel) {
        favoriteLocations.removeAll(where: { $0.id == loc.id } )
        // Firebase remove
    }
}
