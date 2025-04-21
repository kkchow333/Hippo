//import SwiftUI
//import RealityKit
//import ARKit
//
//struct ImageDetectionImmersiveView: View {
//    @State private var arView = ARView(frame: .zero)
//
//    var body: some View {
//        RealityView { content in
//            content.add(arView)
//
//            // Load image anchors
//            guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "VitaminImages", bundle: .main) else {
//                print("Failed to load reference images")
//                return
//            }
//
//            let config = ARWorldTrackingConfiguration()
//            config.detectionImages = referenceImages
//            config.maximumNumberOfTrackedImages = 1
//            arView.session.run(config)
//            arView.session.delegate = ImageAnchorCoordinator(arView: arView)
//        }
//    }
//}
//
//class ImageAnchorCoordinator: NSObject, ARSessionDelegate {
//    let arView: ARView
//
//    init(arView: ARView) {
//        self.arView = arView
//    }
//
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        for anchor in anchors {
//            guard let imageAnchor = anchor as? ARImageAnchor else { continue }
//
//            // Create anchor entity at image position
//            let anchorEntity = AnchorEntity(world: imageAnchor.transform)
//
//            // Highlight the image with a glowing plane
//            let highlightPlane = ModelEntity(
//                mesh: .generatePlane(width: 0.1, height: 0.1),
//                materials: [SimpleMaterial(color: .yellow.withAlphaComponent(0.3), isMetallic: false)]
//            )
//            highlightPlane.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
//            anchorEntity.addChild(highlightPlane)
//
//            // Add the SwiftUI ReminderView as a volume
//            let volume = VolumeView {
//                ReminderView(
//                    name: "Vitamin Bottle",
//                    imageURL: URL(string: "https://example.com/image.jpg")!,
//                    onDismiss: { print("Dismissed") }
//                )
//            }
//            .frame(width: 400, height: 200)
//
//            let volumeEntity = ModelEntity()
//            volumeEntity.components.set(VolumeComponent(view: volume))
//            volumeEntity.position = [0, 0.1, 0] // Offset above the image
//            anchorEntity.addChild(volumeEntity)
//
//            arView.scene.addAnchor(anchorEntity)
//        }
//    }
//}
