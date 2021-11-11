//
//  TabView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/10.
//

import SwiftUI

struct MagnetometerTabView: View {
    
    enum Tabs:String{
        case chart
        case compass
        case magnetometer
    }
    
    @StateObject var magnetometer=MagnetometerCommunicator()
    @SceneStorage("selectedTab") var selectedTab:Tabs = .chart
    
    var body: some View {
        
        TabView(selection: $selectedTab){
            GaussMeterChartView(communicator: magnetometer)
                .tabItem({
                Label(title: {Text("Chart")}, icon: {Image(systemName: "chart.xyaxis.line")})
                })
                .tag(Tabs.chart)
            
            CompassView()
                .tabItem({
                Label(title: {Text("Compass")}, icon: {Image(systemName: "location.north.line")})
                })
                .tag(Tabs.compass)
            MagnetometerView()
                .tabItem({
                    Label(title: {Text("Gaussmeter")}, icon: {
                        Image(systemName: "gauge")
                    })
                }).tag(Tabs.magnetometer)
           
        }
        
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        MagnetometerTabView()
    }
}
