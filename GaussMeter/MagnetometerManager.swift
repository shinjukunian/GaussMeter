//
//  Magnetometer.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/17.
//

import Foundation
import CoreMotion
import Combine

extension Field{
    init(magneticField:CMMagneticField, timestamp:TimeInterval) {
        self.x=magneticField.x
        self.y=magneticField.y
        self.z=magneticField.z
        self.timeStamp=timestamp
    }
}



class MagnetometerManager{
    
    static let shared=MagnetometerManager()
    
    fileprivate let _rawMagneticField = PassthroughSubject<Field, Never>()
    fileprivate let _magneticField = PassthroughSubject<Field, Never>()

    fileprivate let motionManager=CMMotionManager()
    
    lazy var rawMagneticField=_rawMagneticField.eraseToAnyPublisher()
    lazy var magneticField=_magneticField.eraseToAnyPublisher()
    
    init() {
        self.motionManager.magnetometerUpdateInterval = 1/60
        self.motionManager.deviceMotionUpdateInterval = 1/60
    }
    
    func startUpdates(){
        self.motionManager.startMagnetometerUpdates(to: OperationQueue(), withHandler: {data,_ in
            if let data=data{
                self._rawMagneticField.send(Field(magneticField: data.magneticField, timestamp: data.timestamp))
            }
        })
        
        self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue(), withHandler: {data, _ in
            if let data=data{
                self._magneticField.send(Field(magneticField: data.magneticField.field, timestamp: data.timestamp))
            }
        })
    }
    
    func stopUpdates(){
        self.motionManager.stopMagnetometerUpdates()
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    deinit {
        self.stopUpdates()
    }
    
    
}
