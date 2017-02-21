//
//  Player.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 2/12/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import GameplayKit

class Player: NSObject, NSCopying, GKGameModelPlayer {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Player(id: self.id, isAI: self.isAI)
        copy.state = self.state
        copy.points = self.points
        return copy
    }
    
    enum PlayerSate {
        case Break
        case Normal
        case EightBall
    }
    enum ID:Int {
        case First
        case Second
        
        var name:String {
            switch self {
            case .First:
                return "Player1"
            case .Second:
                return "Player2"
            }
        }
    }
    
    let id: ID
    var playerId: Int
    override var description: String {
        return id.name
    }
    var state: PlayerSate
    
    var ballColor:BallColor? = nil
    var points = 0
    var canPocketEightBall: Bool {
        return points == 7
    }
    
    let isAI:Bool
    
    var opponent: Player!
    
    func incPoints() {
        points += 1
        if points == 1 {
            state = .Normal
        }
        if points == 7 {
            state = .EightBall
        }
    }
    
    init(id: ID, isAI: Bool) {
        self.id = id
        self.isAI = isAI
        playerId = id.rawValue
        state = .Break
    }
}
