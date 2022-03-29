//
//  GameOverOverlay.swift
//  CodeNinja
//
//  Created by Giuseppe Sica on 22/03/22.
//

import SpriteKit

struct GOOverlaySettings {
    static let ContinueNode = "ContinueNode"
    static let ContinueLbl = "ContinueLbl"
    
    static let PlayNode = "PlayNode"
    static let PlayLbl = "PlayLbl"
    
}

class GameOverOverlay: BaseOverlay{
    private var titleLbl: SKLabelNode!
   
    private var continueLbl: SKLabelNode!
    private var continueNode: SKShapeNode!
   
    private var playLbl: SKLabelNode!
    private var playNode: SKShapeNode!
    
    var isContinue = false {
        didSet {
            updateBtn(true, event: isContinue, node: continueNode)
            updateBtn(true, event: isContinue, node: continueLbl)
        }
    }
    var isPlay = false {
        didSet{
            updateBtn(true, event: isPlay, node: playNode)
            updateBtn(true, event: isPlay, node: playLbl)
        }
    }
    
    override init(gameScene: GameScene, size: CGSize){
        super.init(gameScene: gameScene, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == GOOverlaySettings.ContinueNode || node.name == GOOverlaySettings.ContinueLbl {
        if !isContinue { isContinue = true}
            
        } else if node.name == GOOverlaySettings.PlayNode || node.name == GOOverlaySettings.PlayLbl {
        if !isPlay { isPlay = true }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isContinue {
            gameScene.presentScene()
            isContinue = false
        }
        if isPlay {
            let fade = SKAction.fadeAlpha(to: 0.0, duration: 0.5)
            bgNode.run(fade) { self.bgNode.isHidden = true}
            playNode.run(.sequence([fade, .removeFromParent()]))
            playLbl.run(.sequence([fade, .removeFromParent()]))
         
            gameScene.isGameEnded = false
            run(.wait(forDuration: 1.5)){
                self.gameScene.tossHandler()
            }
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        if isContinue {
            if let parent = continueNode.parent {
                let location = touch.location(in: parent)
                isContinue = continueNode.contains(location)
            }
        }
        if isPlay {
            if let parent = playNode.parent {
                let location = touch.location(in: parent)
                isPlay = playNode.contains(location)
            }
        }
    }
    
}


//setups
extension GameOverOverlay{
    func setups(_ isPlay: Bool = false){
        isUserInteractionEnabled = true
        let rect = gameScene.playableRect
        let continueW: CGFloat = appDl.Ipad ? 600.0: rect.width*0.6
        let continueH: CGFloat = appDl.IphoneX ? 150.0 : 180.0
        
        guard !isPlay else {
            let playX = rect.midX - continueW/2
            let playY = rect.midY - continueH/2
            let playRect = CGRect(x: playX, y: playY, width: continueW, height: continueH)
            playNode = createBGNode(playRect, corner: 16.0)
            playNode.name = GOOverlaySettings.PlayNode
            
            let pF = playNode.frame
            let pPos = CGPoint(x: pF.midX, y: pF.midY)
            playLbl = createLbl(pPos, hori: .center, verti: .center, txt: "Play", fontS: 60.0)
            playLbl.name = GOOverlaySettings.PlayLbl
            return
        }
        let continueX = rect.midX - continueW/2
        let continueY = rect.minY+200
        let continueRect = CGRect(x: continueX, y: continueY, width: continueW, height: continueH)
        continueNode = createBGNode(continueRect, corner: 16.0)
        continueNode.name = GOOverlaySettings.ContinueNode
       
        let cF = continueNode.frame
        let conPos = CGPoint(x: cF.midX, y: cF.midY)
        continueLbl = createLbl(conPos, hori: .center, verti: .center, txt: "Continue", fontS: 60.0)
        continueLbl.name = GOOverlaySettings.ContinueLbl
        
        
        titleLbl = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLbl.text = "GAME OVER"
        titleLbl.fontSize = 250.0
        titleLbl.numberOfLines = 0
        titleLbl.preferredMaxLayoutWidth = rect.width
        titleLbl.isHidden = true
        titleLbl.position = CGPoint (x: rect.midX, y: rect.height - titleLbl.frame.height/2 - 100)
        addChild(titleLbl)
        
        
        
    }
    private func createBGNode(_ rect: CGRect, corner: CGFloat = 0.0) -> SKShapeNode {
        let bgColor = UIColor(red: 206/255, green: 142/255, blue: 96/255, alpha: 0.5)
        let shapeNode = SKShapeNode(rect: rect, cornerRadius: corner)
        shapeNode.strokeColor = bgColor
        shapeNode.fillColor = bgColor
        shapeNode.isHidden = true
        addChild(shapeNode)
        return shapeNode
    }
    private func createLbl(_ pos: CGPoint, hori: SKLabelHorizontalAlignmentMode, verti: SKLabelVerticalAlignmentMode, txt: String, fontC: UIColor = .white, fontS: CGFloat = 45.0) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        lbl.fontColor = fontC
        lbl.fontSize = fontS
        lbl.text = txt
        lbl.horizontalAlignmentMode = hori
        lbl.verticalAlignmentMode = verti
        lbl.position = pos
        lbl.isHidden = true
        addChild(lbl)
        return lbl
    }
    
    private func updateBtn(_ anim: Bool, event: Bool, node: SKNode){
        var alpha: CGFloat = 1.0
        if event { alpha = 0.5 }
        
        if anim {
            node.run(.fadeAlpha(to: alpha, duration: 0.1))
        } else {
            node.alpha = alpha
        }
    }
    
    func showPlay() {
        playNode.isHidden = false
        playLbl.isHidden = false
        
        fadeInBG()
        fadeIn(playNode, delay: 0.5)
        fadeIn(playLbl, delay: 0.5)
        
    }
    
    func showGameOver(_ txt: String) {
        continueNode.isHidden = false
        continueLbl.isHidden = false
        
        titleLbl.isHidden = false
        titleLbl.text = txt
        
        fadeInBG()
        fadeIn(continueNode, delay: 0.5)
        fadeIn(continueLbl, delay: 0.5)
    }
    
}


