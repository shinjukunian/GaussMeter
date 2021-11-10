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

struct EulerAngles{
    let roll:Float
    let pitch:Float
    let yaw:Float
    
    static let `default` = EulerAngles(roll: 0, pitch: 0, yaw: 0)
    
    init(roll:Float, pitch:Float, yaw:Float) {
        self.roll=roll
        self.pitch=pitch
        self.yaw=yaw
    }
    
    init(_ s:SIMD3<Float>) {
        self.pitch=s.x
        self.yaw=s.y
        self.roll=s.z
    }
    
    init(attitude:CMAttitude) {
        self.pitch=Float(attitude.pitch)
        self.roll=Float(attitude.roll)
        self.yaw=Float(attitude.yaw)
    }
    
    var simdAngles:SIMD3<Float>{
        return SIMD3(pitch,yaw,roll)
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
        self.motionManager.startMagnetometerUpdates(to: OperationQueue(), withHandler: {data,_ in
            if let data=data{
                self._rawMagneticField.send(Field(magneticField: data.magneticField, timestamp: data.timestamp))
            }
        })
        
        self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue(), withHandler: {data, _ in
            if let data=data{
                self._magneticField.send(Field(magneticField: data.magneticField.field, timestamp: data.timestamp))
                self._attitude.send(EulerAngles(attitude: data.attitude))
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
