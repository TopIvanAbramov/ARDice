//
//  ViewController.swift
//  FistARApp
//
//  Created by Иван Абрамов on 27.06.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var allDiceNodes : [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the view's delegate
        
        sceneView.delegate = self
        
        sceneView.automaticallyUpdatesLighting = true
    }
    
    
//    MARK: - DiceMethods
    
    func addDiceNode(withLocation location: SCNVector3) -> SCNNode? {
        let diceScene = SCNScene(named: "art.scnassets/dice.scn")!

        if let node = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
           node.position = location

           sceneView.scene.rootNode.addChildNode(node)
           
           allDiceNodes.append(node)
           
           rollDice(withNode: node)
            
            return node
        }
        
        return nil
    }
    
    
    func rollDice(withNode node: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * Float.pi / 2
        let randomZ = Float(arc4random_uniform(4) + 1) * Float.pi / 2
        let randomY = Float(arc4random_uniform(4) + 1) * Float.pi / 2
        
        node.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 5), y: CGFloat(randomY * 5), z: CGFloat(randomZ * 5), duration: 0.5)
        )
    }
    
    func rollAllDices() {
        for node in allDiceNodes {
            rollDice(withNode: node)
        }
    }
    
//    MARK: - ViewControllerCycleEvents
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          if let touch = touches.first {
              let location = touch.location(in: sceneView)
              let results = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
              
              if let result = results.first {
                  let location = SCNVector3(
                      result.worldTransform.columns.3.x,
                      result.worldTransform.columns.3.y,
                      result.worldTransform.columns.3.z
                  )
                     
                  guard let node = addDiceNode(withLocation: location) else { return }
                  
                  allDiceNodes.append(node)
                  
                  rollDice(withNode: node)
              }
          }
      }
    
    
//    MARK: - ARSCNViewDelegateMethods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        }
    }
    
    @IBAction func refreshTapped(sender: UIBarButtonItem) {
        rollAllDices()
    }
    
    @IBAction func removeTapped(sender: UIBarButtonItem) {
        for node in allDiceNodes {
            node.removeFromParentNode()
        }
    }
}
