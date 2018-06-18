//
//  EndScene.swift
//  Cell Gen
//
//  Created by prabhjot singh on 03/05/2018.
//  Copyright © 2018 prabhjot singh. All rights reserved.
//

import Foundation
import SpriteKit

class EndScene: SKScene,SKPhysicsContactDelegate{
    
    let restartLabel = SKLabelNode(fontNamed: "theboldfont")

    override func didMove(to view: SKView) {
        print("-----ES size: ",self.size)
        let sceneCentreX = self.size.width/2
        let sceneCentreY = self.size.height/2
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size;
        background.position = CGPoint(x: sceneCentreX, y: sceneCentreY);
        background.zPosition = 0;
        self.addChild(background)
        let gameOverLabel = SKLabelNode(fontNamed: "theboldfont")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 60
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: sceneCentreX , y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let finalScore = SKLabelNode(fontNamed: "theboldfont")
        finalScore.text = "Final Score: \(score)"
        finalScore.fontSize = 20
        finalScore.fontColor = SKColor.white
        finalScore.position = CGPoint(x: sceneCentreX, y: self.size.height*0.55)
        finalScore.zPosition = 1
        self.addChild(finalScore)
        
        let defaults = UserDefaults()
        var highScore = defaults.integer(forKey: "highScore")
        if (score > highScore){
            highScore = score
            defaults.set(highScore,forKey: "highScore")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "theboldfont")
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.fontSize = 16
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: sceneCentreX, y: self.size.height*0.40)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        let restartLabel = SKLabelNode(fontNamed: "theboldfont")
        restartLabel.text = "RESTART"
        restartLabel.name = "restartLabel"
        restartLabel.position = CGPoint(x: sceneCentreX, y: self.size.height*0.30)
        restartLabel.fontSize = 20
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let touchPoint = touch.location(in:self)
            self.enumerateChildNodes(withName: "restartLabel"){
                label , stop in
                if(label.contains(touchPoint)){
                    if let view = self.view {
                        if let scene = SKScene(fileNamed: "GameScene") {
                            scene.scaleMode = .aspectFill
                            view.presentScene(scene)
                        }
                        view.ignoresSiblingOrder = true
                        view.showsFPS = true
                        view.showsNodeCount = true
                    }
                }
            }
        }
        
    }
}
