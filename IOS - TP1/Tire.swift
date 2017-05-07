//
//  Tire.swift
//  IOS - TP1
//
//  Created by Agustin Mounier on 4/17/17.
//  Copyright © 2017 Agustin Mounier. All rights reserved.
//

import UIKit
import SpriteKit

class Tire: SKSpriteNode {
    
    let MAX_FORWARD_VEL = CGFloat(70.0)
    let MAX_ANGULAR_VEL = CGFloat(60.0)
    
    var MOVING_UP = false
    var TORQUE_LEFT = false
    var TORQUE_RIGHT = false
    var MOVING_DOWN = false
    
    init() {
        let texture = SKTexture(imageNamed: "tire")
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 12.5, height: 30))
        self.position = CGPoint(x: 200, y:200)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.mass = CGFloat(6.07635545730591)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Tire
        self.physicsBody?.collisionBitMask = PhysicsCategory.Edge
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getLateralVelocity() -> CGVector {
        let normalLateral = CGVector(angle: zRotation)
        let dotProd = dotProduct(vector1: normalLateral, vector2: (physicsBody?.velocity)!)
        
        return normalLateral * dotProd
    }
    
    
    func applyFriction() {
        let lateralVelocity = self.getLateralVelocity()
        self.physicsBody?.applyImpulse(lateralVelocity * -1.0)
        
        let forwardVelocity = getForwardVelocity()
        physicsBody?.applyImpulse(forwardVelocity * -0.05)
    }
    
    func applyInertia() {
        if(self.physicsBody?.angularVelocity != nil) {
//            self.physicsBody?.applyAngularImpulse(-0.01 * self.physicsBody!.angularVelocity)
        }
    }
    
    func isMoving() -> Bool {
         return self.physicsBody?.velocity != nil && (self.physicsBody!.velocity.dx != 0 || self.physicsBody!.velocity.dy != 0)
    }
    
    func isTurning() -> Bool {
        return physicsBody?.angularVelocity != nil && physicsBody!.angularVelocity != CGFloat(0.0)
    }
    
    func getForwardVelocity() -> CGVector {
        let normalForward = CGVector(angle: zRotation + CGFloat.pi/2)
        let dotProd = dotProduct(vector1: normalForward, vector2: (physicsBody?.velocity)!)
        
        return normalForward * dotProd

    }
    
    func dotProduct(vector1: CGVector, vector2: CGVector) -> CGFloat {
        let cosAngle = ((vector1.dx * vector2.dx) + (vector1.dy * vector2.dy)) / (vector1.length() + vector2.length())
        return vector1.length() * vector2.length() * cosAngle
    }
    
    
    func beginImpulseUp() {
        MOVING_UP = true
        impulseUp()
    }
    
    func endImpulseUp() {
        MOVING_UP = false
    }
    
    func impulseUp() {
        if(getForwardVelocity().length() >= MAX_FORWARD_VEL) {
            return
        }
        let nForward = CGVector(angle: zRotation + CGFloat.pi/2)
        
        physicsBody?.applyForce(nForward * 300)
    }
    
    func beginImpulseDown() {
        MOVING_DOWN = true
        impulseDown()
    }
    
    func endImpulseDown() {
        MOVING_DOWN = false
    }
    
    func impulseDown() {
        if(getForwardVelocity().length() >= MAX_FORWARD_VEL) {
            return
        }
        let nForward = CGVector(angle: zRotation + CGFloat.pi/2)
        
        physicsBody?.applyForce(nForward * -300)
    }
    
    
    func beginTorqueLeft() {
        TORQUE_LEFT = true
        torqueLeft()
    }
    
    func endTorqueLeft() {
        TORQUE_LEFT = false
    }
    
    func torqueLeft() {
        if((physicsBody?.angularVelocity)! > MAX_ANGULAR_VEL) {
            return
        }
        physicsBody?.applyTorque(1.1)
    }
    
    func beginTorqueRight() {
        TORQUE_RIGHT = true
        torqueRight()
    }
    
    func endTorqueRight() {
        TORQUE_RIGHT = false
    }
    
    func torqueRight() {
        if((physicsBody?.angularVelocity)! > MAX_ANGULAR_VEL) {
            return
        }
        physicsBody?.applyTorque(-1.1)
    }
    
    
    func updateMovement() {
        if(MOVING_UP) {
            impulseUp()
        }
        
        if(TORQUE_LEFT) {
            torqueLeft()
        }
        
        if(TORQUE_RIGHT) {
            torqueRight()
        }
        
        if(MOVING_DOWN) {
            impulseDown()
        }
    }
    
    
}
