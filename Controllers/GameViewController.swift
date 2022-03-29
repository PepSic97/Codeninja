//
//  GameViewController.swift
//  CodeNinja
//
//  Created by Giuseppe Sica on 21/03/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = LaunchScene(size: CGSize(width: screenWidth, height: screenHeight))
        scene.scaleMode = .aspectFill
        let skView = view as! SKView
//        skView.showsNodeCount = true
//        skView.showsFPS = true
        skView.showsPhysics = true
        skView.ignoresSiblingOrder = false
        skView.presentScene(scene)
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
