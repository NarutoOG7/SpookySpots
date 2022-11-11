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
    
//    @Published var destinations: [Destination] = [] {
//        didSet {
//            self.getRoutes()
//        }
//    }

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
                let time = Time().secondsToHoursMinutes(duration)
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
                exploreVM.setRegion(destination: newValue.startLocation)
                PersistenceController.shared.createOrUpdateTrip(newValue)
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
//            if let newValue = newValue {
                self.alternateRouteState = .selected
                
//                for route in currentTrip?.routes ?? [] {
//                    if route.collectionID == newValue.collectionID {
//                        currentTrip?.routes.removeAll(where: { $0 == route })
//                    }
//                }
//
//                currentTrip?.routes.append(newValue)
//            }
        }
    }
    
    @Published var altsHaveFirst: Bool = false
    @Published var altsHaveSecond: Bool = false
    @Published var altsHaveThird: Bool = false
    @Published var alternateRouteState: AlternateRouteState = .inactive
    
    @Published var allRoutes: [Route] = []
        
    @Published var isShowingSheetForStartOrStop = false
    
    @Published var coreDataTrip: CDTrip?
    
    
//    @Published var moc: NSManagedObjectContext?
    
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var exploreVM = ExploreViewModel.instance

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
                        
            
            fetchTrip()
            
            self.mapRegion = MKCoordinateRegion(center:
                                                    CLLocationCoordinate2D(
                                                        latitude: currentTrip?.startLocation.lat ?? 0,
                                                        longitude: currentTrip?.startLocation.lon ?? 0),
                                                span: MapDetails.defaultSpan)


            
        }
    }
    
    func fetchTrip() {
        PersistenceController.shared.activeTrip { trip in

            if let trip = trip {
                self.currentTrip = trip
            } else {
                self.resetTrip()
                self.mapRegion = MapDetails.defaultRegion
            }
            
        } onError: { err in
            // banner error saying troubles fetching trip? Or no error messsage at all if its just not a trip there
        }
    }
    
    func resetTrip() {
        
        if let currentLoc = userStore.currentLocation {
            
            firebaseManager.getAddressFrom(coordinates: currentLoc.coordinate) { address in
                
                let startLoc = Destination(id: UUID().uuidString,
                                       lat: currentLoc.coordinate.latitude,
                                       lon: currentLoc.coordinate.longitude,
                                       address: address.streetCityState(),
                                       name: "Current Location",
                                       position: 0)
                
               let endLoc = Destination(id: UUID().uuidString,
                                     lat: currentLoc.coordinate.latitude,
                                     lon: currentLoc.coordinate.longitude,
                                     address: address.streetCityState(),
                                     name: "Current Location",
                                     position: 0)
                var trip = Trip(id: UUID().uuidString,
                                userID: self.userStore.user.id,
                                destinations: [],
                                startLocation: startLoc,
                                endLocation: endLoc,
                                routes: [],
                                remainingSteps: [],
                                completedStepCount: 0,
                                totalStepCount: 0,
                                tripState: .building)
                trip.recentlyCompletedDestinationIndex = 0
                trip.nextDestinationIndex = 0
                
                self.currentTrip = trip
                self.routeIsHighlighted = false
                self.currentRoute = nil
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
        
        if let selectedAlternate = selectedAlternate {
            
            for route in currentTrip?.routes ?? [] {
                if route.collectionID == selectedAlternate.collectionID {
                    currentTrip?.routes.removeAll(where: { $0 == route })
                }
            }
            currentTrip?.routes.append(selectedAlternate)
            
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
            selectedAlternate = nil
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
            
            let index = (self.currentTrip?.destinations.count ?? 0) + 1
            
            let destination = Destination(
                id: "\(location.location.id)",
                lat: cloc.coordinate.latitude,
                lon: cloc.coordinate.longitude,
                address: location.location.address?.streetCityState() ?? Address().streetCityState(),
                name: location.location.name,
                position: index)
            if let currentTrip = self.currentTrip {
                
                self.currentTrip?.destinations.append(destination)
            }
//            self.locationStore.activeTripLocations.append(destination)
//            self.saveCurrentTripOnBackground()
        }
    }
    
    func removeDestination(_ location: LocationModel) {
        objectWillChange.send()
        self.currentTrip?.destinations.removeAll(where: { $0.name == location.location.name })
//        self.locationStore.activeTripLocations.removeAll(where: { $0.name == location.location.name })
        self.currentTrip?.routes.removeAll(where: { $0.id == "\(location.location.id)" })
//        self.saveCurrentTripOnBackground()
        
        for route in self.currentTrip?.routes.filter({ $0.collectionID == "\(location.location.id)" }) ?? [] {
            self.currentTrip?.routes.removeAll(where: { $0 == route })
        }

    }
    
    
    func removeDestination(atIndex index: Int) {
        objectWillChange.send()
        self.currentTrip?.destinations.remove(at: index)
//        self.locationStore.activeTripLocations.remove(at: index)
        if currentTrip?.routes.indices.contains(index) ?? false {
            self.currentTrip?.routes.remove(at: index)
        }
//        self.saveCurrentTripOnBackground()

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
            return Time().formatTime(time: travelTime)
        }
        return nil
    }
    
    func getHighlightedRouteTravelTimeAsTime() -> Time? {
        if let travelTime = currentRoute?.travelTime {
            let time = Time().secondsToHoursMinutes(travelTime)
            //            self.currentRouteTravelTime = time
            return time
        }
        return nil
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
            let zoomedOutSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            exploreVM.searchRegion = MKCoordinateRegion(center: center, span: zoomedOutSpan)
        }
    }
    
    //MARK: -  Routes
    
    func getRoutes() {
        self.currentTrip?.routes = []
        self.routesForDestinations { success in
            if success {
                self.getReturnHome { route in
                    var newRoute = route
                    newRoute.tripPosition = self.currentTrip?.routes.count
                    self.currentTrip?.routes.append(newRoute)
                    DispatchQueue.background {
                        
//                        self.saveCurrentTripOnBackground()
                    }
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
            
            for rt in response.routes.prefix(3) {
                                
                let routeID = UUID().uuidString

                let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: rt.polyline.pointCount)
                rt.polyline.getCoordinates(coordsPointer, range: NSMakeRange(0, rt.polyline.pointCount))
                
                let polyline = RoutePolyline(points: rt.polyline.points(), count: rt.polyline.pointCount)
                polyline.startLocation = start
                polyline.endLocation = end
                polyline.parentCollectionID = end.id
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
    }
    
    
    private func getRoutesForTrip(withCompletion completion: @escaping(Route) -> (Void)) {
    
        if let currentTrip = currentTrip {
            
            var first: Destination = currentTrip.startLocation
            var usedDestinations: [Destination] = []
            
            var routesReturnable: [Route] = []
            
            for destination in currentTrip.destinations {
                
                makeDirectionsRequest(start: first, end: destination) { routes in
                    if let first = routes.first {
                        
                        routesReturnable.append(first)
                                                
                        
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
        
        if let first = self.currentTrip?.routes.first(where: { $0.tripPosition == 0 }) {
            self.currentRoute = first
            
            self.routeIsHighlighted = true
            
        }
        
    }
    
    func pauseDirections() {
        self.currentTrip?.tripState = .paused
        self.endDirections()
    }
    
    func resumeDirections() {
        self.currentTrip?.tripState = .navigating
        
        if let route = self.currentTrip?.routes.first(where: { $0.tripPosition == self.currentTrip?.currentRouteIndex }) {
            self.currentRoute = route
            self.routeIsHighlighted = true
        }
    }
    
    func endDirections() {
        self.currentRoute = nil
        self.routeIsHighlighted = false
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
