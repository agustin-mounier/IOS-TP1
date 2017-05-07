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
    var cam:SKCameraNode!
    let car = Car()

    let camScale = CGFloat(2.0)
    var arrowDown: SKSpriteNode!
    var arrowLeft: SKSpriteNode!
    var arrowRight: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        view.showsPhysics = true
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        arrowDown = SKSpriteNode(color: UIColor.black, size: CGSize(width: size.width * camScale, height: size.height * 0.10 * camScale))
        arrowLeft = SKSpriteNode(color: UIColor.black, size: CGSize(width: size.width * 0.15 * camScale, height: size.height * camScale))
        arrowRight = SKSpriteNode(color: UIColor.black, size: CGSize(width: size.width * 0.15 * camScale, height: size.height * camScale))
        
        addCar()
        
        addChild(arrowDown)
        addChild(arrowLeft)
        addChild(arrowRight)
        
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam)
        cam.position = car.position
        cam.xScale = camScale
        cam.yScale = camScale
        car.beginMoveForward()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)

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
//        car.applyTurningFriction()
        car.updateMovement()
        cam.position = car.position
        updateControllsPositions()
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
        pinJointRightTire.shouldEnableLimits = true
        pinJointRightTire.upperAngleLimit = CGFloat.pi / 4.0
        pinJointRightTire.lowerAngleLimit = CGFloat.pi / -4.0
        pinJointRightTire.frictionTorque = 0.9

        
        
        let pinPositionLeftTire =
            CGPoint(x:car.position.x - car.size.width/2 + frontRightTire.size.width/2,
                    y:car.position.y + car.size.height/2 - frontRightTire.size.height/2)
    
        frontLeftTire.position = pinPositionLeftTire
        

        let pinJointLeftTire = SKPhysicsJointPin.joint(withBodyA: car.physicsBody!,
                                                       bodyB: frontLeftTire.physicsBody!,
                                                       anchor: pinPositionLeftTire)
        pinJointLeftTire.shouldEnableLimits = true
        pinJointLeftTire.upperAngleLimit = CGFloat.pi / 4.0
        pinJointLeftTire.lowerAngleLimit = CGFloat.pi / -4.0
        pinJointLeftTire.frictionTorque = 0.9

        
        
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
    
    func updateControllsPositions() {
    
        arrowDown.position = CGPoint(x:cam.position.x, y: cam.position.y - size.height/2 * camScale + arrowDown.size.height/2)
        arrowLeft.position = CGPoint(x:cam.position.x - size.width * 0.5 * camScale + arrowLeft.size.width/2, y: cam.position.y)
        arrowRight.position = CGPoint(x:cam.position.x + size.width * 0.5 * camScale - arrowRight.size.width/2 , y: cam.position.y)
        

    }

    
}
