//
//  FieldView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import SwiftUI
import Foundation

struct FieldView: View {
    
    struct DataPath: Hashable, Equatable{
        let path:CGPath
        let anchor:CGPoint
        let anchorValue:Measurement<UnitMagneticField>
        let formattedAnchorValue:String
    }
    
    @EnvironmentObject var model:FieldViewModel
    
    @Environment(\.plotColors) var colors
    
    @Environment(\.outputUnit) var outputFormat
    
    @State var maxDuration:Double=10
    
    var formatter:MeasurementFormatter {
        let formatter=MeasurementFormatter()
        formatter.unitOptions = [.providedUnit]
        formatter.unitStyle = .medium
        formatter.numberFormatter.numberStyle = .scientific
        formatter.numberFormatter.maximumFractionDigits=1
        formatter.numberFormatter.minimumFractionDigits=1
        return formatter
    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            let paths=self.paths(geometry: geometry)
            ForEach(Array(zip(paths, colors)), id: \.0, content: {(path,color) in
                Path(path.path).stroke(color)
                Text(path.formattedAnchorValue)
                    .font(.callout)
                    .foregroundColor(color)
                    .fixedSize()
                    .frame(width: 50, alignment: .trailing)
                    .offset(x: path.anchor.x-50, y: path.anchor.y)
            })
            
        }).overlay(HStack{
            let labels=["X","Y","Z"]
            ForEach(0..<colors.count){idx in
                Text(verbatim: labels[idx]).font(.caption).foregroundColor(colors[idx])
            }
        }, alignment: .topLeading)
    }
    
    
    func paths(geometry:GeometryProxy)->[DataPath]{
        
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
        
        guard let first=data.first,
              let last=data.last else{
            return [DataPath]()
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
        let formatter=self.formatter
        let formattedValue=MagnometerFormatter.FormattedField.init(field: last, formatter: formatter, format: self.outputFormat)
        
        let xP=DataPath(path: pX, anchor: CGPoint(x: last.timeStamp * xScale - x0, y: -last.x * yScale + maxY*yScale), anchorValue: last.measurementX, formattedAnchorValue: formattedValue.x)
        let yP=DataPath(path: pY, anchor: CGPoint(x: last.timeStamp * xScale - x0, y: -last.y * yScale + maxY*yScale), anchorValue: last.measurementY, formattedAnchorValue: formattedValue.y)
        let zP=DataPath(path: pZ, anchor: CGPoint(x: last.timeStamp * xScale - x0, y: -last.z * yScale + maxY*yScale), anchorValue: last.measurementZ, formattedAnchorValue: formattedValue.z)
        
        
        return [xP,yP,zP]
    }
    
    
    
}

struct FieldView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FieldView().environmentObject(FieldViewModel.dummyModel)
    }
}
