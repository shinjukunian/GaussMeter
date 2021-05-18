//
//  FieldView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import SwiftUI

struct FieldView: View {
    
    struct DataPath: Hashable, Equatable{
        let path:CGPath
        let anchor:CGPoint
    }
    
    @EnvironmentObject var model:FieldViewModel
    
    let colors=[Color.red, Color.green, Color.blue]
    
    @State var maxDuration:Double=10
    
    var body: some View {
        GeometryReader(content: { geometry in
            let paths=self.paths(geometry: geometry)
            ForEach(Array(zip(paths, colors)), id: \.0, content: {(path,color) in
                Path(path).stroke(color)
            })
            
        }).overlay(HStack{
            let labels=["X","Y","Z"]
            ForEach(0..<colors.count){idx in
                Text(verbatim: labels[idx]).font(.caption).foregroundColor(colors[idx])
            }
        }, alignment: .topLeading)
    }
    
    
    func paths(geometry:GeometryProxy)->[CGPath]{
        
        var maxX=model.maxX
        var minX=model.minX
        
        let data:[Field]
        if maxX - minX < maxDuration{
            data=model.fieldData
        }
        
        else{
            let startTime=maxX - maxDuration
            
            let idx=model.fieldData.reversed().firstIndex(where: {$0.timeStamp < startTime}) ?? model.fieldData.startIndex
            data=Array(model.fieldData.suffix(from: model.fieldData.endIndex - idx))
        }
        
        guard let first=data.first else{
            return [CGPath]()
        }
        
        let minY=data.minY
        let maxY=data.maxY
        maxX=data.maxX
        minX=data.minX
        
        let xScale=Double(geometry.size.width) / (maxX-minX)

        let yScale=Double(geometry.size.height) / (maxY-minY)
        
        let pX=CGMutablePath()
        let pY=CGMutablePath()
        let pZ=CGMutablePath()
        
        let x0=first.timeStamp * xScale
        
        pX.move(to: CGPoint(x: first.timeStamp * xScale - x0, y: -first.x * yScale + maxY*yScale))
        pY.move(to: CGPoint(x: first.timeStamp * xScale - x0, y: -first.y * yScale + maxY*yScale))
        pZ.move(to: CGPoint(x: first.timeStamp * xScale - x0, y: -first.z * yScale + maxY*yScale))
        
        for f in data.dropFirst(){
            pX.addLine(to: CGPoint(x: f.timeStamp * xScale - x0, y: -f.x * yScale + maxY*yScale))
            pY.addLine(to: CGPoint(x: f.timeStamp * xScale - x0, y: -f.y * yScale + maxY*yScale))
            pZ.addLine(to: CGPoint(x: f.timeStamp * xScale - x0 , y: -f.z * yScale + maxY*yScale))
        }
        
        
        return [pX,pY,pZ]
    }
    
    
    
}

struct FieldView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FieldView().environmentObject(FieldViewModel.dummyModel)
    }
}
