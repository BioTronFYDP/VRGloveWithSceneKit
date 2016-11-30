//
//  GameViewControllerForHand1.swift
//  Symmetra
//
//  Created by Si Te Feng on 11/20/16.
//  Copyright © 2016 Technochimera. All rights reserved.
//

import SceneKit
import QuartzCore


class GameViewControllerForHand1: NSViewController, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var gameView: GameView!
    
    private var scene = SCNScene()
    private var _handNode: SCNNode = SCNNode()
    
    private var _rawBones: [SCNNode] = []
    private var _structuredBones: [[SCNNode]] = Array(repeating: [], count: 5)
    private var _originalEulers: [[SCNVector3]] = Array(repeating: [], count: 5)
    
    
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
        cameraNode.position = SCNVector3(x: 0, y: 12, z: 8)
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
        _handNode.position = SCNVector3Make(0, 6, 0)
        // (yaw, pitch, roll)
        _handNode.eulerAngles = SCNVector3Make(-CGFloat(M_PI/4), 0, CGFloat(M_PI/2))
        
        executeHandAnimations()
        
        
        // Add lightball
        addLightBalls()
        
        //and orange
        let orangeScene = SCNScene(named: "art.scnassets/orange.dae")!
        let orange = orangeScene.rootNode.childNodes[0]
        orange.scale = SCNVector3Make(1,1,1)
        orange.physicsBody = SCNPhysicsBody.dynamic()
        orange.position = SCNVector3Make(0, 14, 0)
        scene.rootNode.addChildNode(orange)
        
        
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
        let handScene = SCNScene(named: "art.scnassets/hand2.scn")!
        let hand = handScene.rootNode
        
        let bodyType = SCNPhysicsBodyType.kinematic
        let shape = SCNPhysicsShape(node: hand, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        hand.physicsBody = SCNPhysicsBody(type: bodyType, shape: shape)
        
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
                    currBone = currBone.childNodes[0]
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
            
            let (fingerIndex, segmentIndex, success) = fingerAndSegmentIndecesFromBoneName(boneName: boneName)
            
            if success {
                _rawBones.append(bone)
            }
            
            if segmentIndex == 1 && success {
                
                var currentBone = bone
                _structuredBones[fingerIndex-1].append(currentBone)
                _originalEulers[fingerIndex-1].append(currentBone.eulerAngles)
                
                while currentBone.childNodes.count > 0 {
                    currentBone = currentBone.childNodes[0]
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
    
    func addLightBalls() {
        let ballScene = SCNScene(named: "art.scnassets/lightBall.dae")!
        let parentLightBall = ballScene.rootNode.childNodes[0]
        parentLightBall.geometry?.firstMaterial?.diffuse.contents = NSColor.black
        
        for _ in 0 ..< 100 {
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
        
        let flipHand = SCNAction.rotateBy(x: 0, y: 0, z: -CGFloat(M_PI), duration: 8)
        let flipForever = SCNAction.repeatForever(flipHand)
        _handNode.runAction(flipForever)
        
        
        tempTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(GameViewControllerForHand1.timersUp), userInfo: nil, repeats: true)
        
    }
    
    func closeHand(duration: Double, completion: (() -> Void)?) {
        
        let xRotate = SCNAction.rotateBy(x: pi/2, y: 0, z: 0, duration: duration)
        let xNegRotate = SCNAction.rotateBy(x: -pi/2, y: 0, z: 0, duration: 5)
        let yRotate = SCNAction.rotateBy(x: 0, y: pi/2, z: 0, duration: duration)
        let yNegRotate = SCNAction.rotateBy(x: 0, y: -pi/2, z: 0, duration: 5)
        let zRotate = SCNAction.rotateBy(x: 0, y: 0, z: pi/2, duration: 5)
        let zNegRotate = SCNAction.rotateBy(x: 0, y: 0, z: -pi/2, duration: duration)
        
        _structuredBones[0][1].runAction(xRotate)
        _structuredBones[0][2].runAction(yRotate)
        
        for bone in _rawBones {
            if !isHandBone(boneName: bone.name!) && !isThumb(boneName: bone.name!) {
                bone.runAction(yRotate, completionHandler: completion)
            }
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
    
    func timersUp() {
        closeHand(duration: 3) {
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
