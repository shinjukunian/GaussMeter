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
    static let shared=Compass()
    
    fileprivate let _geomagneticField = PassthroughSubject<Field, Never>()
    fileprivate let _heading = PassthroughSubject<Double, Never>()
    
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
        self._heading.send(newHeading.magneticHeading)
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
