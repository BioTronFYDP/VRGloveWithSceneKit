//
//  GameViewController.swift
//  Symmetra
//
//  Created by Si Te Feng on 11/19/16.
//  Copyright (c) 2016 Technochimera. All rights reserved.
//

import SceneKit
import QuartzCore

let pi = CGFloat(3.14159265359)

class GameViewController: NSViewController, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var gameView: GameView!
    
    private var scene = SCNScene()
    private var _handNode: SCNNode = SCNNode()
    private let kDefaultHandPosition = SCNVector3Make(0, 8, 0)
    private let kDefaultHandOrientation = SCNVector3Make(-2.3, 0, CGFloat(M_PI/2))
    
    private var _rawBones: [SCNNode] = []
    private var _structuredBones: [[SCNNode]] = Array(repeating: [], count: 5)
    private var _originalEulers: [[SCNVector3]] = Array(repeating: [], count: 5)
    
    private var _soccerBall: SCNNode = {
        let soccerBallScene = SCNScene(named: "art.scnassets/soccer.dae")!
        let soccerBall = soccerBallScene.rootNode.childNodes[1]
        soccerBall.physicsBody = SCNPhysicsBody.static()
        soccerBall.physicsBody?.friction = 1
        soccerBall.physicsBody?.damping = 0.5
        soccerBall.physicsBody?.restitution = 0
        soccerBall.physicsBody?.rollingFriction = 1
        return soccerBall
    }()
    
    private var _soccerBallScale: CGFloat = 0.001
    private let kSoccerGrowIncrement: CGFloat = 0.05
    private let kSoccerGrowDuration: CGFloat = 2
    var _soccerTimer: Timer!
    
    var tempTimer: Timer!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // add floor to a new scene
        let floorNode = generateFloorNode()
        scene.rootNode.addChildNode(floorNode)
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 14, z: 10)
        cameraNode.eulerAngles = SCNVector3Make(-CGFloat(M_PI/8.0), 0, 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 20, z: 20)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        
        // Retrieve the hand node
        _handNode = getHandNode()
        //  rotateHandIndefinitely()
        scene.rootNode.addChildNode(_handNode)
        _handNode.position = kDefaultHandPosition
        // (yaw, pitch, roll)
        _handNode.eulerAngles = kDefaultHandOrientation
        
        executeHandAnimations()


        

        let dragonScene = SCNScene(named: "art.scnassets/dragon.dae")!
        let dragon = dragonScene.rootNode.childNodes[0]
        dragon.scale = SCNVector3Make(6, 6, 6)
        dragon.eulerAngles = SCNVector3Make(CGFloat(M_PI/18), CGFloat(M_PI/14), -CGFloat(M_PI/2))
        dragon.position = SCNVector3Make(-15, CGFloat(10), -35)
        
        dragon.physicsBody = SCNPhysicsBody.dynamic()
        dragon.physicsBody?.restitution = 0
        dragon.physicsBody?.physicsShape = SCNPhysicsShape(node: dragon, options: nil)
        dragon.physicsBody?.physicsShape = SCNPhysicsShape(geometry: SCNPyramid(width: 1.158*6, height: 1.327*6, length: 1.158*6), options: nil)
        dragon.physicsBody?.restitution = 0.3
        dragon.physicsBody?.mass = 30
        scene.rootNode.addChildNode(dragon)
        
        
        let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
        let ship = shipScene.rootNode.childNodes[0]
        ship.scale = SCNVector3Make(3, 3, 3)
        ship.physicsBody = SCNPhysicsBody.dynamic()
        ship.physicsBody?.mass = 30
        ship.eulerAngles = SCNVector3Make(CGFloat(M_PI/20), CGFloat(M_PI/24), -CGFloat(M_PI/28))
        ship.position = SCNVector3Make(15, CGFloat(5), -23)
        scene.rootNode.addChildNode(ship)
        
        
        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.black
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    func generateFloorNode() -> SCNNode {
        let floorGeometry = SCNFloor()
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = NSImage(named: "woodTile1.jpg")
        floorMaterial.diffuse.wrapS = SCNWrapMode.repeat
        floorMaterial.diffuse.wrapT = SCNWrapMode.repeat
        floorMaterial.locksAmbientWithDiffuse = true
        floorGeometry.materials = [floorMaterial]
        floorGeometry.reflectivity = 0.3
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.physicsBody = SCNPhysicsBody.static()
        floorNode.position = SCNVector3Make(40, 0, 40)
        return floorNode
    }
    
    func getHandNode() -> SCNNode {
        let handNode = SCNNode()
//        let handScene = SCNScene(named: "art.scnassets/hand1.dae")!
        let handScene = SCNScene(named: "art.scnassets/hand3.scn")!
        let hand = handScene.rootNode
        
        let bodyType = SCNPhysicsBodyType.kinematic
        let shape = SCNPhysicsShape(node: hand, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        hand.physicsBody = SCNPhysicsBody(type: bodyType, shape: shape)
        hand.physicsBody?.friction = 1
        hand.physicsBody?.restitution = 0
        
//        handNode.physicsBody = SCNPhysicsBody.kinematic()
        
        for node in hand.childNodes {
            
            guard node.camera == nil && node.light == nil else {
                continue
            }
            
            handNode.addChildNode(node)
            
            var allBones: [SCNNode] = []
            var bones: [SCNNode] = []
            if node.name ?? "" == "Armature" {
                bones.append(contentsOf: node.childNodes)
            }
            
            for bone in bones {
                var currBone = bone
                allBones.append(currBone)
                while currBone.childNodes.count > 0 {
                    
                    if currBone.childNodes[0].name!.contains("Bone") {
                        currBone = currBone.childNodes[0]
                    } else if currBone.childNodes.count >= 2 {
                        currBone = currBone.childNodes[1]
                    } else {
                        break
                    }
                    
                    allBones.append(currBone)
                }
            }
            
            initializeBones(bones: allBones)
        }
        
        return handNode
    }
    
    
    func initializeBones(bones: [SCNNode]) {

        // Initialize Structured Bones
        for bone in bones {
            
            guard let boneName = bone.name else {
                continue
            }
            guard boneName != "plant" else {
                continue
            }
            
            let (fingerIndex, segmentIndex, success) = fingerAndSegmentIndecesFromBoneName(boneName: boneName)
            
            if success {
                _rawBones.append(bone)
            }
            
            if segmentIndex == 1 && success {
                
                var currentBone = bone
                _structuredBones[fingerIndex-1].append(currentBone)
                _originalEulers[fingerIndex-1].append(currentBone.eulerAngles)
                
                while currentBone.childNodes.count > 0 {
                    if currentBone.childNodes[0].name!.contains("Bone") {
                        currentBone = currentBone.childNodes[0]
                    } else if currentBone.childNodes.count >= 2 {
                        currentBone = currentBone.childNodes[1]
                    } else {
                        break
                    }
                    
                    _structuredBones[fingerIndex-1].append(currentBone)
                    _originalEulers[fingerIndex-1].append(currentBone.eulerAngles)
                }
            }
        }
        
    }
    
    
    // fingerIndex, SegmentIndex, Success: indicates that the bone is part of the actual hand
    func fingerAndSegmentIndecesFromBoneName(boneName: String) -> (Int, Int, Bool) {
        var dotIndexOrNil = boneName.characters.index(of: ".")
        if dotIndexOrNil == nil {
            dotIndexOrNil = boneName.characters.index(of: "_")
        }
        guard let dotIndex = dotIndexOrNil else {
            return (-1, -1, false)
        }
        
        let dotSeparationIndex = boneName.index(dotIndex, offsetBy: 1)
        let bonePositionString = boneName.substring(from: dotSeparationIndex)
        
        let index1 = bonePositionString.index(bonePositionString.startIndex, offsetBy: 1)
        let index2 = bonePositionString.index(index1, offsetBy: 1)
        
        let fingerIndexString = bonePositionString.substring(to: index1)
        let segmentIndexString = bonePositionString.substring(with: Range(uncheckedBounds: (lower: index1, upper: index2)))
        
        let fingerIndex = Int(fingerIndexString)!
        let segmentIndex = Int(segmentIndexString)!
        
        return (fingerIndex, segmentIndex, true)
    }
    
    func isHandBone(boneName: String) -> Bool {
        let (_, segment, success) = fingerAndSegmentIndecesFromBoneName(boneName: boneName)
        if success && segment == 1 {
            return true
        }
        return false
    }
    
    func isThumb(boneName: String) -> Bool {
        let (finger, _, success) = fingerAndSegmentIndecesFromBoneName(boneName: boneName)
        if success && finger == 1 {
            return true
        }
        return false
    }
    
    
    func generateSoccerBall() {
        _soccerBall.position = SCNVector3Make(_handNode.position.x, _handNode.position.y+2, _handNode.position.z-2)
        scene.rootNode.addChildNode(_soccerBall)
    }
    
    // Grow the ball from hand from nothing. Set physics mode to kinematic
    func conjureSoccerBallFromHand(duration: TimeInterval, completion: (() -> Void)?) {
        
        _soccerBall.position = SCNVector3Make(_handNode.position.x, _handNode.position.y+2, _handNode.position.z-2)
        scene.rootNode.addChildNode(_soccerBall)
        
        _soccerBall.scale = SCNVector3Make(0.001, 0.001, 0.001)
        
        let growAction = SCNAction.scale(to: 1.0, duration: duration)
        
        _soccerBall.runAction(growAction) {
            completion?()
        }
    }
    
    func dropLightBalls() {
        let ballScene = SCNScene(named: "art.scnassets/lightBall.dae")!
        let parentLightBall = ballScene.rootNode.childNodes[0]
        parentLightBall.geometry?.firstMaterial?.diffuse.contents = NSColor.black
        
        for _ in 0 ..< 30 {
            let lightBall = parentLightBall.flattenedClone()
            let massRand = Random.randCGFloat(from: 0.3, to: 5)
            let scaleRand = Random.randCGFloat(from: 0.4, to: 1)
            let xRand = Random.randCGFloat(from: -30, to: 30)
            let yRand = 40 + Random.randCGFloat(from: -35, to: 35)
            let zRand = Random.randCGFloat(from: -50, to: 5)
            
            lightBall.scale = SCNVector3Make(scaleRand, scaleRand, scaleRand)
            lightBall.geometry = parentLightBall.geometry?.copy() as? SCNGeometry
            lightBall.geometry?.firstMaterial = parentLightBall.geometry?.firstMaterial?.copy() as? SCNMaterial
            lightBall.position = SCNVector3Make(0, 0, 0)
            let moveBall = SCNAction.move(to: SCNVector3Make(xRand, yRand, zRand), duration: 0)
            lightBall.runAction(moveBall)
            
            let emissionColor = NSColor.colorWithIndex(index: Random.randInt(from: 0, to: 8))
            lightBall.geometry?.firstMaterial?.emission.contents = emissionColor
            lightBall.physicsBody = SCNPhysicsBody.dynamic()
            lightBall.physicsBody?.restitution = 2
            lightBall.physicsBody?.mass = massRand
            lightBall.position = SCNVector3Make(0, CGFloat(10), 0)
            scene.rootNode.addChildNode(lightBall)
        }
    }
    
    func executeHandAnimations() {
        let instaFlip = SCNAction.rotateBy(x: 0, y: 0, z: -CGFloat(M_PI), duration: 0)
        let quickFlip = SCNAction.rotateBy(x: 0, y: 0, z: -CGFloat(M_PI), duration: 1.5)
        
        let flipHand = SCNAction.rotateBy(x: 0, y: 0, z: -CGFloat(M_PI), duration: 8)
        let flipForever = SCNAction.repeatForever(flipHand)
        let wait2 = SCNAction.wait(duration: 2)
//        let waitSequence = SCNAction.sequence([instaFlip, wait2, flipForever])
        let mainSequence = SCNAction.sequence([quickFlip])
        
        
        /////////////////////////////////////
        //rotate x is actually -y axis, y is x axis, z is z
        let slapBallRotate = SCNAction.rotateBy(x: -pi/8, y: -pi/4, z: 0, duration: 0.5)
        let slapBallUp = SCNAction.moveBy(x: -0.5, y: 4, z: 0, duration: 0.5)
        
        let slapActionsFwd = SCNAction.group([slapBallRotate, slapBallUp])
        let slapActionsBwd = SCNAction.group([slapBallRotate.reversed(), slapBallUp.reversed()])
        
        let slapSequence = SCNAction.sequence([slapActionsFwd, slapActionsBwd, wait2])
        
        naturalRestingHand(duration: 0, completion: nil)
        _handNode.runAction(mainSequence) {
            self.graspHand(duration: 1.5) {
                self.generateSoccerBall()
                self._soccerBall.scale = SCNVector3Make(0.001, 0.001, 0.001)
    
                self._soccerTimer = Timer.scheduledTimer(timeInterval: Double(self.kSoccerGrowDuration) * Double(self.kSoccerGrowIncrement), target: self, selector: #selector(self.growSoccerIncrementally), userInfo: nil, repeats: true)
                
                self.resetHandPosture(duration: 2, completion: {
                    
                    self.naturalRestingHand(duration: 0.5, completion: {
                        self._soccerBall.physicsBody = SCNPhysicsBody.dynamic()
                        
                        self._handNode.runAction(slapSequence, completionHandler: {
                            
                            // Pretend to drop the ball
                            let moveHandUpABit = SCNAction.moveBy(x: -0.2, y: 2, z: 0.3, duration: 0.8)
                            let quickFlipOpp = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(M_PI), duration: 0.8)
                            
                            let moveHandUpABitRotate = SCNAction.group([moveHandUpABit, quickFlipOpp])
                            
                            let moveHandDown = SCNAction.moveBy(x: 0.2, y: -6, z: -0.3, duration: 0.5)
                            let returnHand = SCNAction.move(to: self.kDefaultHandPosition, duration: 2)
                            let dropBallSequence = SCNAction.sequence([moveHandUpABitRotate, moveHandDown])
                            
                            self._handNode.runAction(dropBallSequence, completionHandler: {
                                self.dropLightBalls()
                                self._handNode.runAction(returnHand) {
                                    
                                    // Lastly, run continuous Open&Close hand
                                    self._handNode.runAction(quickFlip) {
                                        DispatchQueue.main.async {
                                            self.openCloseHand()
                                            self.tempTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.openCloseHand), userInfo: nil, repeats: true)
                                        }
                                    }
                                }
                            })
                        })
                    })
                    
                })
            }
            
        }
        
        
        
    }
    
    func graspHand(duration: Double, completion: (() -> Void)?) {
        // ThisIsRight (yaw, roll, pitch)
        let xRotate = SCNAction.rotateBy(x: pi/2, y: 0, z: 0, duration: duration)
        let xNegRotate = SCNAction.rotateBy(x: -pi/2, y: 0, z: 0, duration: duration)
        let yRotate = SCNAction.rotateBy(x: 0, y: pi/2, z: 0, duration: duration)
        let yNegRotate = SCNAction.rotateBy(x: 0, y: -pi/2, z: 0, duration: duration)
        let zRotate = SCNAction.rotateBy(x: 0, y: 0, z: pi/2, duration: duration)
        let zNegRotate = SCNAction.rotateBy(x: 0, y: 0, z: -pi/2, duration: duration)
        
        _structuredBones[0][1].runAction(xRotate)
        _structuredBones[0][2].runAction(xRotate)
        
        for bone in _rawBones {
            if !isHandBone(boneName: bone.name!) && !isThumb(boneName: bone.name!) {
                bone.runAction(zRotate, completionHandler: nil)
            }
        }
        
        let deadlineTime = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            completion?()
        }
    }
    
    func naturalRestingHand(duration: Double, completion: (() -> Void)?) {
        // ThisIsRight (yaw, roll, pitch)
        let xRotate = SCNAction.rotateBy(x: 0.2, y: 0, z: 0, duration: duration)
        let zRotate = SCNAction.rotateBy(x: 0, y: 0, z: 0.2, duration: duration)
        
        _structuredBones[0][1].runAction(xRotate)
        _structuredBones[0][2].runAction(xRotate)
        
        for bone in _rawBones {
            if !isHandBone(boneName: bone.name!) && !isThumb(boneName: bone.name!) {
                bone.runAction(zRotate, completionHandler: nil)
            }
        }
        
        let deadlineTime = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            completion?()
        }
    }
    
    
    func resetHandPosture(duration: Double, completion: (() -> Void)?) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        for i in 0..<_structuredBones.count {
            
            for j in 0..<_structuredBones[i].count {
                let originalEuler = _originalEulers[i][j]
                let bone = _structuredBones[i][j]
                bone.eulerAngles = originalEuler
            }
        }
        
        SCNTransaction.completionBlock = {
            if (completion != nil) {
                completion!()
            }
        
        }
        SCNTransaction.commit()
    }
    
    func growSoccerIncrementally() {
        
        _soccerBallScale += kSoccerGrowIncrement
        _soccerBall.scale = SCNVector3Make(_soccerBallScale, _soccerBallScale, _soccerBallScale)
        
        if _soccerBallScale >= 1 {
            _soccerTimer.invalidate()
            _soccerTimer = nil
            _soccerBallScale = 0.001
        }
    }
    
    
    func openCloseHand() {
        graspHand(duration: 3) {
            self.resetHandPosture(duration: 2, completion: nil)
        }
    }
    
    // MARK: Physics Contact Delegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
        
    }
    
    
    // MARK: Action Methods
    
    func rotateHandIndefinitely() {
        let rotation = SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 1, z: 1, duration:3))
        _handNode.runAction(rotation)
    }


}
