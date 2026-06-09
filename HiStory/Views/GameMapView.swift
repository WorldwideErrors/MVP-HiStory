import SwiftUI
import MapLibre

class CapturePointAnnotation: MLNPointAnnotation {
    var capturePointID: UUID
    var owner: CaptureState

    init(point: CapturePoint) {
        self.capturePointID = point.id
        self.owner = point.owner
        super.init()
        self.coordinate = point.coordinate
        self.title = point.name
    }

    required init?(coder: NSCoder) { fatalError() }
}

struct GameMapView: UIViewRepresentable {

    @ObservedObject var viewModel: GameMapViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setCenter(viewModel.playerLocation, zoomLevel: 15, animated: false)

        if let url = Bundle.main.url(forResource: "style", withExtension: "json") {
            mapView.styleURL = url
        }

        context.coordinator.mapView = mapView
        return mapView
    }

    func updateUIView(_ uiView: MLNMapView, context: Context) {
        context.coordinator.sync(viewModel: viewModel)
    }
}

// MARK: - Coordinator

extension GameMapView {

    class Coordinator: NSObject, MLNMapViewDelegate {

        var viewModel: GameMapViewModel
        weak var mapView: MLNMapView?

        private let sourceID      = "capture-points-source"
        private let labelLayerID  = "capture-points-labels"
        private var styleLoaded   = false
        private var annotations: [CapturePointAnnotation] = []

        init(viewModel: GameMapViewModel) {
            self.viewModel = viewModel
        }

        // MARK: Style loaded

        // Called once when the map style finishes loading
        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            styleLoaded = true
            addLabelLayer(to: style)
            refreshAnnotations()
        }

        // Called when the user taps an annotation
        func mapView(_ mapView: MLNMapView, didSelect annotation: MLNAnnotation) {
            guard let a = annotation as? CapturePointAnnotation else { return }
            viewModel.selectPoint(with: a.capturePointID)
        }

        private func addLabelLayer(to style: MLNStyle) {
            guard mapView != nil else { return }

            let source = MLNShapeSource(identifier: sourceID, shape: viewModel.featureCollection(), options: nil)
            style.addSource(source)

            let labels = MLNSymbolStyleLayer(identifier: labelLayerID, source: source)
            labels.text = NSExpression(forKeyPath: "name")
            labels.textFontSize = NSExpression(forConstantValue: 11)
            labels.textColor = NSExpression(forConstantValue: UIColor.white)
            labels.textOffset = NSExpression(forConstantValue: CGVector(dx: 0, dy: 2))
            labels.textHaloColor = NSExpression(forConstantValue: UIColor.black)
            labels.textHaloWidth = NSExpression(forConstantValue: 1)
            style.addLayer(labels)
        }

        // MARK: Annotations

        private func refreshAnnotations() {
            guard let mapView else { return }

            if !annotations.isEmpty {
                mapView.removeAnnotations(annotations)
            }
            
            mapView.logoView.isHidden = true
            mapView.attributionButton.isHidden = true

            annotations = viewModel.capturePoints.map { CapturePointAnnotation(point: $0) }
            mapView.addAnnotations(annotations)
        }

        // Return the correct asset image based on owner
        func mapView(_ mapView: MLNMapView, imageFor annotation: MLNAnnotation) -> MLNAnnotationImage? {
            guard let a = annotation as? CapturePointAnnotation else { return nil }

            let assetName: String
            switch a.owner {
            case .neutral:          assetName = "neutral-flag"
            case .capturedByNL: assetName = "dutch-flag"
            case .capturedByES:        assetName = "spain-flag"
            }

            guard let image = UIImage(named: assetName) else { return nil }

            let size = CGSize(width: 64, height: 64)
            let resized = UIGraphicsImageRenderer(size: size).image { _ in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
            return MLNAnnotationImage(image: resized, reuseIdentifier: assetName)
        }

        // MARK: Sync

        func sync(viewModel: GameMapViewModel) {
            self.viewModel = viewModel
            guard styleLoaded,
                  let style = mapView?.style,
                  let source = style.source(withIdentifier: sourceID) as? MLNShapeSource
            else { return }

            source.shape = viewModel.featureCollection()
            refreshAnnotations()
        }

        // MARK: Tap

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView else { return }
            let point = gesture.location(in: mapView)
            let hitArea = CGRect(x: point.x - 20, y: point.y - 20, width: 40, height: 40)

            let features = mapView.visibleFeatures(in: hitArea, styleLayerIdentifiers: [labelLayerID])

            if let hit = features.first,
               let idString = hit.attributes["id"] as? String,
               let id = UUID(uuidString: idString) {
                viewModel.selectPoint(with: id)
            }
        }
    }
}
