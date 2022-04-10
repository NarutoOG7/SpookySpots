//
//  CLGeocoderTests.swift
//  SpookySpotsTests
//
//  Created by Spencer Belton on 4/5/22.
//

import XCTest
@testable import SpookySpots
import CoreLocation

class CLGeocoderTests: XCTestCase {
    
    var sut: FirebaseManager!

    override func setUpWithError() throws {
        super.setUp()
        sut = FirebaseManager()
    }

    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }


    func testForwardGeocod_shouldReturnValue() {
        sut.getCoordinatesFrom(address: "1 Grand Union Sq, Fort Benton, MT 59442") { coordinates in
            print(coordinates)
        }
    }

}
