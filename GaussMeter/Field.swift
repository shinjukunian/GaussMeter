//
//  Field.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import Foundation

struct Field{
    let x:Double
    let y:Double
    let z:Double
    
    var timeStamp:TimeInterval
    
    init(field:Field, offset:TimeInterval) {
        self.x=field.x
        self.y=field.y
        self.z=field.z
        self.timeStamp=field.timeStamp-offset
    }
    
    init(x:Double, y:Double, z:Double, timeStamp:TimeInterval){
        self.x=x
        self.y=y
        self.z=z
        self.timeStamp=timeStamp
    }
    
    init(){
        self.x=0
        self.y=0
        self.z=0
        self.timeStamp=0
    }
    
    var measurementX:Measurement<UnitMagneticField>{
        return Measurement(value: x, unit: .microTeslas)
    }
    
    var measurementY:Measurement<UnitMagneticField>{
        return Measurement(value: y, unit: .microTeslas)
    }
    var measurementZ:Measurement<UnitMagneticField>{
        return Measurement(value: z, unit: .microTeslas)
    }
    
    mutating func offset(by time:TimeInterval){
        self.timeStamp-=time
    }
    
    var maxY:Double{
        return max(x, y, z)
    }
    var minY:Double{
        return min(x, y, z)
    }
    
}

final class UnitMagneticField:Dimension{
    
    static let microTeslas=UnitMagneticField(symbol: "µT", converter: UnitConverterLinear(coefficient: 1/1_000_000))
    static let gauss=UnitMagneticField(symbol: "G", converter: UnitConverterLinear(coefficient: 1/10_000))
    static let tesla=UnitMagneticField(symbol: "T", converter: UnitConverterLinear(coefficient: 1))
    
    
    override class func baseUnit() -> UnitMagneticField {
        return tesla
    }
}

extension Array where Element == Field{
    
    var maxY:Double{
        return self.max(by: {$0.maxY < $1.maxY})?.maxY ?? 0
    }
    
    var minY:Double{
        return self.min(by: {$0.minY < $1.minY})?.minY ?? 0
    }
    
    var minX:Double{
        return self.first?.timeStamp ?? 0
    }
    
    var maxX:Double{
        return self.last?.timeStamp ?? 0
    }
}
