//
//  GameScene.swift
//  IOS - TP1
//
//  Created by Agustin Mounier on 4/17/17.
//  Copyright © 2017 Agustin Mounier. All rights reserved.
//

import SpriteKit
import GameplayKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Edge      : UInt32 = 0b1
    static let Tire      : UInt32 = 0b10
    static let Car       : UInt32 = 0b11
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let car = Car()

    let arrowUp = SKSpriteNode(color: UIColor.white, size: CGSize(width: 25, height: 25))
    let arrowDown = SKSpriteNode(color: UIColor.white, size: CGSize(width: 25, height: 25))
    let arrowLeft = SKSpriteNode(color: UIColor.white, size: CGSize(width: 25, height: 25))
    let arrowRight = SKSpriteNode(color: UIColor.white, size: CGSize(width: 25, height: 25))

    override func didMove(to view: SKView) {
        view.showsPhysics = true
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.Edge

        
        arrowUp.position = CGPoint(x:size.width * 0.5, y: size.width * 0.15)
        arrowDown.position = CGPoint(x:size.width * 0.5, y: size.width * 0.1)
        arrowLeft.position = CGPoint(x:size.width * 0.25, y: size.width * 0.1)
        arrowRight.position = CGPoint(x:size.width * 0.75, y: size.width * 0.1)
        
        addCar()
        
        addChild(arrowUp)
        addChild(arrowDown)
        addChild(arrowLeft)
        addChild(arrowRight)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        if(arrowUp.contains(touchLocation)) {
            car.endMoveForward()
        }
        
        if(arrowLeft.contains(touchLocation)) {
            car.endLeftTurn()
        }
        
        if(arrowRight.contains(touchLocation)) {
            car.endRightTurn()
        }
        
        if(arrowDown.contains(touchLocation)) {
            car.endMoveBackwards()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocationBegan = touch.location(in: self)
        
        if(arrowUp.contains(touchLocationBegan)) {
            car.beginMoveForward()
        }
        
        if(arrowLeft.contains(touchLocationBegan)) {
            car.beginLeftTurn()
        }
        
        if(arrowRight.contains(touchLocationBegan)) {
            car.beginRightTurn()
        }
        
        if(arrowDown.contains(touchLocationBegan)) {
            car.beginMoveBackwards()
        }
        
    
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        car.applyFriction()
        car.applyTurningFriction()
        car.updateMovement()
    }
    
    
    func addCar() {
        let frontRightTire = Tire()
        let frontLeftTire = Tire()
        let backRightTire = Tire()
        let backLeftTire = Tire()

        
        let pinPositionRightTire =
            CGPoint(x:car.position.x + car.size.width/2 - frontRightTire.size.width/2,
                    y:car.position.y + car.size.height/2 - frontRightTire.size.height/2)
        
        frontRightTire.position = pinPositionRightTire
        
        let pinJointRightTire = SKPhysicsJointPin.joint(withBodyA: car.physicsBody!,
                                                        bodyB: frontRightTire.physicsBody!,
                                                        anchor: pinPositionRightTire)
        
        let pinPositionLeftTire =
            CGPoint(x:car.position.x - car.size.width/2 + frontRightTire.size.width/2,
                    y:car.position.y + car.size.height/2 - frontRightTire.size.height/2)
    
        frontLeftTire.position = pinPositionLeftTire

        let pinJointLeftTire = SKPhysicsJointPin.joint(withBodyA: car.physicsBody!,
                                                       bodyB: frontLeftTire.physicsBody!,
                                                       anchor: pinPositionLeftTire)
        
        
        
        let fixedPositionRightTire =
            CGPoint(x:car.position.x + car.size.width/2 - frontRightTire.size.width/2,
                    y:car.position.y - car.size.height/2 + frontRightTire.size.height/2)
        
        backRightTire.position = fixedPositionRightTire
        
        let fixedJointRightTire = SKPhysicsJointFixed.joint(withBodyA: car.physicsBody!,
                                                            bodyB: backRightTire.physicsBody!,
                                                            anchor: fixedPositionRightTire)
        
        let fixedPositionLeftTire =
            CGPoint(x:car.position.x - car.size.width/2 + frontRightTire.size.width/2,
                    y:car.position.y - car.size.height/2 + frontRightTire.size.height/2)
        
        backLeftTire.position = fixedPositionLeftTire
        
        let fixedJointLeftTire = SKPhysicsJointFixed.joint(withBodyA: car.physicsBody!,
                                                           bodyB: backLeftTire.physicsBody!,
                                                           anchor: fixedPositionLeftTire)
        
        
        let fixedPositionLeftTireMiddle =
            CGPoint(x:car.position.x,
                    y:car.position.y - car.size.height/2 + frontRightTire.size.height/2)
        
        backLeftTire.position = fixedPositionLeftTireMiddle
        
        let fixedJointLeftTirem = SKPhysicsJointFixed.joint(withBodyA: car.physicsBody!,
                                                           bodyB: backLeftTire.physicsBody!,
                                                           anchor: fixedPositionLeftTireMiddle)
        
        addChild(backLeftTire)
        addChild(frontLeftTire)
        addChild(frontRightTire)
        addChild(backRightTire)
        addChild(car)
        physicsWorld.add(pinJointRightTire)
        physicsWorld.add(pinJointLeftTire)
        physicsWorld.add(fixedJointLeftTirem)
//        physicsWorld.add(fixedJointRightTire)
//        physicsWorld.add(fixedJointLeftTire)
        car.setTires(frontRight: frontRightTire, frontLeft: frontLeftTire, backRight: backRightTire, backLeft: backLeftTire)
    
    }

    
}
