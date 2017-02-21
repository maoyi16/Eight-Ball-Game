//
//  GameScene.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 1/21/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import SpriteKit
import GameplayKit

class PoolScene: SKScene {
    enum Mode {
        case PVP
        case PVE
        case EVE
    }
    
    // MARK: - fields need to be copied by AI
    let board = Board(difficulty:.Hard)
    // MARK: - fields that are used only for scene
    var canPlacingCueBall = false
    var mode: Mode!
    var selectedNode:SKNode? = nil
    var cue: Cue!
    var cueInRack:Cue!
    var score1:SKLabelNode!
    var score2:SKLabelNode!
    var player1ColorLabel: SKSpriteNode!
    var player2ColorLabel: SKSpriteNode!
    var cushions = [SKNode]()
    let sceneOffsetY: CGFloat = -45
    let sceneOffsetX: CGFloat = 0
    let offsetX:CGFloat = 100
//    let rackTop:SKNode = { let n = SKNode(); n.position = CGPoint(x: -300, y: 90); return n}()
    let rackTop = FakeBall(posX: -300, posY: 90, color: .None, withNode: true)
    static let initPosition = CGPoint(x: -100, y: -45)
    let gameInfoLabel = SKLabelNode(text: "Switch Player")
    static var gameNeedsUpdate = false
    
    private var lastUpdateTime : TimeInterval = 0
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !board.currentPlayer.isAI else {
            return
        }
        if touches.count == 1 {
            if let touch = touches.first {
                let location = touch.location(in: self)
                selectedNode = atPoint(location)
                if selectedNode == cue.node {
                    print("Touched Cue")
                } else if selectedNode == cueInRack.node {
                    print("Adjust Strength")
                } else if canPlacingCueBall && selectedNode == board.cueBall.node {
                    print("Touched CueBall")
                } else {
                    selectedNode = nil
                }
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !board.currentPlayer.isAI else {
            return
        }
        if touches.count == 1 {
            if let touch = touches.first {
                let location = touch.location(in: self)
                //                print(location)
                if selectedNode == cue.node {
                    let newAngle = angle(p1: cue.centerPosition, p2: location)
                    cue.ball.node.run(SKAction.rotate(byAngle: newAngle - cue.angle, duration: 0))
                    cue.angle = newAngle
                } else if selectedNode == cueInRack.node {
                    let translation = location.y - touch.previousLocation(in: self).y
                    //                    print("Translation: \(translation)")
                    cue.translate(translation: translation)
                    cueInRack.translate(translation: translation)
                } else if selectedNode == board.cueBall.node {
                    board.cueBall.node.run(SKAction.move(to: location, duration: 0), completion: {
                        self.board.cueBall.position = location
                    })
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !board.currentPlayer.isAI else {
            return
        }
        print("Touches End")
        if selectedNode == cueInRack.node {
            // Strike the cue ball
            if cue.canStrike() {
                if canPlacingCueBall {
                    exitDragMode()
                }
                cue.strike()
                //                if let ball = board.cueBall as? FakeBall {
                //                    ball.velocity = CGVector(dx: 1000, dy: 0)
                //                }
                PoolScene.gameNeedsUpdate = true
            }
            cueInRack.restore()
        }
        selectedNode = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
//        board.update(deltaTime: dt, withDetection: true)
        board.update(deltaTime: dt, withDetection: false)
        
        self.lastUpdateTime = currentTime
        
        if (board.isStable()) {
            if cue.isStable {
                if !canPlacingCueBall {
                    cue.show()
                }
                if PoolScene.gameNeedsUpdate {
                    updateGame()
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
        print(size)
        print(mode)
        if mode == .PVP {
            board.currentPlayer = Player(id: .First, isAI: false)
            board.currentPlayer.opponent = Player(id: .Second, isAI: false)
            board.currentPlayer.opponent.opponent = board.currentPlayer
            
        } else if mode == .PVE {
            board.currentPlayer = Player(id: .First, isAI: false)
            board.currentPlayer.opponent = Player(id: .Second, isAI: true)
            board.currentPlayer.opponent.opponent = board.currentPlayer
        } else {
            board.currentPlayer = Player(id: .Second, isAI: true)
            board.currentPlayer.opponent = Player(id: .First, isAI: true)
            board.currentPlayer.opponent.opponent = board.currentPlayer
            PoolScene.gameNeedsUpdate = true
        }
        score1 = childNode(withName: "score1") as! SKLabelNode
        score2 = childNode(withName: "score2") as! SKLabelNode
        player1ColorLabel = childNode(withName: "Player1_Color") as! SKSpriteNode
        player1ColorLabel.isHidden = true
        player2ColorLabel = childNode(withName: "Player2_Color") as! SKSpriteNode
        player2ColorLabel.isHidden = true
        //        brain = GameBrain(scene: self)
        
        // Place balls on the pool table
        var ballPositions: [Int]!
        while true {
            ballPositions = GKRandomSource().arrayByShufflingObjects(in: Array(1...15)) as! [Int]
            if ballPositions[14] != 1 {
                break
            }
        }
        
        for i in 1...15 {
            if i < 8 {
                placeABall(position: ballPositions[i - 1], color: .Red)
            } else if i > 8 {
                placeABall(position: ballPositions[i - 1], color: .Blue)
            } else {
                placeABall(position: ballPositions[i - 1], color: .Black)
            }
        }
        
        placeABall(position: 16, color: .White)
        //        remainingBalls.append(contentsOf: balls)
        initPockets()
        addChild(gameInfoLabel)
        gameInfoLabel.zPosition = 20
        gameInfoLabel.isHidden = true
        setAI()
    }
    
    func initPockets() {
        Board.pockets.append(Pocket(x: -223, y: 73))
        Board.pockets.append(Pocket(x: -3, y: 73))
        Board.pockets.append(Pocket(x: 223, y: 73))
        Board.pockets.append(Pocket(x: -223, y: -163))
        Board.pockets.append(Pocket(x: -3, y: -163))
        Board.pockets.append(Pocket(x: 223, y: -163))
    }
    
    func placeABall(position: Int, color: BallColor) {
        let radius = GameConstants.BallRadius
        if position == 16 {
            // Place the cue ball
//            let ball = FakeBall(posX: sceneOffsetX - offsetX, posY: sceneOffsetY, color: color, withNode: true)
            let ball = RealBall(posX: sceneOffsetX - offsetX, posY: sceneOffsetY, color: color)
            addChild(ball.node)
            board.remainingBalls.append(ball)
            cue = Cue(center: ball, onRack: false)
            addChild(rackTop.node)
            cueInRack = Cue(center: rackTop, onRack: true)
            board.cueBall = ball
        } else {
            // Place object balls
            let col: CGFloat =
                position < 2 ? 0 : position < 4 ? 1 : position < 7 ? 2 : position < 11 ? 3 : 4
            let offsetY = -col * radius
            let firstNumberInCol = (col * (col + 1) / 2) + 1
            let x = sceneOffsetX + offsetX + col * radius * sqrt(3)
            let y = sceneOffsetY + offsetY + (CGFloat(position) - firstNumberInCol) * radius * 2
//            let ball = FakeBall(posX: x, posY: y, color: color, withNode: true)
            let ball = RealBall(posX: x, posY: y, color: color)
            addChild(ball.node)
            board.remainingBalls.append(ball)
        }
        
    }
    
    // MARK: - Game Logic
    fileprivate func switchPlayer(number: Int) {
        print("From: \(number). Switch Players")
        //        print(CFAbsoluteTimeGetCurrent())
        board.currentPlayer = board.currentPlayer.opponent
        if canPlacingCueBall {
            updateGameInfo(textList: ["\(board.currentPlayer!)'s turn","Drag to place cue ball"])
        } else {
            updateGameInfo(textList: ["\(board.currentPlayer!)'s turn"])
        }
    }
    
    fileprivate func incScore(player: Player) {
        player.incPoints()
        if (player.id == .First) {
            score1.text = String(Int(score1.text!)! + 1)
        } else {
            score2.text = String(Int(score2.text!)! + 1)
        }
    }
    
    fileprivate func setColor(color: BallColor) {
        board.currentPlayer.ballColor = color
        board.currentPlayer.opponent.ballColor = color == .Blue ? .Red : .Blue
        if board.currentPlayer.id == .First && color == .Blue || board.currentPlayer.id == .Second && color == .Red {
            player1ColorLabel.color = UIColor.blue
            player2ColorLabel.color = UIColor.red
        } else {
            player1ColorLabel.color = UIColor.red
            player2ColorLabel.color = UIColor.blue
        }
        player1ColorLabel.isHidden = false
        player2ColorLabel.isHidden = false
    }
    
    func checkPocketedBalls() -> (includesCueBall:Bool, includesEightBall:Bool, includesWrongTargetBall: Bool) {
        var includesCueBall = false
        var includesEightBall = false
        var includesWrongTargetBall = false
        for ball in board.pocketedBalls {
            print("\(ball) is pocketed")
            if ball.isNormalBall {
                if board.currentPlayer.ballColor == nil {
                    incScore(player: board.currentPlayer)
                    setColor(color: ball.color)
                } else if ball.color == board.currentPlayer.ballColor {
                    incScore(player: board.currentPlayer)
                } else {
                    incScore(player: board.currentPlayer.opponent)
                    includesWrongTargetBall = true
                }
            } else {
                if ball.color == .White {
                    board.remainingBalls.append(ball)
                    includesCueBall = true
                } else {
                    includesEightBall = true
                }
            }
        }
        return (includesCueBall, includesEightBall, includesWrongTargetBall)
    }
    
    fileprivate func updateGame() {
        if board.pocketedBalls.count == 0 {
            switchPlayer(number: 1)
        } else {
            let (includesCueBall, includesEightBall, includesWrongTargetBall) = checkPocketedBalls()
            if includesEightBall {
                if board.currentPlayer.state == .EightBall {
                    print("\(board.currentPlayer!) wins")
                    updateGameInfo(textList: ["\(board.currentPlayer!) wins", "load Menu"])
                } else {
                    print("\(board.currentPlayer!.opponent!) wins")
                    updateGameInfo(textList: ["\(board.currentPlayer!.opponent!) wins", "load Menu"])
                }
            } else if includesCueBall {
                if board.currentPlayer.opponent.isAI {
                        switchPlayer(number: 2)
                } else {
                    enterDragMode()
                    switchPlayer(number: 2)
                    print("Place cue ball anywhere")
                }
                print(board.cueBall.position)
                board.cueBall.position = CGPoint(x: -300, y: sceneOffsetY)
                cue.node.isHidden = true
                addChild(board.cueBall.node)
                self.board.cueBall.position = PoolScene.initPosition
                self.cue.show()
            } else if includesWrongTargetBall {
                switchPlayer(number: 3)
            }
        }
        board.resetPockedBalls()
        PoolScene.gameNeedsUpdate = false
        if board.currentPlayer.isAI {
            processAIMove()
        }
    }
    
    fileprivate func updateGameInfo (textList: [String]) {
        var actions:[SKAction] = []
        for text in textList {
            if text == "load Menu" {
                actions.append(SKAction.run({
                    self.loadMenu()
                }))
            } else {
                actions.append(SKAction.run({
                    self.gameInfoLabel.setScale(1)
                    self.gameInfoLabel.text = text
                }))
                actions.append(SKAction(named: "GameInfo")!)
            }
        }
        gameInfoLabel.isHidden = false
        gameInfoLabel.run(SKAction.sequence(actions), completion: {self.gameInfoLabel.isHidden = true})
    }
    
    fileprivate func enterDragMode() {
        canPlacingCueBall = true
        board.cueBall.node.physicsBody?.collisionBitMask = 0
        board.cueBall.node.physicsBody?.categoryBitMask = 0
    }
    
    fileprivate func exitDragMode() {
        canPlacingCueBall = false
        board.cueBall.node.physicsBody?.collisionBitMask = 0xFFFFFFFF
        board.cueBall.node.physicsBody?.categoryBitMask =  0xFFFFFFFF
    }
    
    fileprivate func loadMenu() {
        
        // Load 'MenuScene.sks' as a GKScene. This provides gameplay related content
        if let scene = GKScene(fileNamed: "MenuScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! MenuScene? {
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view {
                    let transition = SKTransition.reveal(with: .down, duration: 1.0)
                    view.presentScene(sceneNode, transition: transition)
                    view.ignoresSiblingOrder = true
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    var AI = GKMinmaxStrategist()
    
    func setAI() {
        AI.gameModel = board
        AI.maxLookAheadDepth = 1
        AI.randomSource = GKARC4RandomSource()
    }
    
    fileprivate func processAIMove() {
        print("AI's Move")
        if let bestMove = self.AI.bestMoveForActivePlayer() as? Move {
            //            print(bestMove.impluse)
            cue.rotateTranslateThanStrike(impluse: bestMove.impluse)
            print("AI finished")
        } else {
            // winner undecided
            switchPlayer(number: 4)
            if mode == .EVE {
                processAIMove()
            }
        }
    }
}

