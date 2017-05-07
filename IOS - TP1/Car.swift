//
//  Car.swift
//  IOS - TP1
//
//  Created by Agustin Mounier on 5/6/17.
//  Copyright © 2017 Agustin Mounier. All rights reserved.
//

import UIKit
import SpriteKit

class Car: SKSpriteNode {
    
    var frontRightTire: Tire!
    var frontLeftTire: Tire!
    var backRightTire: Tire!
    var backLeftTire: Tire!
    
    init() {
        let texture = SKTexture(imageNamed: "car")
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 50, height: 100))
        self.position = CGPoint(x: 100, y:200)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Car
        self.physicsBody?.collisionBitMask = PhysicsCategory.Edge
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTires(frontRight: Tire, frontLeft: Tire, backRight: Tire, backLeft: Tire) {
        frontRightTire = frontRight
        frontLeftTire = frontLeft
        backLeftTire = backLeft
        backRightTire = backRight
    }

    
    func beginMoveForward() {
        frontRightTire.beginImpulseUp()
        frontLeftTire.beginImpulseUp()
    }
    
    func endMoveForward() {
        frontRightTire.endImpulseUp()
        frontLeftTire.endImpulseUp()
    }
    
    func beginLeftTurn() {
        frontRightTire.beginTorqueLeft()
        frontLeftTire.beginTorqueLeft()
    }
    
    func endLeftTurn() {
        frontRightTire.endTorqueLeft()
        frontLeftTire.endTorqueLeft()
    }
    
    func beginRightTurn() {
        frontRightTire.beginTorqueRight()
        frontLeftTire.beginTorqueRight()
    }
    
    func endRightTurn() {
        frontRightTire.endTorqueRight()
        frontLeftTire.endTorqueRight()
    }
    
    func beginMoveBackwards() {
        frontRightTire.beginImpulseDown()
        frontLeftTire.beginImpulseDown()
    }
    
    func endMoveBackwards() {
        frontRightTire.endImpulseDown()
        frontLeftTire.endImpulseDown()
    }
    
   
    
    func applyFriction() {
        
        if(frontLeftTire.isMoving()) {
            frontLeftTire.applyFriction()
        }
        if(frontRightTire.isMoving()) {
            frontRightTire.applyFriction()
        }
        if(backRightTire.isMoving()) {
            backRightTire.applyFriction()
        }
        if(backLeftTire.isMoving()) {
            backLeftTire.applyFriction()
        }
        
    }
    
    func applyTurningFriction() {
        if(frontLeftTire.isTurning()) {
            frontLeftTire.applyInertia()
        }
        if(frontRightTire.isTurning()) {
            frontRightTire.applyInertia()
        }
        if(backRightTire.isTurning()) {
            backRightTire.applyInertia()
        }
        if(backLeftTire.isTurning()) {
            backLeftTire.applyInertia()
        }
    }
    
    func updateMovement() {
        frontRightTire.updateMovement()
        frontLeftTire.updateMovement()
    }
    
    func limitWheelsTurn() {
    
    }
    
    
}
