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
            let t1=CATransform3DMakeTranslation(0, 0, 0)
            let r1=CATransform3DMakeRotation(CGFloat(attitude.pitch), 0, 0, 1)
            let transform=CATransform3DConcat(t1, r1)
//            let t2=CATransform3DRotate(t1, CGFloat(-attitude.roll), 0, 1, 0)
            
            let axis=attitude.axis
            
            CompassRoseView(heading: self.mode == .trueHeading ? heading.trueHeading : heading.magneticHeading)
                .rotation3DEffect(axis.angle, axis: axis.axis, anchor: .center, anchorZ: 10, perspective: 1)
//                .rotation3DEffect(-attitude.rollAngle, axis: (0,1,0), anchor: .center, anchorZ: -30, perspective: 0.5)
//                .projectionEffect(.init(r1))
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
        CompassHeadingView(heading: Compass.Heading(magneticHeading: 0, trueHeading: 0), attitude: EulerAngles(roll: Angle(degrees: 0).radians, pitch: Angle(degrees: 0).radians, yaw: Angle(degrees: 0).radians), mode: .trueHeading)
    }
}


extension BinaryFloatingPoint{
    func clamped(range: ClosedRange<Self>)->Self{
        return min(max(range.lowerBound, self),range.upperBound)
    }
}
