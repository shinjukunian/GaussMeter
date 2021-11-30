//
//  EulerAngles.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/11.
//

import Foundation
import SwiftUI
import CoreMotion

struct EulerAngles{
    let roll:Float
    let pitch:Float
    let yaw:Float
    
    static let `default` = EulerAngles(roll: Float(0), pitch: 0, yaw: 0)
    
    init(roll:Float, pitch:Float, yaw:Float) {
        self.roll=roll
        self.pitch=pitch
        self.yaw=yaw
    }
    
    init(roll:Double, pitch: Double, yaw:Double){
        self.roll=Float(roll)
        self.pitch=Float(pitch)
        self.yaw=Float(yaw)
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
    
    var pitchAngle:Angle{
        return Angle(radians: Double(pitch))
    }
    
    var rollAngle:Angle{
        return Angle(radians: Double(roll))
    }
    
    var yawAngle:Angle{
        return Angle(radians: Double(yaw))
    }
    
    var axis:EulerAxis{
        return EulerAxis(eulerAngles: self)
    }
    
    struct EulerAxis{
        let axis:(x:CGFloat, y:CGFloat, z:CGFloat)
        let angle:Angle
        
        
        
        init(eulerAngles:EulerAngles, ignoreZ:Bool = true){
            
            
            let c1:Float
            let s1:Float
            
        
            c1=cos(ignoreZ ? 0.01 : eulerAngles.yaw / 2)
            s1=sin(ignoreZ ? 0.01 : eulerAngles.yaw / 2)
            
            
            let c2=cos(eulerAngles.pitch / 2)
            let s2=sin(eulerAngles.pitch / 2)
            let c3=cos(-eulerAngles.roll / 2)
            let s3=sin(-eulerAngles.roll / 2)
            
            let c1c2 = c2*c2
            let s1s2 = s1*s2
            
            let w=c1c2*c3 - s1s2*s3
            var x=c1c2*s3 + s1s2*c3
            var y=s1*c2*c3 + c1*s2*s3
            var z=c1*s2*c3 - s1*c2*s3
            
            let angle=2*acos(w)
            
            var norm=x*x+y*y+z*z
            
            self.angle=Angle(radians: Double(angle))
            
            if abs(self.angle.degrees) < 0.000001{
                self.axis = (x:CGFloat(1), y:CGFloat(0), z:CGFloat(0))
            }
            else{
                if norm < 0.001{
                    x=1
                    z=0
                    z=0
                }
                else{
                    norm = sqrt(norm)
                }
                
                x/=norm
                y/=norm
                z/=norm
                
                
                self.axis=(x:CGFloat(z), y:CGFloat(x), z:CGFloat(y))
            }
        }
        
        
    }
}
