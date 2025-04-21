////
////  ARObjectDetectionViewController.swift
////  Stills
////
////  Created by Esther Kim on 4/20/25.
////
//import UIKit
//import ARKit
//
//class ARObjectDetectionViewController: UIViewController, ARSCNViewDelegate {
//    var sceneView: ARSCNView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        sceneView = ARSCNView(frame: view.bounds)
//        sceneView.delegate = self
//        sceneView.autoenablesDefaultLighting = true
//        view.addSubview(sceneView)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "ARResources", bundle: nil) else {
//            fatalError("Missing AR reference objects")
//        }
//
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.detectionObjects = referenceObjects
//        sceneView.session.run(configuration)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        sceneView.session.pause()
//    }
//
//    // Optional: Handle object detection
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        if let objectAnchor = anchor as? ARObjectAnchor {
//            let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//            box.firstMaterial?.diffuse.contents = UIColor.red
//            let boxNode = SCNNode(geometry: box)
//            node.addChildNode(boxNode)
//        }
//    }
//}
//
