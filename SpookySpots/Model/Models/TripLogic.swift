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
import CoreData
import MapKit
import CoreLocation
import AVFoundation

enum AlternateRouteState {
    case inactive, showingAll, selected
}


class TripLogic: ObservableObject {

    static let instance = TripLogic()
    
    @ObservedObject var navigationLogic = NavigationLogic.instance
    
    let mapView = MKMapView()
    
    
    @Published var destinations: [Destination] = [] {
        didSet {
            self.getRoutes()
        }
    }
    
    @Published var tripRoutes: [Route] = [] {
        willSet {
            
       
            self.setCenterOnRoute()
            self.currentTrip?.routes = newValue

            if let first = newValue.first(where:  { $0.tripPosition == 0 }) {
                self.steps = []
                self.steps = first.rt.steps
            }
        }
        
        didSet {
            //                tripRoutes.sort { a, b in
            //                    guard let aPos = a.tripPosition,
            //                          let bPos = b.tripPosition else { return a.altPosition < b.altPosition }
            //                    return aPos < bPos
            //                }
            
  
         
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
            print(newValue)
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
            
            
            self.completedSteps = []
            self.completedSteps.append(first)
            if first.instructions == "" {
                if newValue.indices.contains(1) {
                    let second = newValue[1]
                    self.completedSteps.append(second)
                }
            }
        }
    }
    

    
    @Published var completedSteps: [MKRoute.Step] = []
    @Published var geoFencingCircles: [MKCircle] = []
    @Published var stepDistanceString = ""
    
    @Published var totalTripDurationAsTime = Time()
    @Published var totalTripDistanceAsLocalUnitString = ""
    
    @Published var trips: [Trip] = []
    @Published var currentTrip: Trip? {
        willSet {
            if let newValue = newValue {
                PersistenceController.shared.createOrUpdateTrip(newValue)
            }
        }
    }
    
    private var distance: Double = 0
    @Published var distanceAsString = "0"
    
    private var duration: Double = 0
    @Published var durationHoursString = "0"
    @Published var durationMinutesString = "0"
    
    @Published var navigation = MKRoute()
    
    @Published var mapRegion = MapDetails.defaultRegion
    
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
    
    @Published var shouldShowAlertForClearingTrip = false
    
    @Published var isShowingSheetForStartOrStop = false
    
    @Published var coreDataTrip: CDTrip?
    
//    @Published var moc: NSManagedObjectContext?
    
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance
//    @ObservedObject var coreDataManager = CoreDataManager.instance
    
//    @Environment(\.managedObjectContext) var moc
    
    
//    @FetchRequest(sortDescriptors: []) var cdTripBucket: FetchedResults<CDTrip> {
//        willSet {
//            self.coreDataTrip = newValue.last
//        }
//    }
    
//
        
    init() {
                
        if userStore.isSignedIn || userStore.isGuest {
            
            self.currentTrip = PersistenceController.shared.activeTrip()
            
//  //          loadFromFirebase()
//            if let first = cdTrips.first {
//            self.coreDataTrip = first
//                self.currentTrip = PersistenceController.shared.cdTripToTrip(first)
//            }
// //            self.currentTrip = self.trips.last
//            if let cdTrip = coreDataTrip {
//
//                var destinations: [Destination] = []
//
//                var start = Destination(id: "", lat: 0, lon: 0, name: "")
//                var end = Destination(id: "", lat: 0, lon: 0, name: "")
//
//                var routes: [Route] = []
//
//                if let cdDestinations = cdTrip.destinations?.allObjects as? [Destination] {
//
//                    destinations = cdDestinations
//                }
//
//                if let endPoints = cdTrip.endPoints?.allObjects as? [Destination] {
//                    if let cdStart = endPoints.first(where: { $0.id == "Start" }),
//                        let cdEnd = endPoints.first(where: { $0.id == "End" }) {
//                        start = cdStart
//                        end = cdEnd
//                    }
//                }
//
//                if let cdRoutes = cdTrip.routes?.allObjects as? [Route] {
//                    routes = cdRoutes
//                }
//
//                let trip = Trip(
//                    id: cdTrip.id ?? "",
//                    userID: cdTrip.userID ?? "",
//                    isActive: cdTrip.isActive,
//                    destinations: destinations,
//                    startLocation: start,
//                    endLocation: end,
//                    routes: routes)
//
//
//                self.currentTrip = trip
//            } else {
//
//            }
            
            if let trip = currentTrip {
                                
                self.destinations = trip.destinations
                locationStore.activeTripLocations = destinations
                
                
                mapRegion = MKCoordinateRegion(center:
                                                CLLocationCoordinate2D(
                                                    latitude: trip.startLocation.lat,
                                                    longitude: trip.startLocation.lon),
                                               span: MapDetails.defaultSpan)
                
//                self.coreDataTrip = coreDataManager.fetchCDTrip(trip)

            } else {
                resetTrip()
                mapRegion = MapDetails.defaultRegion
            }
            
        }
    }
    
    func resetTrip() {
        if let currentLoc = userStore.currentLocation {
            
            let startLoc = Destination(id: UUID().uuidString,
                                       lat: currentLoc.coordinate.latitude,
                                       lon: currentLoc.coordinate.longitude,
                                       name: "Current Location")
            
            let endLoc = Destination(id: UUID().uuidString,
                                     lat: currentLoc.coordinate.latitude,
                                     lon: currentLoc.coordinate.longitude,
                                     name: "Current Location")
            
            let trip = Trip(id: UUID().uuidString,
                            userID: userStore.user.id,
                            isActive: true,
                            destinations: [],
                            startLocation: startLoc,
                            endLocation: endLoc,
                            routes: [])
            self.currentTrip = trip
        }
    }
    
    //MARK: - Alternates
    
    func showAlternateRoutes() {
        if let a = self.currentRoute?.polyline.startLocation,
           let b = self.currentRoute?.polyline.endLocation  {
            self.makeDirectionsRequest(start: a, end: b) { routes in
                self.alternates = routes
                //                    self.alternates.append(routes)
                //                    self.allRoutes.append(routes)
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
        
        var trip = self.currentTrip
    }
    
    //MARK: - Core Data
//    
//    func setUp(_ moc: NSManagedObjectContext) {
//        self.moc = moc
//    }
    
//
//    func saveTripToCoreData() {
//
//        if let currentTrip = currentTrip {
//
//            let cdRoutes = NSSet(array: currentTrip.routes)
//            let cdEndPoints = NSSet(array: [currentTrip.startLocation, currentTrip.endLocation])
//            let cdDestinations = NSSet(array: currentTrip.destinations)
//
//
//        let cdTrip = CDTrip(context: moc)
//            cdTrip.id = currentTrip.id
//            cdTrip.endPoints = cdEndPoints
//            cdTrip.routes = cdRoutes
//            cdTrip.destinations = cdDestinations
//            cdTrip.isActive = currentTrip.isActive
//
//        do {
//            try moc.save()
//        } catch {
//            print(error.localizedDescription)
//        }
//        }
//    }

    
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
    
    
    func removeDestination(atIndex index: Int) {
        objectWillChange.send()
        self.currentTrip?.destinations.remove(at: index)
        self.locationStore.activeTripLocations.remove(at: index)
        self.destinations.remove(at: index)
        if tripRoutes.indices.contains(index) {
            self.tripRoutes.remove(at: index)
        }
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
    
    
    //MARK: - Map
    
    func setCenterOnRoute() {
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
    
    //MARK: -  Routes
    
    private func getRoutes() {
        self.tripRoutes = []
        self.routesForDestinations { success in
            if success {
                print("here")
//                self.getReturnHome { route in
//                    var newRoute = route
//                        newRoute.tripPosition = self.tripRoutes.count
//                    self.tripRoutes.append(newRoute)
//                }
            }
        }
    }
    
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
//            let tripPosition = 0
            
            for rt in response.routes.prefix(3) {
                let polyline = RoutePolyline(points: rt.polyline.points(), count: rt.polyline.pointCount)
                polyline.startLocation = start
                polyline.endLocation = end
                polyline.parentCollectionID = end.id
                ///
                var route = Route(id: UUID().uuidString, rt: rt, collectionID: end.id, polyline: polyline, altPosition: count, tripPosition: nil)
                polyline.route = route
                route.polyline = polyline
                
                routesToReturn.append(route)
                count += 1
                //                            completion(route)
            }
            
            completion(routesToReturn)
        }
    }
    
    
    private func getRoutesForTrip(withCompletion completion: @escaping(Route) -> (Void)) {
        
        self.tripRoutes = []
        
        if let currentTrip = currentTrip {
            
            var first: Destination = currentTrip.startLocation
            var usedDestinations: [Destination] = []
            
            var routesReturnable: [Route] = []
            
            for destination in destinations {
                
                makeDirectionsRequest(start: first, end: destination) { routes in
                    if let first = routes.first {
                        
                        routesReturnable.append(first) ///
                                                ///
                        
                        var route = first
                        route.tripPosition = self.tripRoutes.count
                        
                                    completion(route)
                    }
                }
                first = destination
                usedDestinations.append(destination)
                
                
            }
//            completion(routesReturnable)
            
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
    
    
    func routesForDestinations(withCompletion completion: @escaping(Bool) -> (Void)) {
        getRoutesForTrip { routes in
//            var newRoute = routes
//            newRoute.tripPosition = self.tripRoutes.count
            self.tripRoutes.append(routes)
            self.allRoutes.append(routes)
        }
        completion(true)
    }
    
    
    func tripRoutesContains(_ route: Route) -> Bool {
        tripRoutes.contains(where: { $0.id == route.id })
    }
    
    //MARK: - Navigation
    
    func startTrip() {
        
        if let currentLoc = userStore.currentLocation {
            self.mapRegion = MKCoordinateRegion(center: currentLoc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
        
//        let sortedTripRoutes = self.tripRoutes.sorted(by: { $0.tripPosition ?? 0 < $1.tripPosition ?? 1 })
        if let first = self.tripRoutes.first(where: { $0.tripPosition == 0 }) {
        self.currentRoute = first
        //        self.highlightedPolyline = self.tripRoutes.first?.polyline
        self.routeIsHighlighted = true
        
        }
        
    }
    
    func pauseDirections() {
        
    }
    
    func resumeDirections() {
        
    }
    
    func endDirections() {
        self.currentRoute = nil
        self.routeIsHighlighted = false
        self.shouldShowAlertForClearingTrip = true
    }
    
}
