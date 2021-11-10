//
//  DefineAxesView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import SwiftUI

struct DefineAxesView: View {
    var body: some View {
        
        GeometryReader(content: { geometry in
            let inset=CGRect(origin: .zero, size: geometry.size).insetBy(dx: 5, dy: 5)
            let phoneBox=CGRect(x: inset.minX+inset.width/4, y: inset.minY, width: inset.width/2, height: inset.height)
            ZStack{
                Path(roundedRect: phoneBox, cornerRadius: 4)
                    .stroke()
                
                Path(roundedRect: CGRect(x: phoneBox.minX+phoneBox.width/4, y: phoneBox.minY, width: inset.width/4, height: 3), cornerRadius: /*@START_MENU_TOKEN@*/5/*@END_MENU_TOKEN@*/, style: .continuous)
                
                Path(roundedRect: CGRect(x: phoneBox.minX+phoneBox.width/4, y: phoneBox.maxY-7, width: inset.width/4, height: 3), cornerRadius: /*@START_MENU_TOKEN@*/5/*@END_MENU_TOKEN@*/, style: .continuous)
                
                Path({ path in
                    path.move(to: CGPoint(x: phoneBox.midX, y: phoneBox.midY))
                    path.addLine(to: CGPoint(x: phoneBox.maxX+5, y: phoneBox.midY+phoneBox.height/15))
                }).stroke(Color.red, lineWidth: 2)
                
                Triangle()
                    .frame(width: 5, height: 5, alignment: .top)
                    .foregroundColor(.red)
                    .rotationEffect(Angle(degrees: -10))
                    .offset(x: phoneBox.minX, y: phoneBox.height/15-1)
                
                Path({ path in
                    path.move(to: CGPoint(x: phoneBox.midX, y: phoneBox.midY))
                    path.addLine(to: CGPoint(x: phoneBox.midX, y: phoneBox.minY+10))
                }).stroke(Color.green, lineWidth: 2)
                
                Triangle()
                    .frame(width: 6, height: 6, alignment: .top)
                    .foregroundColor(.green)
                    .offset(x: 0, y: -phoneBox.midY/2)
                
                Path({ path in
                    path.move(to: CGPoint(x: phoneBox.midX, y: phoneBox.midY))
                    path.addLine(to: CGPoint(x: phoneBox.midX-phoneBox.width/2-5, y: phoneBox.midY+phoneBox.height/10))
                }).stroke(Color.blue, lineWidth: 2)
                
                Triangle()
                    .frame(width: 8, height: 8, alignment: .top)
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: 10))
                    .offset(x: -phoneBox.minX, y: phoneBox.height/10-2)
                
            }.rotation3DEffect(.degrees(45), axis: (x: 0, y: -1, z: 0))

        }).aspectRatio(1, contentMode: .fit)
        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 35, maxWidth: 50, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 35, maxHeight: 50, alignment: .center)
        
//        PhoneShape().stroke(lineWidth: 10)
//        Image(systemName: "iphone")
//            .renderingMode(.template)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .foregroundColor(Color.gray)
            
    }
}


//struct PhoneShape:Shape{
//    func path(in rect: CGRect) -> Path {
//
//        let p=Path(roundedRect: inset, cornerRadius: 25)
//        p.addPath(Path(roundedRect: CGRect(origin: <#T##CGPoint#>, size: <#T##CGSize#>), cornerRadius: /*@START_MENU_TOKEN@*/5/*@END_MENU_TOKEN@*/), transform: <#T##CGAffineTransform#>)
//    }
//}

struct DefineAxesView_Previews: PreviewProvider {
    static var previews: some View {
        DefineAxesView()
    }
}
