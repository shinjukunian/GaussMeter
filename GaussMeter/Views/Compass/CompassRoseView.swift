//
//  CompassView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/10.
//

import SwiftUI

struct CompassRoseView: View {
    
    let heading:Double
    
    let inset:CGFloat=30
    
    let fractionalTickHeight:CGFloat=0.1
    
    let fractionalMinorTickHeight:CGFloat=0.05
    
    let majorTickIncrement:Int = 30
    let minorTickIncrement:Int = 5
    
    let fractionalTickCrossing:CGFloat = 0.0
    
    var body: some View {
        
        ZStack{
            GeometryReader(content: {proxy in
                Circle().inset(by: inset).strokeBorder()
                let radius=proxy.size.width / 2 - inset
                
                let center=CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
                
                Path({p in
                    let factor:CGFloat=3
                    p.move(to: CGPoint(x: center.x, y: inset * factor))
                    p.addLine(to: CGPoint(x: center.x, y: proxy.size.height - inset * factor))
                    p.move(to: CGPoint(x: inset * factor, y: center.y))
                    p.addLine(to: CGPoint(x: proxy.size.width - inset * factor, y: center.y))
                }).stroke(Color.gray)
                
                RadialTicks(center: center, radius: radius, fractionalHeight: fractionalTickHeight, fractionalCrossing: fractionalTickCrossing, increment: majorTickIncrement).stroke()
                
                RadialTicks(center: center, radius: radius, fractionalHeight: fractionalMinorTickHeight, fractionalCrossing: fractionalTickCrossing, increment: minorTickIncrement).stroke()
                

                
                let labelStrides=Array(stride(from: 0, to: 360, by: majorTickIncrement))
               
                ForEach(labelStrides, id: \.self, content: {angle in
                    let angleInRadians=Angle(degrees: Double(angle)).radians - Double.pi / 2
                    
                    let x_start = radius * (1-fractionalTickHeight*2) * cos(angleInRadians)
                    let y_start = radius * (1-fractionalTickHeight*2) * sin(angleInRadians)
                    Text(String(angle))
                        .position(x: center.x + x_start, y: center.y + y_start)
                        .font(.caption)
                    
                })
                
                
                Triangle().fill(Color.red)
                    .position(x: center.x, y: inset + radius * fractionalTickHeight / 2)
                    .frame(width: radius * fractionalTickHeight, height: radius * fractionalTickHeight, alignment: .top)
                
                
                Group{
                    Text("N").frame(alignment: .bottom)
                        .rotationEffect(Angle(degrees: heading))
                        .position(x: center.x, y: inset  / 2)
                    Text("E").frame(alignment: .trailing)
                        .rotationEffect(Angle(degrees: heading))
                        .position(x: proxy.size.width - inset / 2, y: center.y)
                    Text("S").frame(alignment: .top)
                        .rotationEffect(Angle(degrees: heading))
                        .position(x:  center.x, y: proxy.size.height - inset / 2)
                    Text("W").frame(alignment: .leading)
                        .rotationEffect(Angle(degrees: heading))
                        .position(x:  inset / 2, y: center.y)
                    
                }
                .font(.title2)
                Circle().stroke(Color.gray)
                    .frame(width: 10, height: 10, alignment: .center)
                    .position(x: center.x , y: center.y )
                    
                
                    
            })
                .aspectRatio(1, contentMode: .fit)
                .rotationEffect(Angle(degrees: -heading))

            
        }
        
    }
    
    
}

struct CompassRoseView_Previews: PreviewProvider {
    static var previews: some View {
        CompassRoseView(heading: 45)
    }
}



struct RadialTicks:Shape{
    
    let center:CGPoint
    let radius:CGFloat
    let fractionalHeight:CGFloat
    let fractionalCrossing:CGFloat
    let increment:Int
    
    func path(in rect: CGRect) -> Path {
        return Path({p in
            for angle in stride(from: 0, to: 360, by: increment){
                let angleInRadians=Angle(degrees: Double(angle)).radians
                let x_start = radius * (1-fractionalHeight) * cos(angleInRadians)
                let y_start = radius * (1-fractionalHeight) * sin(angleInRadians)
                let start=CGPoint(x: center.x + x_start, y: center.y + y_start)
                
                p.move(to: start)
                
                let x_end = radius * (1+fractionalCrossing) * cos(angleInRadians)
                let y_end = radius * (1+fractionalCrossing) * sin(angleInRadians)
                p.addLine(to: CGPoint(x: center.x + x_end, y: center.y + y_end))
            }
        })
        
    }
}
