//
//  Cue.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 1/23/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import Foundation
import SpriteKit

class Cue {
    static let minTipToCenter:CGFloat = -10
    static let impluseFactor:CGFloat = 3
    let node: SKSpriteNode
    let ball: Ball
    var tipToCenter:CGFloat = minTipToCenter
    var angle:CGFloat
    var isStable = true
    
    func translate(translation: CGFloat) {
        if !translation.isZero {
            let newTipToCenter = tipToCenter + translation
            if newTipToCenter <= Cue.minTipToCenter {
                tipToCenter = newTipToCenter
                node.run(SKAction.moveTo(x: newTipToCenter, duration: 0))
            }
        }
    }
    
    func strike() {
        if (tipToCenter < Cue.minTipToCenter) {
            let impluse = CGVector(dx: Cue.impluseFactor * tipToCenter * cos(angle), dy: Cue.impluseFactor * tipToCenter * sin(angle))
            isStable = false
            node.run(SKAction.moveTo(x: Cue.minTipToCenter, duration: 0.1), completion: {
                if let ball = self.ball as? FakeBall {
                    ball.velocity = impluse
                } else {
                    self.ball.node.physicsBody?.applyImpulse(impluse)
                }
                self.node.isHidden = true
                self.isStable = true
            })
        }
    }
    
    func show() {
        if node.isHidden {
            tipToCenter = Cue.minTipToCenter
            node.position = CGPoint(x: tipToCenter, y: 0)
            node.isHidden = false
        }
    }
    
    func canStrike() -> Bool {
        return !node.isHidden
    }
    
    func restore() {
        print("Restore")
        node.run(SKAction.moveTo(x: Cue.minTipToCenter, duration: 0.1), completion: {
            self.tipToCenter = Cue.minTipToCenter
            //            print(self.node.position)
        })
    }
    
    init(center: Ball, onRack: Bool) {
        self.ball = center
        node = SKSpriteNode(texture: SKTexture(imageNamed: "CueStick"), size: CGSize(width: 300, height: 30))
        ball.node.addChild(node)
        if onRack {
            self.ball.node.zRotation = CGFloat (M_PI / 2)
        }
        node.anchorPoint.x = 1
        node.zPosition = onRack ? 10 : 1
        angle = CGFloat(M_PI)
        node.position = CGPoint(x: tipToCenter, y: 0)
    }
    
    var centerPosition:CGPoint {
        return ball.position
    }
    
    func rotateTranslateThanStrike(impluse: CGVector) {
        let impluseAngle = atan2(impluse.dy, impluse.dx)
        //        print("oldAngle: \(angle)")
        //        print("impluseAngle: \(impluseAngle)")
        let rotateAngle = convertAngle(angle: impluseAngle - convertAngle(angle: angle.subtracting(CGFloat(M_PI))))
        //        print("rotateAngle: \(rotateAngle)")
        let translation = -length(vector: impluse) * 0.1
        let newTipToCenter = tipToCenter + translation
        print(0)
        if newTipToCenter <= Cue.minTipToCenter {
            isStable = false
            PoolScene.gameNeedsUpdate = true
            ball.node.run(SKAction.rotate(byAngle: rotateAngle, duration: 1), completion:{
                self.angle = convertAngle(angle: self.angle + rotateAngle)
                //                print("newAngle: \(self.angle)")
                self.node.run(SKAction.sequence(
                    [
                        SKAction.moveTo(x: newTipToCenter, duration: 1),
                        SKAction.moveTo(x: Cue.minTipToCenter, duration: 0.1),
                        ]),
                              completion: {
                                
                                let v = CGVector(
                                    dx:
                                    GameConstants.AIStrength * impluse.dx,
                                    dy:
                                    GameConstants.AIStrength * impluse.dy
                                )
                                
                                if let b = self.ball as? FakeBall {
                                    b.velocity = v
                                } else {
                                    self.ball.node.physicsBody?.applyImpulse(v)
                                }
                                self.node.isHidden = true
                                self.isStable = true
                })
            })
        }
    }
}
