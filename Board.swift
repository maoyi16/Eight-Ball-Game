//
//  Board.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 2/19/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import Foundation
import GameplayKit

class Board:NSObject {
    
    enum Difficulty {
        case Easy
        case Medium
        case Hard
    }
    var currentPlayer: Player!
    var cueBall: Ball!
    var remainingBalls = [Ball]()
    var pocketedBalls = [Ball]()
    let difficulty:Difficulty
    static var pockets = [Pocket]()
    static let boardLeft:CGFloat = -215
    static let boardRight:CGFloat = 214.5
    static let boardTop:CGFloat = 68
    static let boardBottom:CGFloat = -157
    
    init(difficulty:Difficulty) {
        self.difficulty = difficulty
    }
    override var description: String {
        return "currentPayer: \(currentPlayer)\n cueBall: \(cueBall)\n remainingBalls: \(remainingBalls)\n"
    }
    
    func resetPockedBalls() {
        pocketedBalls.removeAll()
    }
    
    func checkPockets() {
        for pocket in Board.pockets {
            for ball in remainingBalls {
                let distance = sqrt(pow(ball.position.x - pocket.posX, 2) + pow(ball.position.y - pocket.posY, 2))
                if (distance < pocket.radius) {
                    //                    print("\(ball) is Pocketed")
                    ball.node?.removeFromParent()
                    if let b = ball as? FakeBall {
                        b.velocity = CGVector(dx: 0, dy: 0)
                    }
                    pocketedBalls.append(ball)
                    if let index = remainingBalls.index(where: {$0 === ball}) {
                        remainingBalls.remove(at: index)
                    }
                }
            }
        }
    }
    
    func isStable() -> Bool {
        for ball in remainingBalls {
            if !ball.isStable {
                return false
            }
        }
        return true
    }
    /**
     c^2 = a^2 + b^2 - 2ab*cos(theta)
     */
    func computeDistance(ball1:Ball, ball2:Ball, angle:CGFloat) -> CGFloat {
        let b = distance(p1: ball1.position, p2: ball2.position)
        let c = 2 * GameConstants.BallRadius
        let vector1 = CGVector(dx: cos(angle), dy: sin(angle))
        let vector2 = CGVector(dx: ball2.position.x - ball1.position.x, dy: ball2.position.y - ball1.position.y)
        let costheta = dotCGVector(v1: vector1, v2: vector2)
        return b * costheta - sqrt(pow(b * costheta,2) - pow(b,2) + pow(c,2))
    }
    
    func computeAngle(ball1: Ball, ball2: Ball) -> [(Int, distance:CGFloat)] {
        let x1 = ball1.position.x
        let y1 = ball1.position.y
        let x2 = ball2.position.x
        let y2 = ball2.position.y
        let r = GameConstants.BallRadius
        let dist = distance(p1: ball1.position, p2: ball2.position)
        var angles_distances = [(Int,CGFloat)]()
        if dist == 2 * r {
            let ang = angle(p1: CGPoint(x:x1,y:y1), p2: CGPoint(x:x2,y:y2))
            var ang1 = ang - CGFloat(M_PI_4)
            var ang2 = ang + CGFloat(M_PI_4)
            ang1 = convertAngle(angle: ang1)
            ang2 = convertAngle(angle: ang2)
            
            if ang2 < ang1 {
                let t = ang1
                ang1 = ang2
                ang2 = t
            }
            
            let  lower = lround(Double(GLKMathRadiansToDegrees(Float(ang1)))) + 1
            let  upper = lround(Double(GLKMathRadiansToDegrees(Float(ang2)))) - 1
            if lower <= upper {
                for a in lower...upper {
                    angles_distances.append((a,dist))
                }
                
            }
            
        } else {
            let sigma1 = sqrt(-4*pow(r,2) + pow(x1,2) - 2*x1*x2 + pow(x2,2) + pow(y1,2) - 2*y1*y2 + pow(y2,2))
            var sigma2 = (x1-x2) * (pow(x1,2) - 2*x1*x2 + pow(x2,2) + pow(y1,2) - 2*y1*y2 + pow(y2,2))
            var sigma3 = (4*pow(r,2) - pow(x2,2) + x1*x2 - pow(y2,2) + y1*y2) / (x1 - x2)
            var sigma4 = 2*y1*pow(y2,2)
            var sigma5 = 4*pow(r,2)*y2
            let sigma6 = 4*pow(r,2)*y1
            let xsol1 = sigma3 - ((y1-y2) * (sigma6 - sigma5 + pow(x1,2)*y2 + pow(x2,2)*y2 - sigma4 + pow(y1,2)*y2 + pow(y2,3) - 2*r*x1*sigma1 + 2*r*x2*sigma1 - 2*x1*x2*y2)) / sigma2
            let xsol2 = sigma3 - ((y1-y2) * (sigma6 - sigma5 + pow(x1,2)*y2 + pow(x2,2)*y2 - sigma4 + pow(y1,2)*y2 + pow(y2,3) + 2*r*x1*sigma1 - 2*r*x2*sigma1 - 2*x1*x2*y2)) / sigma2
            sigma2 = pow(x1,2) - 2*x1*x2 + pow(x2,2) + pow(y1,2) - 2*y1*y2 + pow(y2,2)
            sigma3 = 2*y1*pow(y2,2)
            sigma4 = 4*pow(r,2)*y2
            sigma5 = 4*pow(r,2)*y1
            let ysol1 = (sigma5 - sigma4 + pow(x1,2)*y2 + pow(x2,2)*y2 - sigma3 + pow(y1,2)*y2 + pow(y2,3) - 2*r*x1*sigma1 + 2*r*x2*sigma1 - 2*x1*x2*y2) / sigma2
            let ysol2 = (sigma5 - sigma4 + pow(x1,2)*y2 + pow(x2,2)*y2 - sigma3 + pow(y1,2)*y2 + pow(y2,3) + 2*r*x1*sigma1 - 2*r*x2*sigma1 - 2*x1*x2*y2) / sigma2
            var ang1 = angle(p1: CGPoint(x:x1,y:y1), p2: CGPoint(x:xsol1,y:ysol1))
            var ang2 = angle(p1: CGPoint(x:x1,y:y1), p2: CGPoint(x:xsol2,y:ysol2))
            
            if !ang1.isNaN && !ang2.isNaN {
                if ang2 < ang1 {
                    let t = ang1
                    ang1 = ang2
                    ang2 = t
                }
                
                let  lower = lround(Double(GLKMathRadiansToDegrees(Float(ang1)))) + 1
                let  upper = lround(Double(GLKMathRadiansToDegrees(Float(ang2)))) - 1
                if lower <= upper {
                    for a in lower...upper {
                        let d = computeDistance(ball1: ball1, ball2: ball2, angle: CGFloat(GLKMathDegreesToRadians(Float(a))))
                        if !d.isNaN {
                            angles_distances.append((a,d))
                        }
                    }
                }
            }
            
        }
        return angles_distances
    }
    
    
    func validAngles() -> [(angle:CGFloat, distance:CGFloat)] {
        var possibleValidAngles_distances = [(Int, distance:CGFloat)]()
        var invalidAngles_distances = [(Int, distance:CGFloat)]()
        for ball in remainingBalls {
            if ball !== cueBall {
                if currentPlayer.ballColor == nil && ball.color != .White && ball.color != .Black {
                    possibleValidAngles_distances.append(contentsOf: computeAngle(ball1: cueBall, ball2: ball))
                } else if ball.color == currentPlayer.ballColor || ball.color == .Black && currentPlayer.state == .EightBall {
                    possibleValidAngles_distances.append(contentsOf: computeAngle(ball1: cueBall, ball2: ball))
                } else {
                    invalidAngles_distances.append(contentsOf: computeAngle(ball1: cueBall, ball2: ball))
                }
            }
        }
        var dict:[Int:CGFloat] = [:]
        for possibleValidAngles_distance in possibleValidAngles_distances {
            dict[possibleValidAngles_distance.0] = possibleValidAngles_distance.distance
        }
        for invalidAngles_distance in invalidAngles_distances {
            if let d = dict[invalidAngles_distance.0] {
                if invalidAngles_distance.distance < d {
                    dict.removeValue(forKey: invalidAngles_distance.0)
                }
            }
        }
        var result:[(angle:CGFloat, distance:CGFloat)] = []
        for tuple in dict {
            result.append((angle:CGFloat(GLKMathDegreesToRadians(Float(tuple.key))), distance: tuple.value))
        }
        
        var selectedResult:[(angle:CGFloat, distance:CGFloat)] = []
        var idx = 0
        print("Finish computing valid angles and distances")
        while idx < result.count {
            print("\(idx): Valid Angle = \(GLKMathRadiansToDegrees(Float(result[idx].angle)))")
            selectedResult.append(result[idx])
            idx += remainingBalls.count
        }
        return selectedResult
    }
}

extension Board: GKGameModel {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board(difficulty: .Easy)
        copy.setGameModel(self)
        return copy
    }
    /**
     * Returns an array of all the GKGameModelUpdates (i.e. actions/moves) that the active
     * player can undertake, with one instance of GKGameModelUpdate for each possible move.
     * Returns nil if the specified player is invalid, is not a part of the game model, or
     * if there are no valid moves available.
     */
    public func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let angleDistanceTuples = validAngles()
        var result = [Move]()
        for tuple in angleDistanceTuples {
            let factor = sqrt(4 * GameConstants.Friction * max(100,tuple.distance) / 3)
            let m = Move(impluse: CGVector(dx: factor * Cue.impluseFactor * cos(tuple.angle), dy: factor * Cue.impluseFactor * sin(tuple.angle)))
            if !m.impluse.dx.isNaN && !m.impluse.dy.isNaN {
                result.append(m)
            }
        }
        //        print(result)
        return result
    }
    
    /**
     * Array of instances of GKGameModelPlayers representing players within this game model. When the
     * GKMinmaxStrategist class is used to find an optimal move for a specific player, it uses this
     * array to rate the moves of that player’s opponent(s).
     */
    
    public var players: [GKGameModelPlayer]? {
        return [currentPlayer, currentPlayer.opponent]
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            
            currentPlayer = board.currentPlayer.copy() as! Player
            currentPlayer.opponent = board.currentPlayer.opponent.copy() as! Player
            currentPlayer.opponent.opponent = currentPlayer
            remainingBalls.append(contentsOf: board.remainingBalls.map({$0.copy()}) as! [Ball])
            for ball in remainingBalls {
                if ball.color == .White {
                    cueBall = ball
                }
            }
        }
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let move = gameModelUpdate as? Move else {
            return
        }
        pocketedBalls.removeAll()
        if let ball = cueBall as? FakeBall {
            ball.velocity = CGVector(dx: GameConstants.AIStrength * move.impluse.dx, dy: GameConstants.AIStrength * move.impluse.dy)
            //            print(ball.velocity)
        }
        let seconds = 0.05
        while !isStable() {
            update(deltaTime: seconds, withDetection: true)
        }
    }
    
    func update(deltaTime seconds: TimeInterval, withDetection: Bool) {
        for ball in remainingBalls {
            ball.update(deltaTime: seconds)
        }
        checkPockets()
        if withDetection {
            //            print("Start Detection")
            checkCollisions()
        }
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        guard let player = player as? Player else {
            return -10
        }
        let sol = checkPocketedBalls()
        let total = sol.currentPlayerGet + player.points
        var netWin = sol.currentPlayerGet - sol.opponentGet
        if sol.includesEightBall {
            if total < 7 {
                netWin = -10
            } else {
                netWin += 1
            }
        }
        if sol.includesCueBall {
            netWin -= 2
        }
        print("\(player) will get: \(total)")
        print("Net Win: \(netWin)")
        return netWin
    }
    
    func checkCollisions() {
        for ball in remainingBalls {
            if let ball = ball as? FakeBall {
                if ball.position.x - GameConstants.BallRadius < Board.boardLeft && ball.velocity.dx < 0 ||
                    ball.position.x + GameConstants.BallRadius > Board.boardRight && ball.velocity.dx > 0 {
//                    print("Collision X")
                    ball.velocity = CGVector(dx: -ball.velocity.dx, dy: ball.velocity.dy)
                }
                if ball.position.y - GameConstants.BallRadius < Board.boardBottom && ball.velocity.dy < 0 ||
                    ball.position.y + GameConstants.BallRadius > Board.boardTop && ball.velocity.dy > 0 {
//                    print("Collision Y")
                    ball.velocity = CGVector(dx: ball.velocity.dx, dy: -ball.velocity.dy)
                }
                
                for anotherBall in remainingBalls {
                    if anotherBall !== ball {
                        if let anotherBall = anotherBall as? FakeBall {
                            if colliding(b1: ball, b2: anotherBall) {
//                                print("\(ball) and \(anotherBall) bounced")
                                bounce(b1: ball, b2: anotherBall)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func colliding(b1: Ball, b2: Ball) -> Bool {
        let deltaX = b2.position.x - b1.position.x
        let deltaY = b2.position.y - b1.position.y
        return pow(deltaX, 2) + pow(deltaY, 2) <= pow(2 * GameConstants.BallRadius, 2) &&
            deltaX * (b2.velocity.dx - b1.velocity.dx) + deltaY * (b2.velocity.dy - b1.velocity.dy) < 0
    }
    
    func bounce(b1: FakeBall, b2: FakeBall) {
        let d = distance(p1: b1.position, p2: b2.position)
        let deltaX = b2.position.x - b1.position.x
        let deltaY = b2.position.y - b1.position.y
        let unitContactX = deltaX / d
        let unitContactY = deltaY / d
        let b1Impluse = b1.velocity.dx * unitContactX + b1.velocity.dy * unitContactY
        let b2Impluse = b2.velocity.dx * unitContactX + b2.velocity.dy * unitContactY
        let impluseDiff = b2Impluse - b1Impluse
        b1.velocity = CGVector(dx: b1.velocity.dx + unitContactX * impluseDiff, dy: b1.velocity.dy + unitContactY * impluseDiff)
        b2.velocity = CGVector(dx: b2.velocity.dx - unitContactX * impluseDiff, dy: b2.velocity.dy - unitContactY * impluseDiff)
    }
    
    func checkPocketedBalls() -> (includesCueBall:Bool, includesEightBall:Bool, includesWrongTargetBall: Bool, currentPlayerGet: Int, opponentGet: Int) {
        var includesCueBall = false
        var includesEightBall = false
        var includesWrongTargetBall = false
        var counter1 = 0
        var counter2 = 0
        for ball in pocketedBalls {
//            print("\(ball) is pocketed")
            if ball.isNormalBall {
                if currentPlayer.ballColor == nil {
                    currentPlayer.ballColor = ball.color
                    counter1 += 1
                } else if ball.color == currentPlayer.ballColor {
                    counter1 += 1
                } else {
                    counter2 += 1
                    includesWrongTargetBall = true
                }
            } else {
                if ball.color == .White {
                    remainingBalls.append(ball)
                    includesCueBall = true
                } else {
                    includesEightBall = true
                }
            }
        }
        return (includesCueBall, includesEightBall, includesWrongTargetBall, counter1, counter2)
    }
}
