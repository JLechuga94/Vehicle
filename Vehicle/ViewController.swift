//
//  ViewController.swift
//  Floor_lava
//
//  Created by Julian Lechuga Lopez on 20/6/18.
//  Copyright © 2018 Julian Lechuga Lopez. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func createConcrete(planeAnchor: ARPlaneAnchor) -> SCNNode{
        let planeAnchorPosition = planeAnchor.center
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        concreteNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Concrete")
        concreteNode.geometry?.firstMaterial?.isDoubleSided = false
        concreteNode.eulerAngles = SCNVector3(Float(-90.degreesToRadians),0,0)
        concreteNode.position = SCNVector3(planeAnchorPosition.x, planeAnchorPosition.y, planeAnchorPosition.z)
        let staticBody = SCNPhysicsBody.static()
        concreteNode.physicsBody = staticBody
        return concreteNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
        print("new flat surface detected, new ARPlaneAnchor added")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes {(childNode, _) in
            childNode.removeFromParentNode()
        }
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
        print("*************")
        print("updating floors anchor")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes {(childNode, _) in
            childNode.removeFromParentNode()
        }
    }


    @IBAction func addCar(_ sender: Any) {
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
        
        let scene = SCNScene(named: "Car-Scene.scn")
        let frame = (scene?.rootNode.childNode(withName: "frame", recursively: false))!
//        let box = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
//        box.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        frame.position = currentPositionOfCamera
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: frame, options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        frame.physicsBody = body
        self.sceneView.scene.rootNode.addChildNode(frame)
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
