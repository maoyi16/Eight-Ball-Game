//
//  MenuScene.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 2/12/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuScene: SKScene {
    
    var pvpLabel: SKLabelNode!
    var pveLabel: SKLabelNode!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
        
        if let location = touches.first?.location(in: self) {
            let touchedNode = atPoint(location)
            
            if touchedNode.name == "PVP" || touchedNode.name == "PVE" || touchedNode.name == "EVE" {
                
                // MARK: Go to PoolScene
                // Load 'PoolScene.sks' as a GKScene. This provides gameplay related content
                // including entities and graphs.
                if let scene = GKScene(fileNamed: "PoolScene") {
                    
                    // Get the SKScene from the loaded GKScene
                    if let sceneNode = scene.rootNode as! PoolScene? {
                        sceneNode.mode = touchedNode.name == "PVP" ? .PVP : touchedNode.name == "PVE" ? .PVE : .EVE
                        // Set the scale mode to scale to fit the window
                        sceneNode.scaleMode = .aspectFill
                        
                        // Present the scene
                        if let view = self.view {
                            let transition = SKTransition.reveal(with: .down, duration: 1.0)
                            view.presentScene(sceneNode, transition: transition)
//                            view.ignoresSiblingOrder = true
                            view.showsFPS = false
                            view.showsPhysics = false
                            view.showsNodeCount = false
                        }
                    }
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
        pveLabel = childNode(withName: "PVP") as! SKLabelNode!
        
    }
}
