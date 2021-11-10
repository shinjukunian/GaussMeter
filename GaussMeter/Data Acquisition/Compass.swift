//
//  Compass.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import Foundation
import Combine
import CoreLocation

class Compass:NSObject,ObservableObject, CLLocationManagerDelegate{
    
    struct Heading{
        let magneticHeading:Double
        let trueHeading:Double
        let accuracy:Double
        let timeStamp:Date
        let field:Field
        
        init(magneticHeading:Double = 0, trueHeading:Double = 0, accuracy:Double = 0, timeStamp:Date = Date(), field:Field = Field(x: 0, y: 0, z: 0, timeStamp: 0)){
            self.magneticHeading=magneticHeading
            self.trueHeading=trueHeading
            self.accuracy=accuracy
            self.timeStamp=timeStamp
            self.field=field
        }
        
        init(heading:CLHeading){
            self.trueHeading=heading.trueHeading
            self.accuracy=heading.headingAccuracy
            self.magneticHeading=heading.magneticHeading
            self.timeStamp=heading.timestamp
            self.field=Field(heading: heading)
        }
        
        var variation:Double{
            return trueHeading - magneticHeading
        }
        
        static let dummy = Heading()
        
    }
    
    
    static let shared=Compass()
    
    fileprivate let _geomagneticField = PassthroughSubject<Field, Never>()
    fileprivate let _heading = PassthroughSubject<Heading, Never>()
    
    fileprivate let locationManager=CLLocationManager()
    
    lazy var geomagneticField=_geomagneticField.eraseToAnyPublisher()
    lazy var heading=_heading.eraseToAnyPublisher()
    
    fileprivate var currentheading:CLHeading = CLHeading()
    
    var cancellable: Cancellable?

    override init() {
        super.init()
        self.locationManager.delegate=self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.currentheading=newHeading
        self._heading.send(Heading(heading: newHeading))
    }
    
    func startHeadingUpdates(){
        locationManager.startUpdatingHeading()
        cancellable = Timer.publish(every: 0.1, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {time in
                let ref=time.timeIntervalSinceReferenceDate
                var field=Field(heading: self.currentheading)
                field.timeStamp=ref
                self._geomagneticField.send(field)
            })
    }
    
    func stopHeadingUpdates(){
        locationManager.stopUpdatingHeading()
        cancellable?.cancel()
    }
}

extension Field{
    init(heading:CLHeading){
        self.x=heading.x
        self.y=heading.y
        self.z=heading.z
        self.timeStamp=heading.timestamp.timeIntervalSinceReferenceDate
    }
}
