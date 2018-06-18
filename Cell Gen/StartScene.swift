//
//  StartScene.swift
//  Cell Gen
//
//  Created by prabhjot singh on 04/05/2018.
//  Copyright © 2018 prabhjot singh. All rights reserved.
//

import Foundation
import SpriteKit

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        print("-----ES size: ",self.size)
        let sceneCentreX = self.size.width/2
        let sceneCentreY = self.size.height/2
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size;
        background.position = CGPoint(x: sceneCentreX, y: sceneCentreY);
        background.zPosition = 0;
        self.addChild(background)
        let gameTitle = SKLabelNode(fontNamed: "theboldfont")
        gameTitle.text = "Cell Gen Game"
        gameTitle.fontSize = 60
        gameTitle.fontColor = SKColor.white
        gameTitle.position = CGPoint(x: sceneCentreX , y: self.size.height*0.7)
        gameTitle.zPosition = 1
        self.addChild(gameTitle)
        
        let startLabel = SKLabelNode(fontNamed: "theboldfont")
        startLabel.text = "Start"
        startLabel.fontSize = 25
        startLabel.name = "startLabel"
        startLabel.fontColor = SKColor.white
        startLabel.position = CGPoint(x: sceneCentreX, y: self.size.height*0.40)
        startLabel.zPosition = 1
        self.addChild(startLabel)
        
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
        highScoreLabel.position = CGPoint(x: sceneCentreX, y: self.size.height*0.55)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        let instructionLabel = SKLabelNode(fontNamed: "theboldfont")
        instructionLabel.text = "Hint: Move phone to navigate and collect as many cell as possible"
        instructionLabel.position = CGPoint(x: sceneCentreX, y: self.size.height*0.20)
        instructionLabel.fontSize = 12
        instructionLabel.fontColor = SKColor.white
        instructionLabel.zPosition = 1
        self.addChild(instructionLabel)

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let touchPoint = touch.location(in:self)
            self.enumerateChildNodes(withName: "startLabel"){
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
