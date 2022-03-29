//
//  LaunchScene.swift
//  CodeNinja
//
//  Created by Giuseppe Sica on 24/03/22.
//
import UIKit
import SpriteKit

class LaunchScene: SKScene {
    
    var bgImage: SKSpriteNode?
    var button: SKSpriteNode?
    
    override func sceneDidLoad() {
       
        bgImage = SKSpriteNode(texture: SKTexture(imageNamed: "launch"), size: self.size)
        
        
        button = SKSpriteNode(imageNamed: "play")
        
        }
    
    override func didMove(to view: SKView) {
        bgImage?.name = "bg"
        bgImage?.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        bgImage?.position = scene!.position
        bgImage?.zPosition = 0
        self.addChild(bgImage!)
        
        button?.name = "button"
        button?.position = CGPoint(x: 880 , y: 200)
        button?.zPosition = 100
        self.addChild(button!)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let first = touches.first
        if let atlocation = first?.location(in: self){
            if let touchedNode = atPoint(atlocation) as? SKSpriteNode{
                if touchedNode.name == "button" {
                    let nextScene = GameScene(size: CGSize(width: screenWidth, height: screenHeight))
                    nextScene.scaleMode = .aspectFill
                    view?.presentScene(nextScene, transition: .fade(withDuration: 2.0))
                    
                }
            }
        }
    }
    }
