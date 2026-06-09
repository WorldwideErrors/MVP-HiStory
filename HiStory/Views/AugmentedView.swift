import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Enable world tracking
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        
        // Load your USDZ model
        if let airplane = try? ModelEntity.load(named: "solar_panels.usdz") {
            
            let anchor = AnchorEntity(plane: .horizontal)
            anchor.addChild(airplane)
            
            arView.scene.addAnchor(anchor)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct AugmentedView: View {
    var body: some View {
        ARViewContainer()
            .ignoresSafeArea()
    }
}
