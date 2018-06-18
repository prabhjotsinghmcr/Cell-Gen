//
//  GameScene.swift
//  Cell Gen
//
//  Created by prabhjot singh on 03/05/2018.
//  Copyright © 2018 prabhjot singh. All rights reserved.
//

import SpriteKit
import CoreMotion

var score = 0

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var motionManager = CMMotionManager()
    var destX: CGFloat = 0.0
    var destY: CGFloat = 0.0
    var playerFrames:[SKTexture]?
    var timer = Timer()
    var secondsLeft = 60
    var isTimerRunning = false
    var movingRight = true
    var player:SKSpriteNode
    let backgroundMusic = SKAudioNode(fileNamed: "backgroundMusic.wav");
    var CurrentGameState = GameState.preRun;
    let screenWidth :CGFloat = 300;
    let screenHeight :CGFloat = 130;
    var gameArea: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0  )
    let colSound = SKAction.playSoundFileNamed("colSound.wav", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("gameOver.wav", waitForCompletion: false)
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let RedBloodCell : UInt32 = 0b10 //2
        static let WhiteBloodCell : UInt32 = 0b100 //4
        static let NerveCell : UInt32 = 0b111 //7
        static let Virus : UInt32 = 0b1010 //10
    }

   override init(size: CGSize) {
    let sceneWidth = size.height;
    gameArea = CGRect(x: 0, y: 0, width: sceneWidth, height: size.height);
    var playerFramesLocal:[SKTexture] = []
    let playerAtlas = SKTextureAtlas(named: "player")
    for index in 1 ... 10{
        let textureName = "pr\(index)"
        let texture = playerAtlas.textureNamed(textureName)
        playerFramesLocal.append(texture)
    }
    self.playerFrames = playerFramesLocal
    self.player = SKSpriteNode(texture: playerFrames![0])
    super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
    var playerFramesLocal:[SKTexture] = []
        let playerAtlas = SKTextureAtlas(named: "player")
        for index in 1 ... 10{
            let textureName = "pr\(index)"
            let texture = playerAtlas.textureNamed(textureName)
            playerFramesLocal.append(texture)
        }
        self.playerFrames = playerFramesLocal
    self.player = SKSpriteNode(texture: playerFrames![0])
    super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        score = 0;
        self.physicsWorld.contactDelegate = self
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size;
        background.position = CGPoint(x: 0, y: 0);
        background.zPosition = 0;
        self.addChild(background);
        self.addChild(backgroundMusic);
        addPlayer()
        addScoreLabel()
        CurrentGameState = GameState.inRun
        addTimer();
        addCells();
        addMotionSensor()
        
    }
    
    fileprivate func addMotionSensor() {
        if motionManager.isAccelerometerAvailable == true {
            // 2
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{
                data, error in
                if(data!.acceleration.y > 0.0){
                    self.movingRight = true
                }
                else{
                    self.movingRight = false
                }
                self.destY = self.player.position.x + CGFloat(data!.acceleration.x * 500)
                self.destX = self.player.position.y + CGFloat(data!.acceleration.y * 500)
                
            })
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let maxX = screenWidth - player.size.width/2
        let maxY = screenHeight
        if (destY > maxY ) {
            destY = screenHeight - player.size.height/2
        }
        if destY <  -maxY  {
            destY = -screenHeight + player.size.height/2
        }
        if destX > maxX{
            destX = screenWidth - player.size.width/2
        }
        if destX < -maxX{
            destX = -screenWidth + player.size.width/2
        }
        let move = SKAction.move(to: CGPoint(x: destX, y: -destY), duration: 0.5)
        if (self.movingRight){
            self.player.xScale = 0.15
        }
        else{
            self.player.xScale = -0.15
        }
        self.player.run(move)
       
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == PhysicsCategories.RedBloodCell {
            //player and RBC
            self.run(colSound)
            contact.bodyA.node?.removeFromParent()
            updateScore(point: 10)
        }
        else if(contact.bodyB.categoryBitMask == PhysicsCategories.RedBloodCell){
            self.run(colSound)
            contact.bodyB.node?.removeFromParent()
            updateScore(point: 10)
        }
        else if(contact.bodyB.categoryBitMask == PhysicsCategories.Virus || contact.bodyA.categoryBitMask == PhysicsCategories.Virus){
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            if(CurrentGameState == GameState.inRun){
                let touchPoint = touch.location(in: self)
                let previousTouchPoint = touch.previousLocation(in: self)
                let moveInPositionX = touchPoint.x - previousTouchPoint.x
                let moveInPositionY = touchPoint.y - previousTouchPoint.y
                player.position.x += moveInPositionX
                player.position.y += moveInPositionY
                if (player.position.x > screenWidth - player.size.height/2 ) {
                    player.position.x = screenWidth - player.size.height/2
                }
                if player.position.x <  (-screenWidth)  - player.size.height/2  {
                    player.position.x = -screenWidth + player.size.height/2
                }
                if player.position.y > screenHeight - player.size.height/2{
                    player.position.y = screenHeight - player.size.height/2
                }
                if player.position.y < -screenHeight - player.size.height/2{
                    player.position.y = -screenHeight + player.size.height/2
                }
            }
            
        }
    }
    
    
    func addScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "theboldfont")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20;
        scoreLabel.fontColor = SKColor.white;
        scoreLabel.verticalAlignmentMode = .top
        let x = -((self.size.width/2) - 70);
        let y = ((self.size.height/2));
        scoreLabel.position = CGPoint(x: x , y: y);
        scoreLabel.zPosition = 50;
        self.addChild(scoreLabel);
    }
    
    fileprivate func addPlayer() {
        player.run(SKAction.repeatForever(SKAction.animate(with: self.playerFrames!, timePerFrame: 0.05, resize: false, restore: true)))
        player.setScale(0.15)
        player.position = CGPoint(x: 4, y: self.size.height * 0.2);
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.NerveCell | PhysicsCategories.RedBloodCell | PhysicsCategories.WhiteBloodCell | PhysicsCategories.Virus
        self.addChild(player)
    }
    
    func gameOver() {
        CurrentGameState = GameState.postRun;
        backgroundMusic.run(SKAction.stop())
        scoreLabel.removeAllActions()
        self.removeAllActions();
        self.enumerateChildNodes(withName: "cell"){
            cell, stop in
            cell.removeAllActions()
        }
        let switchSceneAction = SKAction.run(switchScene)
        let sceneSwitchDelay = SKAction.wait(forDuration: 1)
        let sceneSwitchSeq = SKAction.sequence([sceneSwitchDelay,switchSceneAction])
        self.run(gameOverSound)
        self.run(sceneSwitchSeq)
    }
    
    func switchScene(){
        let newScene = EndScene(size: self.size)
        newScene.scaleMode = .aspectFill
        let sceneSwitchTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(newScene,transition:sceneSwitchTransition)
    }
    
    func addTimer() {
        let timerX = self.size.width/2 - 70
        let y = ((self.size.height/2));
        timerLabel = SKLabelNode(fontNamed: "theboldfont")
        timerLabel.text = "Time Left: 60";
        timerLabel.fontSize = 20;
        timerLabel.fontColor = SKColor.white
        timerLabel.verticalAlignmentMode = .top
        timerLabel.position = CGPoint(x: timerX , y: y)
        timerLabel.zPosition = 50
        self.addChild(timerLabel)
        runTimer();
    }
    
    func runTimer(){
        let actionwait = SKAction.wait(forDuration:1)
        let actionrun = SKAction.run({
            self.secondsLeft -= 1;
            if( self.secondsLeft <= 0 ){
                self.gameOver();
            }
            self.timerLabel.text = "Time Left:\(self.secondsLeft)"
        })
        scoreLabel.run(SKAction.repeatForever(SKAction.sequence([actionwait,actionrun])))
    }
    
    
    func updateScore(point: Int){
        score += point;
        scoreLabel.text = "Score: \(score)";
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSeq = SKAction.sequence([scaleUp,scaleDown])
        scoreLabel.run(scaleSeq)
    }
    

    
    func addCells() {
        let generateNew = SKAction.run(generateCell)
        let wait = SKAction.wait(forDuration: 1)
        let generationSeq = SKAction.sequence([generateNew,wait])
        let cellGenerationLoop = SKAction.repeatForever(generationSeq)
        self.run(cellGenerationLoop)
    }
    
    func generateCell(){
        let randomStartX = random(min: -screenWidth, max: screenWidth)
        let randomStartY = random(min: -screenHeight, max: screenHeight)
        let finishX : CGFloat;
        let rightToLeft = arc4random() % 2 == 0
        if(rightToLeft){
            finishX = -screenWidth
        }
        else{
            finishX = screenWidth
        }
        let startPoint = CGPoint(x: randomStartX, y: randomStartY)
        let endPoint = CGPoint(x: finishX, y: randomStartY)
        let randomCell = arc4random_uniform(3)+1
        
        addCell(String(randomCell), startPoint, rightToLeft, endPoint)
    }
    
    fileprivate func addCell(_ randomCellNumber: String, _ startPoint: CGPoint, _ rightToLeft: Bool, _ endPoint: CGPoint) {
        var cellFrameM:[SKTexture]?
        var cellFrames:[SKTexture] = []
        let cellAtlas = SKTextureAtlas(named: "cell\(randomCellNumber)")
        for index in 1 ... 11{
            let textureName = "p\(randomCellNumber)_walk\(index)"
            let texture = cellAtlas.textureNamed(textureName)
            cellFrames.append(texture)
        }
        cellFrameM = cellFrames
        let texture = cellFrameM![0]
        
        let bloodCell = SKSpriteNode(texture: texture)
        
        bloodCell.run(SKAction.repeatForever(SKAction.animate(with: cellFrameM!, timePerFrame: 0.05, resize: false, restore: true)))
        bloodCell.name = "cell"
        bloodCell.position = startPoint
        bloodCell.setScale(0.5)
        bloodCell.zPosition = 2;
        bloodCell.physicsBody = SKPhysicsBody(rectangleOf: bloodCell.size)
        bloodCell.physicsBody!.affectedByGravity = false
        bloodCell.physicsBody!.categoryBitMask = PhysicsCategories.RedBloodCell
        bloodCell.physicsBody!.collisionBitMask = PhysicsCategories.None
        bloodCell.physicsBody!.contactTestBitMask = PhysicsCategories.Player
        if(rightToLeft){
            bloodCell.xScale = -0.5
        }
        else{
            bloodCell.xScale = 0.5
        }
        self.addChild(bloodCell);
        
        let moveCell = SKAction.move(to: endPoint, duration: 3)
        let deleteCell = SKAction.removeFromParent()
        let cellSequence = SKAction.sequence([moveCell,deleteCell])
        bloodCell.run(cellSequence)
    }
    
   
    func random() -> CGFloat {
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    func random(min:CGFloat,max: CGFloat) -> CGFloat  {
        return random() * (max - min) + min
    }

}
