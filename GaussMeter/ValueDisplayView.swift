//
//  ValueDisplayView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import SwiftUI

struct ValueDisplayView: View {
    @EnvironmentObject var magnetometer:Magnetometer
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text("X")
                Spacer()
                Text("Y")
                Spacer()
                Text("Z")
                Spacer()
            }
            
            HStack{
                Spacer()
                Text("Raw")
                Text(verbatim:  magnetometer.formatter.rawMagneticField.x)
                Text(verbatim:  magnetometer.formatter.rawMagneticField.y)
                Text(verbatim:  magnetometer.formatter.rawMagneticField.z)
                Spacer()
            }
            HStack{
                Spacer()
                Text("Calibrated")
                Text(verbatim:  magnetometer.formatter.magneticField.x)
                Text(verbatim:  magnetometer.formatter.magneticField.y)
                Text(verbatim:  magnetometer.formatter.magneticField.z)
                Spacer()
            }
            HStack{
                Spacer()
                Text("Geomagnetic")
                Text(verbatim:  magnetometer.formatter.geomagneticField.x)
                Text(verbatim:  magnetometer.formatter.geomagneticField.y)
                Text(verbatim:  magnetometer.formatter.geomagneticField.z)
                Spacer()
            }
        }
        
    }
}

struct ValueDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ValueDisplayView().environmentObject(Magnetometer())
    }
}
