//
//  LaunchGameScene.swift
//  CodeNinja
//
//  Created by Giuseppe Sica on 24/03/22.
//

import SpriteKit
import SwiftUI

struct LaunchGameScene: View{
    var body: some View {
        ZStack{
            Image("launch")
                .frame(width: 900, height: 410)
            VStack{
                Button(action:{
                GameScene()
                }) {
            Image("play")
            .frame(width: 500, height: 100)
            .position(x: 450 + 256, y: 512+64
            )
                }
        }
    }
    }
    
}


struct LaunchGameScene_Previews: PreviewProvider {
    static var previews: some View {
        LaunchGameScene()
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
.previewInterfaceOrientation(.landscapeLeft)
    }
}
