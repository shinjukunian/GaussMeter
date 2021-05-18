//
//  HeadingView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import SwiftUI

struct HeadingView: View {
    
    @Binding var heading:Double
    
    var body: some View {
        Triangle().fill(
            Color.red
        ).background(Color.clear)
        .aspectRatio(0.75 , contentMode: .fit)
        .rotationEffect(Angle(degrees: 360-heading))
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

struct HeadingView_Previews: PreviewProvider {
    static var previews: some View {
        HeadingView(heading: Binding.constant(45))
    }
}
