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


extension DispatchQueue {

    static func background(_ task: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            task()
        }
    }

    static func main(_ task: @escaping () -> ()) {
        DispatchQueue.main.async {
            task()
        }
    }
}

class TripLogic: ObservableObject {

    static let instance = TripLogic()
    
    @ObservedObject var navigationLogic = NavigationLogic.instance
    
    @Published var destinations: [Destination] = [] {
        didSet {
            self.getRoutes()
        }
    }

    @Published var currentRoute: Route? {
        willSet {
            setHighlightedRouteDistanceAsLocalString()
            //            setHighlightedRouteTravelTimeAsTime()
        }
    }
    @Published var currentRouteTravelTime: Time?
    @Published var currentRouteDistanceString: String?
    @Published var steps: [Route.Step] = [] {
        willSet {
            
            guard let first = newValue.first else { return }
            guard let locManager = self.userLocManager.locationManager else { return }
            locManager.monitoredRegions.forEach({ locManager.stopMonitoring(for: $0) })
            
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: first.latitude ?? 0, longitude: first.longitude ?? 0), radius: 20, identifier: "\(newValue.firstIndex(where: { $0 == first }) )")
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
    

    
    @Published var completedSteps: [Route.Step] = []
    @Published var geoFencingCircles: [MKCircle] = []
    @Published var stepDistanceString = ""
    
    var totalTripDurationAsTime: Time {
        get {
            var totalTime = Time()
            var duration: Double = 0
            for route in self.currentTrip?.routes ?? [] {
                duration += route.travelTime
                let time = secondsToHoursMinutes(duration)
                totalTime = time
            }
            return totalTime
        }
    }
    
    var totalTripDistanceAsLocalUnitString: String {
        get {
            let locale = Locale.current
            let usesMetric = locale.usesMetricSystem
            
            var distance: Double = 0
            let unitSystem = usesMetric ? "meters" : "miles"
      
            for route in self.currentTrip?.routes ?? [] {
                let meters = route.distance
                let miles = meters * 0.000621371
                let dist = usesMetric ? meters : miles
                distance += dist
            }
            let str = String(format: "%.0f \(unitSystem)", distance)
            return str
        }
    }
    
    @Published var trips: [Trip] = []
    @Published var currentTrip: Trip? {
        willSet {
            if let newValue = newValue {
                if let first = newValue.routes.first(where:  { $0.tripPosition == 0 }) {
                    self.steps = []
                    self.steps.append(first.steps.first ?? Route.Step())
                }
                self.setCenterOnRoute()
                
                DispatchQueue.main.async {
                    
                    let persist = PersistenceController.shared
                    let context = persist.container.viewContext
                    persist.createOrUpdateTrip(newValue, context: context)
                }
            }
        }
    }
    
    private var distance: Double = 0
    @Published var distanceAsString = "0"
    
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
            
            if let trip = currentTrip {
       
                mapRegion = MKCoordinateRegion(center:
                                                CLLocationCoordinate2D(
                                                    latitude: trip.startLocation.lat,
                                                    longitude: trip.startLocation.lon),
                                               span: MapDetails.defaultSpan)
                
            } else {
                resetTrip()
                mapRegion = MapDetails.defaultRegion
            }
            
        }
    }
    
    func resetTrip() {
        
        if let currentLoc = userStore.currentLocation {
            
            firebaseManager.getAddressFrom(coordinates: currentLoc.coordinate) { address in
                
                let startLoc = Destination(id: UUID().uuidString,
                                       lat: currentLoc.coordinate.latitude,
                                       lon: currentLoc.coordinate.longitude,
                                       address: address.streetCityState(),
                                       name: "Current Location")
                
               let endLoc = Destination(id: UUID().uuidString,
                                     lat: currentLoc.coordinate.latitude,
                                     lon: currentLoc.coordinate.longitude,
                                     address: address.streetCityState(),
                                     name: "Current Location")
                var trip = Trip(id: UUID().uuidString,
                                userID: self.userStore.user.id,
                                isActive: true,
                                destinations: [],
                                startLocation: startLoc,
                                endLocation: endLoc,
                                routes: [],
                                remainingSteps: [],
                                completedStepCount: 0,
                                totalStepCount: 0,
                                tripState: .building)
                trip.recentlyCompletedDestination = startLoc
                trip.nextDestination = endLoc
                
                self.currentTrip = trip
            }
        }
    }
    
    //MARK: - Alternates
    
    func showAlternateRoutes() {
        if let a = self.currentRoute?.polyline?.startLocation,
           let b = self.currentRoute?.polyline?.endLocation  {
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
        if let rtIndice = self.currentTrip?.routes.firstIndex(where: { $0.collectionID == selectedAlternate?.collectionID }),
           let alt = selectedAlternate {
            self.currentTrip?.routes[rtIndice] = alt
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
        (self.currentTrip?.destinations ?? []).contains(where:  { $0.name == location.location.name})
    }
    
    func addDestination(_ location: LocationModel) {
        objectWillChange.send()
        
        firebaseManager.getCoordinatesFromAddress(address: location.location.address?.geoCodeAddress() ?? "") { cloc in
            
            let destination = Destination(
                id: "\(location.location.id)",
                lat: cloc.coordinate.latitude,
                lon: cloc.coordinate.longitude,
                address: location.location.address?.streetCityState() ?? Address().streetCityState(),
                name: location.location.name)
            if let currentTrip = self.currentTrip {
                
                self.currentTrip?.destinations.append(destination)
            }
            self.destinations.append(destination)
//            self.locationStore.activeTripLocations.append(destination)
        }
    }
    
    func removeDestination(_ location: LocationModel) {
        objectWillChange.send()
        self.currentTrip?.destinations.removeAll(where: { $0.name == location.location.name })
//        self.locationStore.activeTripLocations.removeAll(where: { $0.name == location.location.name })
        self.destinations.removeAll(where: { $0.name == location.location.name })
        self.currentTrip?.routes.removeAll(where: { $0.id == "\(location.location.id)" })
    }
    
    
    func removeDestination(atIndex index: Int) {
        objectWillChange.send()
        self.currentTrip?.destinations.remove(at: index)
//        self.locationStore.activeTripLocations.remove(at: index)
        self.destinations.remove(at: index)
        if currentTrip?.routes.indices.contains(index) ?? false {
            self.currentTrip?.routes.remove(at: index)
        }
    }
    
    //MARK: - Distance
    
    func getDistanceStringFromRoute(_ route: Route, shortened: Bool) -> String {
        let locale = Locale.current
        let usesMetric = locale.usesMetricSystem
        
        var distance: Double = 0
        let unitSystem = usesMetric ? "meters" : "miles"
        let shortenedUnitSystem  = usesMetric ? "m" : "mi"

            let meters = route.distance
            let miles = meters * 0.000621371
            let dist = usesMetric ? meters : miles
            distance += dist
        
        let unitString = shortened ? shortenedUnitSystem : unitSystem
        let str = String(format: "%.0f \(unitString)", distance)

        return str
    }
    
    func setHighlightedRouteDistanceAsLocalString() {
        let locale = Locale.current
        let usesMetric = locale.usesMetricSystem
        
        if let meters = self.currentRoute?.distance {
            let miles = meters * 0.000621371
            let distance = usesMetric ? meters : miles
            self.currentRouteDistanceString = String(format: "%.0f", distance)
        }
    }
    
    
    //MARK: - Duration
    
    func getHighlightedRouteTravelTimeAsDigitalString() -> String? {
        if let travelTime = currentRoute?.travelTime {
            return formatTime(time: travelTime)
        }
        return nil
    }
    
    func getHighlightedRouteTravelTimeAsTime() -> Time? {
        if let travelTime = currentRoute?.travelTime {
            let time = secondsToHoursMinutes(travelTime)
            //            self.currentRouteTravelTime = time
            return time
        }
        return nil
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
        if let destinations = self.currentTrip?.destinations {
        for dest in destinations {
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
    }
    
    //MARK: -  Routes
    
    private func getRoutes() {
        self.currentTrip?.routes = []
        self.routesForDestinations { success in
            if success {
                self.getReturnHome { route in
                    var newRoute = route
                    newRoute.tripPosition = self.currentTrip?.routes.count
                    self.currentTrip?.routes.append(newRoute)
                }
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
            if let response = response {
            
            
            var routesToReturn: [Route] = []
            
            var count = 0
//            let tripPosition = 0
            
            for rt in response.routes.prefix(3) {
                
                                
//                var myPointsArray = [Route.Point]()
                
                let routeID = UUID().uuidString

                let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: rt.polyline.pointCount)
                rt.polyline.getCoordinates(coordsPointer, range: NSMakeRange(0, rt.polyline.pointCount))
                
//                var coords: [CLLocationCoordinate2D] = []

//                pointsFromUnsafePointer(rt: rt) { points in
//                    myPointsArray = points
//                    for point in points.sorted(by: { $0.index ?? 0 < $1.index ?? 1 }) {
//                        let coord = CLLocationCoordinate2D(latitude: point.latitude ?? 0, longitude: point.longitude ?? 0)
//                        coords.append(coord)
//                    }
//                }

                let polyline = RoutePolyline(points: rt.polyline.points(), count: rt.polyline.pointCount)
                polyline.startLocation = start
                polyline.endLocation = end
                polyline.parentCollectionID = end.id
//                polyline.pts = myPointsArray
                polyline.routeID = routeID
                
                DispatchQueue.background {
                polyline.setPointCoordinates(rt)
                }
                
                var steps = [Route.Step]()
                var index: Int16 = 0
                for step in rt.steps {
                    let stp = Route.Step(id: index,
                                         distanceInMeters: step.distance,
                                         instructions: step.instructions,
                                         latitude: step.polyline.coordinate.latitude,
                                         longitude: step.polyline.coordinate.longitude)
                    steps.append(stp)
                    index += 1
                }
                
                let route = Route(id: routeID,
                                  steps: steps,
                                  travelTime: rt.expectedTravelTime,
                                  distance: rt.distance,
                                  collectionID: end.id,
                                  polyline: polyline,
                                  altPosition: count,
                                  tripPosition: nil)
                

                
                routesToReturn.append(route)
                count += 1
            }
                completion(routesToReturn)
            
            }
        }
//        func pointsFromUnsafePointer(rt: MKRoute, completion: @escaping([Route.Point]) -> (Void)) {
//            var index = 0
//            var points = [Route.Point]()
//            for pt in UnsafeBufferPointer(start: rt.polyline.points(),
//                                          count: rt.polyline.pointCount) {
//
//                let point = Route.Point(index: index,
//                                        latitude: pt.coordinate.latitude,
//                                        longitude: pt.coordinate.longitude)
//                index += 1
//                points.append(point)
//            }
//            completion(points)
//        }
    }
    
    
    private func getRoutesForTrip(withCompletion completion: @escaping(Route) -> (Void)) {
    
        if let currentTrip = currentTrip {
            
            var first: Destination = currentTrip.startLocation
            var usedDestinations: [Destination] = []
            
            var routesReturnable: [Route] = []
            
            for destination in currentTrip.destinations {
                
                makeDirectionsRequest(start: first, end: destination) { routes in
                    if let first = routes.first {
                        
                        routesReturnable.append(first) ///
                                                ///
                        
                        var route = first
                        route.tripPosition = self.currentTrip?.routes.count
                        
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
        if let start = self.currentTrip?.destinations.last,
           let end = currentTrip?.endLocation {
            
            makeDirectionsRequest(start: start, end: end) { routes in
                if let first = routes.first {

                    
                    completion(first)
                    
                }
            }
        }
    }
    
    
    func routesForDestinations(withCompletion completion: @escaping(Bool) -> (Void)) {
        self.currentTrip?.routes = []
        self.allRoutes = []
        getRoutesForTrip { route in
//            var newRoute = routes
//            newRoute.tripPosition = self.tripRoutes.count
            self.currentTrip?.routes.append(route)
            self.allRoutes.append(route)
        }
        completion(true)
    }
    
    
    func tripRoutesContains(_ route: Route) -> Bool {
        self.currentTrip?.routes.contains(where: { $0.id == route.id }) ?? false
    }
    
    //MARK: - Navigation
    
    func startTrip() {
        
        self.currentTrip?.tripState = .navigating
        
        if let currentLoc = userStore.currentLocation {
            self.mapRegion = MKCoordinateRegion(center: currentLoc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
        
//        let sortedTripRoutes = self.tripRoutes.sorted(by: { $0.tripPosition ?? 0 < $1.tripPosition ?? 1 })
        if let first = self.currentTrip?.routes.first(where: { $0.tripPosition == 0 }) {
        self.currentRoute = first
            self.currentTrip?.nextDestination = currentTrip?.destinations.first
//                self.highlightedPolyline = self.tripRoutes.first?.polyline
        self.routeIsHighlighted = true
            self.currentTrip?.recentlyCompletedDestination = currentTrip?.startLocation
            
//            DispatchQueue.background {
//                for route in self.currentTrip?.routes ?? [] {
//                    for step in route.steps.sorted(by: { $0.id ?? 0 < $1.id ?? 1 }) {
//                        self.currentTrip?.remainingSteps.append(step)
//                    }
//                }
//            }
            
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
        self.currentTrip?.tripState = .finished
    }
    
}

extension Array where Element == CLLocationCoordinate2D {
    func center() -> CLLocationCoordinate2D {
        var maxLatitude: Double = -200;
        var maxLongitude: Double = -200;
        var minLatitude: Double = Double(MAXFLOAT);
        var minLongitude: Double = Double(MAXFLOAT);
        
        for location in self {
            if location.latitude < minLatitude {
                minLatitude = location.latitude;
            }
            
            if location.longitude < minLongitude {
                minLongitude = location.longitude;
            }
            
            if location.latitude > maxLatitude {
                maxLatitude = location.latitude;
            }
            
            if location.longitude > maxLongitude {
                maxLongitude = location.longitude;
            }
        }
        
        return CLLocationCoordinate2DMake(CLLocationDegrees((maxLatitude + minLatitude) * 0.5), CLLocationDegrees((maxLongitude + minLongitude) * 0.5));
    }
}
