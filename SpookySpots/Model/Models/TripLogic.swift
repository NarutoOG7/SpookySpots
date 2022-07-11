//
//  TripLogic.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/7/22.
//



//
//for i in 0..<first.rt.steps.count {
//    let step = first.rt.steps[i]
//    let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
//    let circle = MKCircle(center: region.center, radius: region.radius)
//
//    self.geoFencingCircles.append(circle)
//
//    let locale = Locale.current
//    let usesMetric = locale.usesMetricSystem
//    let units = usesMetric ? "meters" : "miles"
//
//    let firstDST = self.steps[0].distance
//    let distanceONE = String(format: "%.2f", usesMetric ? firstDST : firstDST * 0.000621371)
//
//    let firstEmpty = self.steps[0].instructions == ""
//
//    let secondDST = self.steps[1].distance
//    let distanceTWO = String(format: "%.2f", usesMetric ? secondDST : secondDST * 0.000621371)
//
//    let skippedEmptyFirstMessage = "In \(distanceTWO) \(units), \(self.steps[1].instructions)."
//    let fullMessage = "In \(distanceONE) \(units), \(self.steps[0].instructions). Then, in \(distanceTWO) \(units), \(self.steps[1].instructions)."
//
//    let initialMessage = firstEmpty ? skippedEmptyFirstMessage : fullMessage
//
//    self.directionsLabel = initialMessage
//    self.stepsCounter += 1
//
//    locManager.startMonitoring(for: region)
//
//}


import SwiftUI
import MapKit
import CoreLocation
import AVFoundation

enum AlternateRouteState {
    case inactive, showingAll, selected
}

struct Route: Identifiable, Equatable {
    let id: String
    let rt: MKRoute
    let collectionID: String
    var polyline: RoutePolyline
    let altPosition: Int
    var tripPosition: Int?
}

class TripLogic: ObservableObject {
    static let instance = TripLogic()

    @ObservedObject var navigationLogic = NavigationLogic.instance
    
    @Published var destinations: [Destination] = [] {
        didSet {
            self.tripRoutes = []
            self.getRoutes { success in
                if success {
                    self.getReturnHome { route in
                        self.tripRoutes.append(route)
                    }
                    self.steps = self.tripRoutes.first?.rt.steps ?? []
                    if let firstStep = self.steps.first {
                        
                        if firstStep.instructions == "" {
                            if self.steps.indices.contains(1) {
                                let secondStep = self.steps[1]
                                self.directionsLabel = secondStep.instructions
                                self.completedSteps.append(firstStep)
                                self.completedSteps.append(secondStep)
//                                self.stepDistanceString =
                            }
                        } else {
                            self.directionsLabel = firstStep.instructions
                            self.completedSteps.append(firstStep)
                        }
                        
                    }
//                    self.directionsLabel = ((firstStep == "") ? secondStep : firstStep) ?? ""
                }
            }
        }
    }
    
    @Published var tripRoutes: [Route] = [] {
        willSet {
            if let last = newValue.last {

                var arrayOfCoordinates: [CLLocationCoordinate2D] = []
                for dest in self.destinations {
                    arrayOfCoordinates.append(CLLocationCoordinate2D(latitude: dest.lat, longitude: dest.lon))
                }
                var center = CLLocationCoordinate2D()
                if arrayOfCoordinates.isEmpty {
                    center = MapDetails.startingLocation.coordinate
                } else {
                    center = arrayOfCoordinates.center()
                }
                self.mapRegion = MKCoordinateRegion(center: center, span: MapDetails.defaultSpan)
            }
            print(newValue.count)
        }
        
            didSet {
        setTotalDistance()
        setTotalTripDuration()
            }
        
    }
    
    
    @Published var isNavigating = false
    @Published var currentRoute: Route? {
        willSet {
            setHighlightedRouteDistanceAsLocalString()
//            setHighlightedRouteTravelTimeAsTime()
        }
    }
    @Published var currentRouteTravelTime: Time?
    @Published var currentRouteDistanceString: String?
    @Published var steps: [MKRoute.Step] = [] {
        willSet {
            guard let first = newValue.first else { return }
            guard let locManager = self.userLocManager.locationManager else { return }
            locManager.monitoredRegions.forEach({ locManager.stopMonitoring(for: $0) })
            
            let region = CLCircularRegion(center: first.polyline.coordinate, radius: 20, identifier: "\(newValue.firstIndex(where: { $0 == first }) )")
                let circle = MKCircle(center: region.center, radius: region.radius)
                
                self.geoFencingCircles.append(circle)
                
//                let locale = Locale.current
//                let usesMetric = locale.usesMetricSystem
//                let units = usesMetric ? "meters" : "miles"
//
//                let firstDST = self.steps[0].distance
//                let distanceONE = String(format: "%.2f", usesMetric ? firstDST : firstDST * 0.000621371)
//
//                let firstEmpty = self.steps[0].instructions == ""
//
//                let secondDST = self.steps[1].distance
//                let distanceTWO = String(format: "%.2f", usesMetric ? secondDST : secondDST * 0.000621371)
//
//                let skippedEmptyFirstMessage = "In \(distanceTWO) \(units), \(self.steps[1].instructions)."
//                let fullMessage = "In \(distanceONE) \(units), \(self.steps[0].instructions). Then, in \(distanceTWO) \(units), \(self.steps[1].instructions)."
//
//                let initialMessage = firstEmpty ? skippedEmptyFirstMessage : fullMessage
//
//                self.directionsLabel = initialMessage
//                self.stepsCounter += 1
//
                locManager.startMonitoring(for: region)
            
        }
    }
    @Published var completedSteps: [MKRoute.Step] = []
    @Published var geoFencingCircles: [MKCircle] = []
    @Published var directionsLabel = ""
    @Published var stepDistanceString = ""
    
    @Published var totalTripDurationAsTime = Time()
    @Published var totalTripDistanceAsLocalUnitString = "" 
        
    @Published var trips: [Trip] = []
    @Published var currentTrip: Trip?
    
    private var distance: Double = 0
    @Published var distanceAsString = "0"
    
    private var duration: Double = 0
    @Published var durationHoursString = "0"
    @Published var durationMinutesString = "0"
    
    @Published var navigation = MKRoute()
    
    @Published var mapRegion = MapDetails.defaultRegion 
    @Published var destAnnotations: [LocationAnnotationModel] = []
    
    @Published var routeIsHighlighted = false
//    @Published var highlightedPolyline: RoutePolyline?
    
    @Published var alternates: [Route] = []
    @Published var selectedAlternate: Route? {
        didSet {
            self.alternateRouteState = .selected
        }
    }
    
    @Published var altsHaveFirst: Bool = false
    @Published var altsHaveSecond: Bool = false
    @Published var altsHaveThird: Bool = false
    @Published var alternateRouteState: AlternateRouteState = .inactive
    
    @Published var allRoutes: [Route] = []
    
    
    @Published var isShowingSheetForStartOrStop = false
    
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance

    init() {
        
        if userStore.isSignedIn || userStore.isGuest {
            
            loadFromFirebase()
            
            self.currentTrip = self.trips.last
            
            if let trip = currentTrip {
                
                self.destinations = trip.destinations
                locationStore.activeTripLocations = destinations
                
                
                mapRegion = MKCoordinateRegion(center:
                                                CLLocationCoordinate2D(
                                                    latitude: trip.startLocation.lat,
                                                    longitude: trip.startLocation.lon),
                                               span: MapDetails.defaultSpan)
                
            } else {
                                
                if let currentLoc = userStore.currentLocation {
                    
                    let startLoc = Destination(id: UUID().uuidString,
                                               lat: currentLoc.coordinate.latitude,
                                               lon: currentLoc.coordinate.longitude,
                                               name: "Current Location")
                    
                    let endLoc = Destination(id: UUID().uuidString,
                                             lat: currentLoc.coordinate.latitude,
                                             lon: currentLoc.coordinate.longitude,
                                             name: "Current Location")
                    
                currentTrip = Trip(id: UUID().uuidString,
                                   userID: userStore.user.id,
                                   isActive: true,
                                   destinations: [],
                                   startLocation: startLoc,
                                   endLocation: endLoc)
                    mapRegion = MapDetails.defaultRegion
            }
            }
            
        }
    }
    
    //MARK: - Alternates
    
    func showAlternateRoutes() {
        if let a = self.currentRoute?.polyline.startLocation,
           let b = self.currentRoute?.polyline.endLocation {
                self.makeDirectionsRequest(start: a, end: b) { routes in
                    self.alternates = routes
                    for route in routes {
                        self.allRoutes.append(route)
                    }
                }
                    
            }
        
    }
    
    func alternateSelectedForNextPhase() {
        if let rtIndice = tripRoutes.firstIndex(where: { $0.collectionID == selectedAlternate?.collectionID }),
           let alt = selectedAlternate {
            tripRoutes[rtIndice] = alt
        }
    }
    
    func alternatesLogic() {
        
        switch alternateRouteState {
        case .inactive:
            alternateRouteState = .showingAll
            showAlternateRoutes()
        case .showingAll:
            alternates = []
            alternateRouteState = .inactive
        case .selected:
            alternateSelectedForNextPhase()
            alternates = []
            alternateRouteState = .inactive
        }
    }
    
    func alternatesAreOnBoard() -> Bool {
        self.alternateRouteState == .showingAll || self.alternateRouteState == .selected
    }
    
    func positionIsSelected(_ position: Int) -> Bool {
        selectedAlternate?.altPosition == position
    }
    
    func selectAlternate(_ position: Int) {
        self.selectedAlternate = alternates.first(where: { $0.altPosition == position })
        self.currentRoute = self.selectedAlternate
    }
    
    //MARK: - Firebase
    
    func loadFromFirebase() {
        firebaseManager.getTripLocationsForUser { trip in
            self.trips.append(trip)
        }
    }
    
    func saveToFirebase() {
        if let currentTrip = currentTrip {
            firebaseManager.addOrSaveTrip(currentTrip)
        }
    }

    //MARK: - Destinations
    
    func destinationsContains(_ location: LocationModel) -> Bool {
        self.destinations.contains(where:  { $0.name == location.location.name})
    }

    func addDestination(_ location: LocationModel) {
        objectWillChange.send()

        firebaseManager.getCoordinatesFromAddress(address: location.location.address?.geoCodeAddress() ?? "") { cloc in

            let destination = Destination(
                id: "\(location.location.id)",
                lat: cloc.coordinate.latitude,
                lon: cloc.coordinate.longitude,
                name: location.location.name)
            if let currentTrip = self.currentTrip {
                
                self.currentTrip?.destinations.append(destination)
            }
            self.destinations.append(destination)
            self.locationStore.activeTripLocations.append(destination)
        }
    }

    func removeDestination(_ location: LocationModel) {
        objectWillChange.send()
        self.currentTrip?.destinations.removeAll(where: { $0.name == location.location.name })
        self.locationStore.activeTripLocations.removeAll(where: { $0.name == location.location.name })
        self.destinations.removeAll(where: { $0.name == location.location.name })
        self.tripRoutes.removeAll(where: { $0.id == "\(location.location.id)" })
    }
    
    //MARK: - Distance
    
    func getDistanceAsString() -> String {
        self.distance = 0
        for route in self.tripRoutes {
            let dst = route.rt.distance / 1609.344
            self.distance += dst
            return String(format: "%.0f", self.distance)
        }
        return ""
    }
    
    func getSingleRouteDistanceAsString() -> String {
        if var distance = self.currentRoute?.rt.distance {
            distance /=  1609.344
            return String(format: "%.0f", distance)
        }
        return ""
    }
    
    func setTotalDistance() {
        let locale = Locale.current
        let usesMetric = locale.usesMetricSystem
        
        self.distance = 0
        
        for route in tripRoutes {
            let meters = route.rt.distance
            let miles = meters * 0.000621371
            let distance = usesMetric ? meters : miles
            self.distance += distance
        }
        self.totalTripDistanceAsLocalUnitString = String(format: "%.0f", distance)
    }
    
    func setHighlightedRouteDistanceAsLocalString() {
        let locale = Locale.current
        let usesMetric = locale.usesMetricSystem
        
        if let meters = self.currentRoute?.rt.distance {
            let miles = meters * 0.000621371
            let distance = usesMetric ? meters : miles
            self.currentRouteDistanceString = String(format: "%.0f", distance)
        }
    }
    
//    func setTotalTripDistance() {
//        self.distance = 0
//        self.distanceAsString = ""
//        for route in self.tripRoutes {
//            let dst = route.rt.distance / 1609.344
//            self.distance += dst
//            self.distanceAsString = String(format: "%.0f", self.distance)
//        }
//    }
//
    
    //MARK: - Duration
    
    func getHighlightedRouteTravelTimeAsDigitalString() -> String? {
        if let travelTime = currentRoute?.rt.expectedTravelTime {
                return formatTime(time: travelTime)
        }
        return nil
    }
    
    func getHighlightedRouteTravelTimeAsTime() -> Time? {
        if let travelTime = currentRoute?.rt.expectedTravelTime {
            let time = secondsToHoursMinutes(travelTime)
//            self.currentRouteTravelTime = time
            return time
        }
        return nil
    }
    
    func setTotalTripDuration() {
        self.duration = 0
        for route in self.tripRoutes {
            self.duration += route.rt.expectedTravelTime
            let time = secondsToHoursMinutes(duration)
            self.totalTripDurationAsTime = time
        }
    }
    
    func secondsToHoursMinutes(_ seconds: Double) -> Time {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return Time(hours: hours, minutes: minutes) 
    }
    
    func formatTime(time: Double) -> String? {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.hour, .minute]
        return dateFormatter.string(from: time)
    }
    
    //MARK: -  Routes
    
    private func makeDirectionsRequest(start: Destination, end: Destination, withCompletion completion: @escaping([Route]) -> (Void)) {
        let request = MKDirections.Request()
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
                    let mapItemA = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: start.lat, longitude: start.lon))
                    let mapItemB = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: end.lat, longitude: end.lon))
        
                    request.source = MKMapItem(placemark: mapItemA)
                    request.destination = MKMapItem(placemark: mapItemB)
        
                    let directions = MKDirections(request: request)
                    directions.calculate { response, error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        guard let response = response else { return }
                        
                        var routesToReturn: [Route] = []
                        
                        var count = 0
            
                        for rt in response.routes.prefix(3) {
                            let polyline = RoutePolyline(points: rt.polyline.points(), count: rt.polyline.pointCount)
                            polyline.startLocation = start
                            polyline.endLocation = end
                            polyline.parentCollectionID = end.id
                            
                            var route = Route(id: UUID().uuidString, rt: rt, collectionID: end.id, polyline: polyline, altPosition: count)
                            route.polyline = polyline
                            polyline.route = route
        
                            routesToReturn.append(route)
                            count += 1
                        }
                        
                        completion(routesToReturn)
                    }
    }
    
    
    private func getRoutesForTrip(withCompletion completion: @escaping(Route) -> (Void)) {
        
        self.tripRoutes = []
        
        if let currentTrip = currentTrip {
            
            var first: Destination = currentTrip.startLocation
            var usedDestinations: [Destination] = []
            
            for destination in destinations {
                
                makeDirectionsRequest(start: first, end: destination) { routes in
                    if let first = routes.first {
                                               
                        completion(first)
            
                    }
                }
                first = destination
                usedDestinations.append(destination)
                

                }

                
            }
        
    }
    
    func getReturnHome(withCompletion completion: @escaping(Route) -> (Void)) {
        if let start = self.destinations.last,
           let end = currentTrip?.endLocation {
            
            makeDirectionsRequest(start: start, end: end) { routes in
                if let first = routes.first {
        
                    completion(first)
                    
                }
            }
        }
    }
            

    func getRoutes(withCompletion completion: @escaping(Bool) -> (Void)) {
        getRoutesForTrip { route in
            var newRoute = route
            newRoute.tripPosition = self.tripRoutes.count
            self.tripRoutes.append(newRoute)
            self.allRoutes.append(newRoute)
            completion(true)
        }
    }
            
    
    func tripRoutesContains(_ route: Route) -> Bool {
        tripRoutes.contains(where: { $0.id == route.id })
    }
    
    //MARK: - Navigation
    
    func startTrip() {
                        
        if let currentLoc = userStore.currentLocation {
            self.mapRegion = MKCoordinateRegion(center: currentLoc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }

        self.currentRoute = self.tripRoutes.first(where: { $0.tripPosition == 0 })
//        self.highlightedPolyline = self.tripRoutes.first?.polyline
        self.routeIsHighlighted = true
        
    }
    
    func pauseDirections() {
        
    }
    
    func resumeDirections() {
        
    }
    
    func endDirections() {
        self.currentRoute = nil
        self.routeIsHighlighted = false
    }
    
}
