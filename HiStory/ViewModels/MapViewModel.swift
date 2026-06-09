import Foundation
import CoreLocation
import MapLibre
import Combine

class GameMapViewModel: ObservableObject {
    @Published var capturePoints: [CapturePoint] = []
    @Published var selectedPoint: CapturePoint?
    @Published var playerLocation: CLLocationCoordinate2D = .init(latitude: 51.5886, longitude: 4.7760)
    
    init() {
        loadPoints()
    }

    private func loadPoints() {
        capturePoints = [
            CapturePoint(
                name: "Grote Kerk",
                coordinate: .init(latitude: 51.5886, longitude: 4.7760),
                owner: .capturedByES,
                imageName: ""
            ),
            CapturePoint(
                name: "Kasteel van Breda",
                coordinate: .init(latitude: 51.59064, longitude: 4.776204),
                imageName: ""
            ),
            CapturePoint(
                name: "Spanjaardsgat",
                coordinate: .init(latitude: 51.5876, longitude: 4.7756),
                owner: .capturedByES,
                imageName: ""
            ),
            CapturePoint(
                name: "Begijnhof Breda",
                coordinate: .init(latitude: 51.5870, longitude: 4.7737),
                owner: .capturedByES,
                imageName: ""
            ),
            CapturePoint(
                name: "Ginnikenpoort",
                coordinate: .init(latitude: 51.5830, longitude: 4.7810),
                imageName: ""
            ),
            CapturePoint(
                name: "Haagpoort",
                coordinate: .init(latitude: 51.5900, longitude: 4.7715),
                imageName: ""
            )
        ]
    }

    func featureCollection() -> MLNShape {                          // ← MLN, not MGL
            let features = capturePoints.map { capturePoint -> MLNPointFeature in  // ← capturePoints (was capturePoint)
                let feature = MLNPointFeature()                         // ← MLN
                feature.coordinate = capturePoint.coordinate
                feature.attributes = [
                    "id": capturePoint.id.uuidString,
                    "name": capturePoint.name,
                    "owner": capturePoint.owner.rawValue
                ]
                return feature
            }
            return MLNShapeCollectionFeature(shapes: features)          // ← MLN
        }

    func selectPoint(with id: UUID){
        selectedPoint = capturePoints.first(where: { $0.id == id })
    }
    
}
