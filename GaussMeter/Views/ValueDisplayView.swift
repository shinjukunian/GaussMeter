//
//  ValueDisplayView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import SwiftUI

struct ValueDisplayView: View {
    @EnvironmentObject var magnetometer:Magnetometer
    @Environment(\.plotColors) var colors
    
    var body: some View {
        
        HStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
            VStack(alignment: .trailing, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Text(" ")
                Text("Raw")
                Text("Calibrated")
                Text("Geomagnetic")
            })
            
            VStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Text("X").foregroundColor(colors[0])
                
                Text(verbatim:  magnetometer.formatter.rawMagneticField.x)
                Text(verbatim:  magnetometer.formatter.magneticField.x)
                Text(verbatim:  magnetometer.formatter.geomagneticField.x)
            })
        VStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                
                Text("Y").foregroundColor(colors[1])
                Text(verbatim:  magnetometer.formatter.rawMagneticField.y)
                
                Text(verbatim:  magnetometer.formatter.magneticField.y)
                Text(verbatim:  magnetometer.formatter.geomagneticField.y)
                
                
            })
        VStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                
                Text("Z").foregroundColor(colors[2])
                
                Text(verbatim:  magnetometer.formatter.rawMagneticField.z)
                
                Text(verbatim:  magnetometer.formatter.magneticField.z)
                Text(verbatim:  magnetometer.formatter.geomagneticField.z)
                
            })
        })
    }
}

struct ValueDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ValueDisplayView().environmentObject(Magnetometer())
    }
}
