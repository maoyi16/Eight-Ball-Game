//
//  angleTest.swift
//  angleTest
//
//  Created by 毛易 on 2/19/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import XCTest
import GameplayKit
class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDistanceComputation() {
        let ball1 = FakeBall(posX: 0, posY: 0, color: .Blue)
        let ball2 = FakeBall(posX: 4 * 7.5, posY: 0, color: .Blue)
        let board = Board(difficulty: .Hard)
        print("\n\n\n\n\n")
        print(board.computeDistance(ball1: ball1, ball2: ball2, angle: CGFloat(M_PI / 6)))
        print("\n\n\n\n\n")
    }
    
    func testAngles() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let b1 = FakeBall(posX: 0, posY: 0, color: .White)
        let b2 = FakeBall(posX: 30, posY: 0, color: .Blue)
        let b3 = FakeBall(posX: 60, posY: 0, color: .Red)
        let board = Board(difficulty: .Hard)
        board.remainingBalls.append(contentsOf:[b1,b2,b3] as [Ball])
        board.cueBall = b1
        board.currentPlayer = Player(id: .First, isAI: false)
        board.currentPlayer.opponent = Player(id: .Second, isAI: true)
        board.currentPlayer.opponent.opponent = board.currentPlayer
//        board.currentPlayer.ballColor = .Blue
        print(board.validAngles())
    }
    
    func testboardCopy() {
        let b1 = FakeBall(posX: 0, posY: 0, color: .White)
        let b2 = FakeBall(posX: 30, posY: 0, color: .Blue)
        let b3 = FakeBall(posX: 15, posY: 0, color: .Red)
        let board = Board(difficulty: .Hard)
        board.remainingBalls.append(contentsOf: [b1,b2,b2.copy() as! Ball,b3])
        board.cueBall = b1
        board.currentPlayer = Player(id: .First, isAI: false)
        board.currentPlayer.opponent = Player(id: .Second, isAI: true)
        board.currentPlayer.opponent.opponent = board.currentPlayer
        board.currentPlayer.ballColor = .Blue
        let copy = board.copy()
        print(board)
        print("\n\n")
        print(copy)
    }
    
    func testLALA() {
        let a:CGFloat = 5.0
        let b:CGFloat = 5.0
        XCTAssert(a == b)
        print(GLKMathRadiansToDegrees(-2))
        print(lround(Double(GLKMathRadiansToDegrees(Float(CGFloat(-2))))))
        
        var dict = [2:3,4:5]
        if let s = dict[5] {
            print(s)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
