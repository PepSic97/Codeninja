//
//  GameScene.swift
//  CodeNinja
//
//  Created by Giuseppe Sica on 21/03/22.
//

import SpriteKit
import GameplayKit

//proprieties

class GameScene: SKScene {
    
    var gameOverOverlay: GameOverOverlay!
    
    var popupTime: Double = 0.99
    var isNextSequenceQueued = true
    var sequenceType: [SequenceType] = []
    var spawnType: [SpawnType] = []
    var sequencePos = 0
    var delay = 0.7
    var activeSprites: [SKNode] = []
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var activeSlicePoints: [CGPoint] = []
    
    var scoreLbl: SKLabelNode!
    var score: Int = 0 {
        willSet{
            scoreLbl.text = "\(newValue)"
            scoreLbl.run(.sequence([.scale(to: 1.5, duration: 0.1), .scale(to:1.0, duration: 0.1)]))
            
        }
    }
    
    var livesNode: [SKSpriteNode] = []
    var lives = 3
    
    
    var playableRect: CGRect{
        let ratio: CGFloat = appDl.IphoneX ? 2.16: 16/9
        let width = size.width
        let height = width/ratio
        let x : CGFloat = 0.0
        let y : CGFloat = (size.height - height)/2
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    let buttonSound = SKAction.playSoundFileNamed(SoundType.button.rawValue, waitForCompletion: false)
    let swordSound = SKAction.playSoundFileNamed(SoundType.sword.rawValue, waitForCompletion: false)
    let launchSound = SKAction.playSoundFileNamed(SoundType.launch.rawValue, waitForCompletion: false)
    let creditSound = SKAction.playSoundFileNamed(SoundType.credit.rawValue, waitForCompletion: false)
    var swooshSounds: [SKAction] = [
        .playSoundFileNamed(SoundType.swoosh1.rawValue, waitForCompletion: true),
        .playSoundFileNamed(SoundType.swoosh2.rawValue, waitForCompletion: true),
        .playSoundFileNamed(SoundType.swoosh3.rawValue, waitForCompletion: true),
    ]
    let bruhSound = SKAction.playSoundFileNamed(SoundType.bruh.rawValue, waitForCompletion: false)
    let backSound = SKAction.playSoundFileNamed(SoundType.back.rawValue, waitForCompletion: false)
    let wowSound = SKAction.playSoundFileNamed(SoundType.wow.rawValue, waitForCompletion: false)
    var isSwooshSound = false
    
    
    var isGameEnded = true
    var isReload = true
    
    
    
    //    lifecycle
    
    override func didMove(to view: SKView) {
        setupNodes()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        for _ in touches{
            guard let touch = touches.first
            else {
                return
            }
            let location = touch.location(in: self)
            activeSlicePoints.append(location)
            redrawActiveSlice()
            activeSliceBG.removeAllActions()
            activeSliceFG.removeAllActions()
            
            activeSliceFG.alpha = 1.0
            activeSliceBG.alpha = 1.0
            
        }
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        activeSliceBG.run(.fadeAlpha(by: 0.0, duration: 0.25))
        activeSliceFG.run(.fadeAlpha(by: 0.0, duration: 0.25))
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if isGameEnded { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSound {playSwooshSound()}
        
        let ns = nodes(at:location)
        for node in ns {
            
            if node.name == "Code" {
                createEmitter("SliceGood", pos: node.position, node: self)
                node.name = nil
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let groupAct = SKAction.group([scaleOut, fadeOut])
                let sequence = SKAction.sequence([groupAct, .removeFromParent()])
                node.run(sequence)
                
                score += 1
                removeSprite(node, nodes: &activeSprites)
                run(swordSound)
                
            } else if node.name == "Bonus" {
                createEmitter("SliceGood", pos: node.position, node: self)
                node.name = nil
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let groupAct = SKAction.group([scaleOut, fadeOut])
                let sequence = SKAction.sequence([groupAct, .removeFromParent()])
                node.run(sequence)
                
                score += 50
                removeSprite(node, nodes: &activeSprites)
                run(wowSound)
            } else if node.name == "Icon" {
                createEmitter("SliceGood", pos: node.position, node: self)
                node.name = nil
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let groupAct = SKAction.group([scaleOut, fadeOut])
                let sequence = SKAction.sequence([groupAct, .removeFromParent()])
                node.run(sequence)
                
                score += 25
                removeSprite(node, nodes: &activeSprites)
                run(bruhSound)
            }
            else if node.name == "Bomb"{
                createEmitter("SliceBad", pos: node.parent!.position, node: self)
                node.name = nil
                node.parent!.physicsBody?.isDynamic = false
                let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let groupAct = SKAction.group([scaleOut, fadeOut])
                let sequence = SKAction.sequence([groupAct, .removeFromParent()])
                node.parent!.run(sequence)
                
                removeSprite(node.parent!, nodes: &activeSprites)
                run(backSound)
                //                run(creditSound)
                setupGameOver(true)
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval){
        var bombCount = 0
        for node in activeSprites {
            if node.name == "Bomb" {
                bombCount += 1
                break
            }
        }
        if bombCount == 0 {
            SKTAudio.sharedInstance.stopSoundEffect()
        }
        if activeSprites.count > 0{
            
            activeSprites.forEach({
                let height = $0.frame.height
                let value = frame.minY - height
                
                if $0.position.y < value {
                    $0.removeAllActions()
                    
                    if $0.name == "BombContainer"{
                        $0.name = nil
                        $0.removeFromParent()
                        removeSprite($0, nodes: &activeSprites)
                    } else if $0.name == "Code" {
                        subtractLives()
                        $0.name = nil
                        $0.removeFromParent()
                        removeSprite($0, nodes: &activeSprites)
                    } else if $0.name == "Bonus" {
                        //subtractLives()
                        $0.name = nil
                        $0.removeFromParent()
                        removeSprite($0, nodes: &activeSprites)
                    } else if $0.name == "Icon" {
                        //subtractLives()
                        $0.name = nil
                        $0.removeFromParent()
                        removeSprite($0, nodes: &activeSprites)
                    }
                }
                
            })
            
        } else {
            if !isNextSequenceQueued{
                run(.wait(forDuration: popupTime)){
                    self.tossHandler()
                }
                isNextSequenceQueued = true
            }
        }
        
        
    }
}
//configures
extension GameScene{
    func setupNodes(){
        createBG()
        setupPhysics()
        setUpSequenceType()
        
        createSlice()
        createScore()
        //        drawPlayableArea()
        createLives()
        setupOverlays()
        guard !isGameEnded else { return }
        run(.wait(forDuration: 1.5)){
            self.tossHandler()
        }
    }
    
    func drawPlayableArea(){
        let shape = SKShapeNode(rect: playableRect)
        shape.lineWidth = 5.0
        shape.strokeColor = .red
        shape.fillColor = .clear
        
        
        addChild(shape)
    }
    
    
    func setupPhysics(){
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.speed = 0.85
    }
    
    func setupOverlays(){
        gameOverOverlay = GameOverOverlay(gameScene: self, size: size)
        gameOverOverlay.zPosition = 99999
        addChild(gameOverOverlay)
        guard isReload else { return }
        gameOverOverlay.setups(true)
        gameOverOverlay.showPlay()
        
    }
}
//background
extension GameScene{
    func createBG(){
        let bg = SKSpriteNode(imageNamed: "background")
        bg.size = CGSize(width: frame.width, height: frame.height+20.0/2)
        bg.position = CGPoint(x: frame.width/2, y: frame.height/2)
        bg.zPosition = -1.0
        addChild(bg)
    }
}
extension GameScene{
    func tossHandler(){
        
        if isGameEnded { return }
        popupTime *= 0.991
        delay *= 0.99
        physicsWorld.speed *= 1.01
        
        
        let sequence = sequenceType[sequencePos]
        switch sequence {
        case .OneNoBomb:
            createSprite(.Never)
        case .One:
            createSprite()
        case .TwoWithOneBomb:
            createSprite(.Never)
            createSprite(.Always)
        case .Two:
            createSprite()
            createSprite()
        case .Three:
            createSprite()
            createSprite()
            createSprite()
        case .Four:
            createSprite()
            createSprite()
            createSprite()
            createSprite()
        case .Five:
            createSprite()
            run(.wait(forDuration: delay/5)) { self.createSprite() }
            run(.wait(forDuration: delay/5)) { self.createSprite() }
            run(.wait(forDuration: delay/5*2)) { self.createSprite() }
            run(.wait(forDuration: delay/5*3)) { self.createSprite() }
        case .Six:
            createSprite()
            run(.wait(forDuration: delay/10)){self.createSprite()}
            run(.wait(forDuration: delay/10)){self.createSprite()}
            run(.wait(forDuration: delay/10)){self.createSprite()}
            run(.wait(forDuration: delay/10*2)){self.createSprite()}
        }
        //       createSprite()
        sequencePos += 1
        isNextSequenceQueued = false
    }
    
    
    
    
    func createSprite(_ forceBomb: ForceBomb = .Defaults, _ spawnType: SpawnType = .None){
        var sprite = SKSpriteNode()
        var i = Int.random(min: 1, max: 9)
        var bombType = Int.random(min: 1, max: 6)
        var spawning = Int.random(min: 1, max: 5)
        if forceBomb == .Never{
            bombType = 1
        } else if forceBomb == .Always{
            bombType = 0
        }
        
        if bombType == 0 {
            sprite = SKSpriteNode()
            sprite.zPosition = 1.0
            sprite.setScale(1.5)
            sprite.name = "BombContainer"
            let bomb = SKSpriteNode(imageNamed: "bomb")
            bomb.name = "Bomb"
            sprite.addChild(bomb)
            
            SKTAudio.sharedInstance.stopSoundEffect()
            //            SKTAudio.sharedInstance.playBGMusic(SoundType.sliceBombFuse.rawValue)
            
            //            let pos = CGPoint(x: bomb.frame.midX+35, y: bomb.frame.maxY+5)
            //            createEmitter("SliceFuse", pos: pos, node: sprite)
            //
        } else {
            if spawnType == .SpawnOne {
                spawning = 1
            } else if spawnType == .SpawnTwo {
                spawning = 2
            } else if spawnType == .SpawnThree {
                spawning = 3
            } else if spawnType == .SpawnBonus {
                spawning = 4
            } else if spawnType == .SpawnIcon {
                spawning = 5
            }
            if spawning == 1 {
                sprite = SKSpriteNode(imageNamed: "var")
                sprite.setScale(1.5)
                sprite.name = "Code"
                run(launchSound)
            }
            else if spawning == 2 {
                sprite = SKSpriteNode(imageNamed: "let")
                sprite.setScale(1.5)
                sprite.name = "Code"
                run(launchSound)
            }
            else if spawning == 3 {
                sprite = SKSpriteNode(imageNamed: "if")
                sprite.setScale(1.5)
                sprite.name = "Code"
                run(launchSound)
            }
            else if spawning == 4 {
                sprite = SKSpriteNode(imageNamed: "mango")
                sprite.setScale(1.5)
                sprite.name = "Bonus"
                run(launchSound)
            }
            else if spawning == 5 {
                switch i {
                case 1 :
                    sprite = SKSpriteNode(imageNamed: "iconaCodeNinja")
                    sprite.setScale(2)
                    sprite.name = "Icon"
                    run(launchSound)
                    
                case 2:
                    sprite = SKSpriteNode(imageNamed: "iconaWillPower")
                    sprite.setScale(0.20)
                    sprite.name = "Icon"
                    run(launchSound)
                    
                case 3 :
                    sprite = SKSpriteNode(imageNamed: "cat")
                    sprite.setScale(0.20)
                    sprite.name = "Icon"
                    run(launchSound)
                    
                case 4 :
                    sprite = SKSpriteNode(imageNamed: "cosplanning")
                    sprite.setScale(0.20)
                    sprite.name = "Icon"
                    run(launchSound)
                    
                case 5:
                    sprite = SKSpriteNode(imageNamed: "fugu")
                    sprite.setScale(0.20)
                    sprite.name = "Icon"
                    run(launchSound)
                    
                case 6 :
                    sprite = SKSpriteNode(imageNamed: "unveil")
                    sprite.setScale(0.20)
                    sprite.name = "Icon"
                    run(launchSound)
                    
                case 7:
                    sprite = SKSpriteNode(imageNamed: "requiem")
                    sprite.setScale(0.20)
                    sprite.name = "Icon"
                    run(launchSound)
                    
                case 8:
                    sprite = SKSpriteNode(imageNamed: "space")
                    sprite.setScale(0.20)
                    sprite.name = "Icon"
                    run(launchSound)
                    
                case 9:
                    sprite = SKSpriteNode(imageNamed: "fist")
                    sprite.setScale(0.20)
                    sprite.name = "Icon"
                    run(launchSound)
                    
                default :
                    sprite = SKSpriteNode(imageNamed: "mango")
                    sprite.setScale(1.5)
                    sprite.name = "Bonus"
                    run(launchSound)
                }
            }
        }
        let spriteW = sprite.frame.width
        let xRandom = CGFloat.random(min: frame.minX + spriteW, max: frame.maxX - spriteW)
        let pos = CGPoint(x: xRandom/2, y: frame.midY)
        let angularVelocity = CGFloat.random(min: -8.0, max: 8.0)/2
        let yVelocity = Int.random(min: 10, max: 20)
        let xVelocity: Int
        let value = frame.minX + 256
        
        if pos.x < value{
            xVelocity = Int.random(min: 4, max: 30)
            
        } else if pos.x < value*2{
            xVelocity = Int.random(min: 2, max: 8)
        } else if pos.x < frame.maxX{
            xVelocity = Int.random(min: 2, max: 8)
        } else {
            xVelocity = Int.random(min: 4, max: 20)
        }
        sprite.position = pos
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 60.0)
        sprite.physicsBody?.angularVelocity = angularVelocity
        sprite.physicsBody?.velocity = CGVector(dx: CGFloat(xVelocity*40), dy: CGFloat(yVelocity*40))
        sprite.physicsBody?.collisionBitMask = 0
        addChild(sprite)
        
        
        activeSprites.append(sprite)
    }
    func removeSprite(_ node: SKNode, nodes: inout [SKNode]){
        if let index =  nodes.firstIndex(of: node){
            nodes.remove(at: index)
        }
    }
}

//sequence type
extension GameScene {
    func setUpSequenceType() {
        sequenceType = [.OneNoBomb, .One, .TwoWithOneBomb, .Two, .Three, .Four, .Five, .Six]
        for _ in 0...100 {
            let sequence = SequenceType(rawValue: Int.random(min: 1, max: 7))!
            sequenceType.append(sequence)
        }
    }
}
//slice
extension GameScene{
    func createSlice(){
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2.0
        activeSliceBG.lineWidth = 9.0
        activeSliceBG.strokeColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2.0
        activeSliceFG.lineWidth = 5.0
        activeSliceFG.strokeColor = .white
        
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    func redrawActiveSlice(){
        if activeSlicePoints.count < 2{
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        while activeSlicePoints.count > 12{
            activeSlicePoints.remove(at: 0)
            
        }
        let bezierPath = UIBezierPath()
        bezierPath.move(to: activeSlicePoints[0])
        
        for i in 0..<activeSlicePoints.count{
            bezierPath.addLine(to: activeSlicePoints[i])
            
        }
        activeSliceBG.path = bezierPath.cgPath
        activeSliceFG.path = bezierPath.cgPath
        
    }
    
    func playSwooshSound() {
        isSwooshSound = true
        let soundAct = swooshSounds[Int.random(min: 0, max: 2)]
        
        run(soundAct) {
            self.isSwooshSound = false
        }
    }
    
    
}

//score

extension GameScene{
    func createScore(){
        let width: CGFloat = 250.0
        let height: CGFloat = 100.0
        let yPos = appDl.Iphone ? frame.maxY - height - 20: playableRect.maxY - height - 20
        let shapeRect = CGRect(x: frame.midX - width/2, y: yPos, width: width, height: height)
        let shape = SKShapeNode(rect: shapeRect, cornerRadius: 8.0)
        shape.strokeColor = .clear
        shape.fillColor = UIColor.black.withAlphaComponent(0.5)
        shape.zPosition = 5.0
        addChild(shape)
        
        scoreLbl = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        scoreLbl.text = "0"
        scoreLbl.zPosition = 5.0
        scoreLbl.fontSize = 80.0
        scoreLbl.verticalAlignmentMode = .center
        scoreLbl.horizontalAlignmentMode = .center
        scoreLbl.position = CGPoint(x: shape.frame.midX, y: shape.frame.midY)
        
        shape.addChild(scoreLbl)
    }
}
//life
extension GameScene{
    func createLives(){
        for i in 0..<3{
            let sprite = SKSpriteNode(imageNamed: "life")
            sprite.size = CGSize(width: frame.midX/12, height: frame.midY/10)
            sprite.setScale(1.5)
            let spriteW = sprite.frame.width
            let spriteH = sprite.frame.height
            let yPos = appDl.Ipad ? frame.maxY - spriteH : playableRect.maxY - spriteH
            
            sprite.position = CGPoint(x: CGFloat(i)*spriteW+90, y: yPos+30)
            addChild(sprite)
            livesNode.append(sprite)
        }
    }
    func subtractLives(){
        lives -= 1
        let sprite: SKSpriteNode
        if lives == 2 {
            sprite = livesNode[0]
        }
        else if lives == 1 {
            sprite = livesNode[1]
        }
        else {
            sprite = livesNode[2]
            setupGameOver(false)
        }
        sprite.texture = SKTexture(imageNamed: "lifegone")
        sprite.xScale = 1.5*1.3
        sprite.yScale = 1.5*1.3
        sprite.run(.scale(to: 1.5, duration: 0.1))
    }
}

//Gameover

extension GameScene{
    func setupGameOver(_ isGameOver: Bool){
        gameOverOverlay.setups()
        gameOverOverlay.showGameOver("GAME OVER!")
        if isGameEnded { return }
        isGameEnded = true
        
        physicsWorld.speed = 0.0
        isUserInteractionEnabled = false
        run(backSound)
        //        run(creditSound)
        if isGameOver{
            let texture = SKTexture(imageNamed: "lifegone")
            livesNode[0].texture = texture
            livesNode[1].texture = texture
            livesNode[2].texture = texture
        }
    }
    
    func presentScene() {
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        scene.isReload = false
        scene.isGameEnded = false
        view!.presentScene(scene, transition: .fade(withDuration: 1.0))
        
        
    }
    
}
//SKEmitter Node
extension GameScene{
    func createEmitter(_ fn: String, pos: CGPoint, node: SKNode){
        let emitter = SKEmitterNode(fileNamed: fn)!
        emitter.position = pos
        node.addChild(emitter)
        
    }
}
