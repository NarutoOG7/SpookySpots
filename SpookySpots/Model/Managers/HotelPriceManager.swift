//
//  HotelPriceManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation
import SwiftUI

class HotelPriceManager {
    static let instance = HotelPriceManager()
    
    let hotelPriceURL = "https://data.xotelo.com/api/rates?hotel_key=g297930-d305178&chk_in=2022-12-25&chk_out=2022-12-26"
    
    func getPriceOfHotel(key: String, withCompletion completion: @escaping ((_ hotelPriceModel: HotelPriceModel?) -> (Void))) {
        let urlString = "\(hotelPriceURL)?hotel_key=\(key)"
        let url = URL(string: urlString)!
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching hotel prices for hotelKey: \(key), error: \(error)")
                //handle error
            }
            
            guard let data = data else { return }
            do {
                let hotelPrice = try JSONDecoder().decode(HotelPriceData.self, from: data)
                var prices = [Double]()
                for price in hotelPrice.result.rates {
                    prices.append(price.rate)
                }
                let hotelPriceModel = HotelPriceModel(prices: prices)
                completion(hotelPriceModel)
            } catch {
                // Handle Error
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}
