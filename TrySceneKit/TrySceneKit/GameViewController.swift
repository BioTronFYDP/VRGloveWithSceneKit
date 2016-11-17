//
//  GameViewController.swift
//  TrySceneKit
//
//  Created by Si Te Feng on 11/6/16.
//  Copyright (c) 2016 Technochimera. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
     
    var handNode: SCNNode = SCNNode()
    
    var rawBones: [SCNNode]!
    var structuredBones: [[SCNNode]]!
    
    //Temp
    var tempTimer: Timer!
    var prevPositions : [SCNVector3] = []
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the hand node
        let handScene = SCNScene(named: "art.scnassets/hand1.dae")!
        let hand = handScene.rootNode
        
        for node in hand.childNodes {
            
            guard node.camera == nil && node.light == nil else {
                continue
            }
            
            handNode.addChildNode(node)
            
            guard let bones = node.skinner?.bones else{
                continue
            }
            
            initializeBones(bones: bones)
            
        }
        scene.rootNode.addChildNode(handNode)
        
        let adjustRotation = SCNAction.rotateBy(x: CGFloat(M_PI/2), y: 0, z: CGFloat(-M_PI/1.85), duration:0)
        handNode.runAction(adjustRotation)
        rotateIndefinitely()
        
        //Try
        tempTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(GameViewController.morphHand), userInfo: nil, repeats: true)
        
        
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
    
    
    func initializeBones(bones: [SCNNode]) {
        rawBones = bones
        
        for i in 0 ..< rawBones.count {
            prevPositions.append(rawBones[i].position)
        }
        
    }
    
    func morphHand() {
        for i in 0..<rawBones.count {
            let bone = rawBones[i]
            let prevPosition:SCNVector3 = prevPositions[i]
            
            let randNumDouble = Double(arc4random() % 100) / 100.0 * 1.0 - 0.5
            let randNum = CGFloat(randNumDouble)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1
            bone.position = SCNVector3Make(prevPosition.x + randNum, prevPosition.y + randNum, prevPosition.z + randNum)
            SCNTransaction.commit()
        }
    }

    
    
    func rotateIndefinitely() {
        let rotation = SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 1, z: 1, duration:3))
        handNode.runAction(rotation)
    }
    
    
    
    
    
}







