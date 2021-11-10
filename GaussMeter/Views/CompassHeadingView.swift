//
//  CompassView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/10.
//

import SwiftUI

struct CompassHeadingView: View {
    
    let heading:Double
    let attitude:EulerAngles
    
    let limit:Double = 1
    
    var body: some View {
        ZStack{
            CompassRoseView(heading: heading)
                
                .rotation3DEffect(.radians(min(limit,Double(attitude.pitch))), axis: (x: 1, y: 0, z: 0), anchor: .center, anchorZ: 1, perspective: 1)
                .rotation3DEffect(.radians(min(limit,Double(attitude.roll))), axis: (x: 0, y: 1, z: 0), anchor: .center, anchorZ: 1, perspective: 1)
            Circle().stroke()
                .frame(width: 15, height: 15, alignment: .center)
        }
    }
}

struct CompassHeadingView_Previews: PreviewProvider {
    static var previews: some View {
        CompassHeadingView(heading: 90, attitude: EulerAngles(roll: 0, pitch: -0.2, yaw: 0))
    }
}
