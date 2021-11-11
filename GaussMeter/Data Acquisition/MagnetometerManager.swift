//
//  Magnetometer.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/17.
//

import Foundation
import CoreMotion
import Combine
import SwiftUI

extension Field{
    init(magneticField:CMMagneticField, timestamp:TimeInterval) {
        self.x=magneticField.x
        self.y=magneticField.y
        self.z=magneticField.z
        self.timeStamp=timestamp
        self.accuracy = .uncalibrated
    }
    
    init(calibratedField:CMCalibratedMagneticField, timeStamp: TimeInterval){
        self.x=calibratedField.field.x
        self.y=calibratedField.field.y
        self.z=calibratedField.field.z
        self.timeStamp=timeStamp
        self.accuracy = .init(accuracy: calibratedField.accuracy)
    }
}

extension Field.FieldAccuracy{
    init(accuracy:CMMagneticFieldCalibrationAccuracy){
        switch accuracy {
        case .uncalibrated:
            self = .uncalibrated
        case .low:
            self = .low
        case .medium:
            self = .medium
        case .high:
            self = .high
        @unknown default:
            fatalError()
        }
    }
}


class MagnetometerManager{
    
    static let shared=MagnetometerManager()
    
    fileprivate let _rawMagneticField = PassthroughSubject<Field, Never>()
    fileprivate let _attitude = PassthroughSubject<EulerAngles, Never>()
    fileprivate let _magneticField = PassthroughSubject<Field, Never>()

    fileprivate let motionManager=CMMotionManager()
    
    lazy var rawMagneticField=_rawMagneticField.eraseToAnyPublisher()
    lazy var magneticField=_magneticField.eraseToAnyPublisher()
    lazy var attitude=_attitude.eraseToAnyPublisher()
    
    init() {
        self.motionManager.magnetometerUpdateInterval = 1/60
        self.motionManager.deviceMotionUpdateInterval = 1/60
    }
    
    func startUpdates(){
        self.motionManager.startMagnetometerUpdates(to: OperationQueue(), withHandler: {data,error in
            if let data=data{
                self._rawMagneticField.send(Field(magneticField: data.magneticField, timestamp: data.timestamp))
            }
            if let error=error{
                print(error)
            }
        })
        
        self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue(), withHandler: {data, error in
            if let data=data{
                self._magneticField.send(Field(calibratedField: data.magneticField, timeStamp: data.timestamp))
                self._attitude.send(EulerAngles(attitude: data.attitude))
            }
            if let error=error{
                print(error)
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
