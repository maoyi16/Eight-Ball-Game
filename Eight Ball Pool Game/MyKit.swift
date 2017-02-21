//
//  MyKit.swift
//  Eight Ball Pool Game
//
//  Created by 毛易 on 2/17/17.
//  Copyright © 2017 Yi Mao. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

func unitVector(vector: CGVector) -> CGVector {
    let length = sqrt(pow(vector.dx, 2) + pow(vector.dy,2))
    return CGVector(dx: vector.dx / length, dy: vector.dy / length)
}
func negatedVector(vector: CGVector) -> CGVector {
    return CGVector(dx: -vector.dx, dy: -vector.dy)
}

func angle(p1:CGPoint, p2:CGPoint) -> CGFloat {
    return atan2(p2.y - p1.y, p2.x - p1.x)
}

func distance(p1:CGPoint, p2:CGPoint) -> CGFloat {
    let deltaX = p2.x - p1.x
    let deltaY = p2.y - p1.y
    return sqrt(pow(deltaX,2) + pow(deltaY,2))
}

func dotCGVector(v1:CGVector, v2:CGVector) -> CGFloat {
    let unitVector1 = unitVector(vector: v1)
    let unitVector2 = unitVector(vector: v2)
    return unitVector1.dx * unitVector2.dx + unitVector1.dy * unitVector2.dy
}

func length(vector: CGVector) -> CGFloat {
    return sqrt(pow(vector.dx, 2) + pow(vector.dy,2))
}

func convertAngle(angle:CGFloat) -> CGFloat {
    if angle > CGFloat(M_PI) {
        return angle.subtracting(CGFloat(2 * M_PI))
    } else if angle < CGFloat(-M_PI) {
        return angle.adding(CGFloat(2 * M_PI))
    } else {
        return angle
    }
}
