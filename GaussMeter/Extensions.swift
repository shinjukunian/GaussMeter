//
//  Extensions.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import Foundation
import SwiftUI

extension CGPoint: Hashable{
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
    
    
}

extension Array{
    func subsampled(maxElements:Int)->[Element]{
        if self.count < maxElements{
            return self
        }
        else{
            let s = self.count / maxElements
            return stride(from: 0, to: self.count, by: s).map({idx in
                return self[idx]
            })
        }
    }
}



