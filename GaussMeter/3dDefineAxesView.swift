//
//  3dDefineAxesView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/19.
//

import SwiftUI
import SceneKit
import SpriteKit

struct ThreeDDefineAxesView: View {
    
    var scene:SCNScene{
        let url=Bundle.main.url(forResource: "iPhoneModel", withExtension: "scn")!
        let scene = try! SCNScene(url: url, options: [.checkConsistency:true])
//        scene.rootNode.simdScale=SIMD3(0.75,0.75,0.75)
//        scene.rootNode.simdEulerAngles=SIMD3(Float.pi/2,Float.pi*2, Float.pi/4)
        
//        scene.background.contents = UIColor.clear
        return scene
    }
    
   


    var body: some View {
        
        SceneView(scene: scene, pointOfView: nil, options: [ .autoenablesDefaultLighting], preferredFramesPerSecond: 30, antialiasingMode: .multisampling2X, delegate: nil, technique: nil)
            .aspectRatio(1, contentMode: .fit).frame(width: 50, height: 50, alignment: .trailing)
    }
}

struct ThreeDDefineAxesView_Previews: PreviewProvider {
    static var previews: some View {
        ThreeDDefineAxesView()
    }
}
