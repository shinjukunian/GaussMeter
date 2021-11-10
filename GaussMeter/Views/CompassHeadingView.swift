//
//  CompassView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/10.
//

import SwiftUI

struct CompassHeadingView: View {
    
    let heading:Compass.Heading
    let attitude:EulerAngles
    
    let mode:CompassView.CompassHeadingMode
    
    let limit = (-CGFloat.pi/2) * 0.7 ... (CGFloat.pi/2)*0.7
    
    var body: some View {
        
        ZStack(alignment: .center){
            let t1=CATransform3DMakeRotation(CGFloat(attitude.pitch), 1, 0, 0)
            let t2=CATransform3DRotate(t1, CGFloat(-attitude.roll), 0, 1, 0)
            
            CompassRoseView(heading: self.mode == .trueHeading ? heading.trueHeading : heading.magneticHeading)
                .projectionEffect(.init(t2))
            Circle().stroke()
                .frame(width: 15, height: 15, alignment: .center)
            
        }
        .background(backgroundRect, alignment: .top)

    }
    
    var backgroundRect:some View{
        
        GeometryReader(content: {proxy in
            let dev=self.mode == .trueHeading ? -heading.variation : heading.variation
            Rectangle()
                .fill(Color.gray)
                .frame(width: 4, height: 50, alignment: .top)
                .position(x: proxy.size.width/2, y: 25)
            Rectangle()
                .fill(Color.gray)
                .frame(width: 2, height: 50, alignment: .top)
                .position(x: proxy.size.width/2, y: 25)
                .rotationEffect(.degrees(dev), anchor: .center)
        })
        
            
    }
}

struct CompassHeadingView_Previews: PreviewProvider {
    static var previews: some View {
        CompassHeadingView(heading: Compass.Heading(magneticHeading: 45, trueHeading: 30), attitude: EulerAngles(roll: 0, pitch: 0, yaw: 0), mode: .trueHeading)
    }
}


extension BinaryFloatingPoint{
    func clamped(range: ClosedRange<Self>)->Self{
        return min(max(range.lowerBound, self),range.upperBound)
    }
}
