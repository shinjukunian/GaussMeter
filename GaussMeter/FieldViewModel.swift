//
//  FieldViewModel.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import Foundation
import Combine

class FieldViewModel:ObservableObject{
    
    static var dummyModel:FieldViewModel{
        let startTime:Double=0
        let endTime:Double=1000
        let interval=0.02
        let xSlope:Double=1
        let ySlope:Double = -0.2
        
        let field=stride(from: startTime, to: endTime, by: interval)
            .map{time -> Field in
                let z=sin(time/10)*10
                let f=Field(x: time*xSlope+z, y: time*ySlope, z: z, timeStamp: time)
                return f
            }
        let model=FieldViewModel()
        model.fieldData=field
        return model
    }
    
    @Published var fieldData:[Field]=[Field]()
    var startTime:TimeInterval=Double.greatestFiniteMagnitude
    
    var cancelables:Set<AnyCancellable>=Set<AnyCancellable>()
    
    var maxX:Double{
        return fieldData.maxX
    }
    
    var minX:Double{
        return fieldData.minX
    }
    
    var maxY:Double{
        return fieldData.maxY
    }
    
    var minY:Double{
        return self.minY
    }
    
    init() {}
    
    init(subject:AnyPublisher<Field,Never>) {
        
        subject.receive(on: RunLoop.main)
            .collect(.byTime(RunLoop.main, .seconds(0.2)) , options: nil)
            .sink(receiveValue: {value in
                self.startTime = min(value.first?.timeStamp ?? Double.greatestFiniteMagnitude, self.startTime)
                self.fieldData.append(contentsOf: value.map({v in
                    return Field(field: v, offset: self.startTime)
                }))
                
                self.objectWillChange.send()
                
            })
            .store(in: &cancelables)
    }
    
    func reset(){
        self.fieldData.removeAll()
        self.startTime=Double.greatestFiniteMagnitude
    }
    
    
}

