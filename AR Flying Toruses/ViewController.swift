//
//  ViewController.swift
//  AR Flying Toruses
//
//  Created by Denis Bystruev on 23/09/2018.
//  Copyright © 2018 Denis Bystruev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var visualizeTrajectory = false
    
    // Initial position of the flying ring
    var ringStartPosition: SCNVector3!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Create and add lights to the scene
        createLights(positions: [/*SCNVector3(0, 10, 10)*/]).forEach { node in scene.rootNode.addChildNode(node)
        }
        
        // Add a plane to the scene
        scene.rootNode.addChildNode(createPlane(0, -7, 0))
        
        // Add a torus to the scene
        let ring = createRing(0, -2, -10, color: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1))
        scene.rootNode.addChildNode(ring)
        
        if visualizeTrajectory {
            let startRing = createRing(
                ringStartPosition.x,
                ringStartPosition.y,
                ringStartPosition.z,
                color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            )
            scene.rootNode.addChildNode(startRing)
            
            for time in stride(from: 0.0, to: 1.0, by: 0.1) {
                scene.rootNode.addChildNode(positionVisualisation(at: time))
            }
        }
        
        // Animate the flying ring forever
        let interval = TimeInterval(Int.max)
        
        ring.runAction(
            SCNAction.customAction(duration: interval) {
                node, elapsedTime in
                node.position = self.getPosition(at: TimeInterval(elapsedTime))
            }
        )
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Configure the view
        sceneView.backgroundColor = UIColor.black
    }
    
    // Create lights for the scene
    func createLights(positions: [SCNVector3]) -> [SCNNode] {
        var lightNodes = [SCNNode]()
        
        // create and add lights to the scene
        positions.forEach { position in
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = .omni
            lightNode.position = position
            lightNodes.append(lightNode)
        }
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        lightNodes.append(ambientLightNode)
        
        return lightNodes
    }
    
    // Create a plane for the scene
    func createPlane(_ x: Float, _ y: Float, _ z: Float) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/Earth Texture")
        
        let plane = SCNPlane(width: 250, height: 250)
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x -= Float.pi / 2
        planeNode.position = SCNVector3(x, y, z)
        
        return planeNode
    }
    
    // Add a torus to the scene
    func createRing(
        _ x: Float,
        _ y: Float,
        _ z: Float,
        color: UIColor
    ) -> SCNNode {
        
        let gold = SCNMaterial()
        gold.diffuse.contents = color
        
        let torus = SCNTorus(ringRadius: 1, pipeRadius: 0.25)
        torus.materials = [gold]
        
        let torusNode = SCNNode(geometry: torus)
        //        torusNode.eulerAngles.x += Float.pi / 2
        ringStartPosition = SCNVector3(x, y, z)
        torusNode.position = ringStartPosition
        
        let light = SCNLight()
        light.type = .omni
        torusNode.light = light
        
        return torusNode
    }
    
    // Return a position on 8 trajectory
    func getPosition(at time: TimeInterval) -> SCNVector3 {
        let radius = Float(50)
        let t = time - 1.05 * .pi
        let x = radius * Float(cos(t / 2))
        let z = radius * Float(sin(t))
        
        // rotate by phi angle and add start position
        let phi = Float.pi / 8
        let newX = x * cos(phi) + z * sin(phi) + ringStartPosition.x
        let newZ = -x * sin(phi) + z * cos(phi) + ringStartPosition.z
        
//        print(#function, x, z)
        
        return SCNVector3(newX, ringStartPosition.y, newZ)
    }
    
    func positionVisualisation(at time: TimeInterval) -> SCNNode {
        let blueColor = SCNMaterial()
        blueColor.diffuse.contents = UIColor.blue
        
        let box = SCNBox(
            width: 0.5,
            height: 0.5,
            length: 0.5,
            chamferRadius: 0
        )
        box.materials = [blueColor]
        
        let node = SCNNode(geometry: box)
        node.position = getPosition(at: time)
        
        return node
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
