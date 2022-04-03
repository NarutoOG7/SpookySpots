//
//  LocationDataModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation

struct LocationDataModel {
    
    let name: String
    let address: Address
    let description: String
    let moreInfoLink: String
    let review: Review
    
    
    //MARK: - Images
    struct Images {
        var id: Int
        var imageURL: String
        var locationID: Int
    }
}
