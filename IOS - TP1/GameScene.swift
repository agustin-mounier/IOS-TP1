//
//  GameScene.swift
//  IOS - TP1
//
//  Created by Agustin Mounier on 4/17/17.
//  Copyright © 2017 Agustin Mounier. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Edge      : UInt32 = 0b1
    static let Tire      : UInt32 = 0b10
    static let Car       : UInt32 = 0b11
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let car = Car()
    let camScale = CGFloat(2.0)
    let LAPS = 3
    let timerLabel = SKLabelNode(fontNamed: "Arial")
    let lapsLabel = SKLabelNode(fontNamed: "Arial")
    let bestLapLabel = SKLabelNode(fontNamed: "Arial")

    
    var cam:SKCameraNode!
    
    var arrowDown: SKSpriteNode!
    var arrowLeft: SKSpriteNode!
    var arrowRight: SKSpriteNode!
    
    var speedBoosts = [SKNode]()
    var speedBumps = [SKNode]()

    var finishLine: SKNode!
    var gameTimer: Timer!
    var laps = 0
    var time = 0
    var bestTime = 0
    var countLap = true
    
    
    override func didMove(to view: SKView) {
//        view.showsPhysics = true
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        setUpControlls()
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
        
        getSpeedBoostsAndBumps()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        setUpLabels()
        addChild(timerLabel)
        addChild(lapsLabel)
        addChild(bestLapLabel)
        
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
        car.updateMovement()
        cam.position = car.position
        updateControllsPositions()
        applySpeedBoosts()
        updateLabelsPosition()
        updateLapsCounter()
        applySpeedBumps()
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

        
        
        let springPositionRightTire =
            CGPoint(x:car.position.x + car.size.width/2 - frontRightTire.size.width/2,
                    y:car.position.y - car.size.height/2 + frontRightTire.size.height/2)
        
        backRightTire.position = springPositionRightTire
        
        let springJointRightTire = SKPhysicsJointSpring.joint(withBodyA: car.physicsBody!,
                                                            bodyB: backRightTire.physicsBody!,
                                                            anchorA: springPositionRightTire,
                                                            anchorB: springPositionRightTire)
        
        let springPositionLeftTire =
            CGPoint(x:car.position.x - car.size.width/2 + frontRightTire.size.width/2,
                    y:car.position.y - car.size.height/2 + frontRightTire.size.height/2)
        
        backLeftTire.position = springPositionLeftTire
        
        let springJointLeftTire = SKPhysicsJointSpring.joint(withBodyA: car.physicsBody!,
                                                           bodyB: backLeftTire.physicsBody!,
                                                           anchorA: springPositionLeftTire,
                                                           anchorB: springPositionLeftTire)
        
        springJointLeftTire.frequency = 20
        springJointRightTire.frequency = 20
        
        
        addChild(backLeftTire)
        addChild(frontLeftTire)
        addChild(frontRightTire)
        addChild(backRightTire)
        addChild(car)
        physicsWorld.add(pinJointRightTire)
        physicsWorld.add(pinJointLeftTire)
        physicsWorld.add(springJointRightTire)
        physicsWorld.add(springJointLeftTire)
        car.setTires(frontRight: frontRightTire, frontLeft: frontLeftTire, backRight: backRightTire, backLeft: backLeftTire)
    
    }
    
    func updateControllsPositions() {
    
        arrowDown.position = CGPoint(x:cam.position.x, y: cam.position.y - size.height/2 * camScale + arrowDown.size.height/2)
        arrowLeft.position = CGPoint(x:cam.position.x - size.width * 0.5 * camScale + arrowLeft.size.width/2, y: cam.position.y)
        arrowRight.position = CGPoint(x:cam.position.x + size.width * 0.5 * camScale - arrowRight.size.width/2 , y: cam.position.y)
        
    }
    
    func applySpeedBoosts() {
        for speedBoost in speedBoosts {
            if(speedBoost.contains(car.position)) {
                car.applySpeedBoost()
            }
        }
    }
    
    func applySpeedBumps() {
        for speedBump in speedBumps {
            if(speedBump.contains(car.position)) {
                car.applySpeedBump()
            }
        }
    }
    
    func runTimedCode() {
        time += 1
        timerLabel.text = "Time: \(time)"
    }
    
    func updateLabelsPosition() {
        timerLabel.position.x = cam.position.x + size.width * 0.5 * camScale - 90
        timerLabel.position.y = cam.position.y + size.height * 0.5 * camScale - 60
        
        lapsLabel.position.x = cam.position.x + size.width * 0.5 * camScale - 250
        lapsLabel.position.y = cam.position.y + size.height * 0.5 * camScale - 60
        
        bestLapLabel.position.x = cam.position.x + size.width * 0.5 * camScale - 450
        bestLapLabel.position.y = cam.position.y + size.height * 0.5 * camScale - 60

    }

    func updateLapsCounter() {
        if(finishLine.contains(car.position) && countLap) {
            laps += 1
            lapsLabel.text = "Lap: \(laps)"
            countLap = false
            if(bestTime == 0 || bestTime > time - bestTime) {
                bestLapLabel.text = "Best time: \(time - bestTime)"
                bestTime = time - bestTime
            }
        }
        if(car.position.y > finishLine.position.y - 400 &&
            car.position.y < finishLine.position.y - 200) {
            countLap = true
        }
    }
    
    func setUpLabels() {
        timerLabel.fontSize = 30
        timerLabel.color = UIColor.white
        lapsLabel.fontSize = 30
        lapsLabel.color = UIColor.white
        lapsLabel.text = "Lap: 0"
        bestLapLabel.fontSize = 30
        bestLapLabel.color = UIColor.white
        bestLapLabel.text = "Best time: none"
    }
    
    func setUpControlls() {
        arrowDown = SKSpriteNode(color: UIColor.black, size: CGSize(width: size.width * camScale, height: size.height * 0.10 * camScale))
        arrowLeft = SKSpriteNode(color: UIColor.black, size: CGSize(width: size.width * 0.15 * camScale, height: size.height * camScale))
        arrowRight = SKSpriteNode(color: UIColor.black, size: CGSize(width: size.width * 0.15 * camScale, height: size.height * camScale))
    }
    
    func getSpeedBoostsAndBumps() {
        finishLine = (scene?.childNode(withName:"finish-line"))!
        speedBoosts.append((scene?.childNode(withName:"speed-boost-1"))!)
        speedBoosts.append((scene?.childNode(withName:"speed-boost-2"))!)
        speedBoosts.append((scene?.childNode(withName:"speed-boost-3"))!)
        speedBoosts.append((scene?.childNode(withName:"speed-boost-4"))!)
        
        speedBumps.append((scene?.childNode(withName:"speed-bump-1"))!)
        speedBumps.append((scene?.childNode(withName:"speed-bump-2"))!)
        speedBumps.append((scene?.childNode(withName:"speed-bump-3"))!)
        speedBumps.append((scene?.childNode(withName:"speed-bump-4"))!)
        speedBumps.append((scene?.childNode(withName:"speed-bump-5"))!)
    }
    
}
