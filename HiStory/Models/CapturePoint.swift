import CoreLocation

enum CaptureState: String {
    case neutral
    case capturedByNL
    case capturedByES
    
    var label: String {
            switch self {
            case .neutral:      return "Neutraal"
            case .capturedByNL: return "Nederland"
            case .capturedByES: return "Spanje"
            }
        }
}

struct CapturePoint: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D

    var owner: CaptureState = .neutral
    var progress: Double = 0.0   // 0 → 1 capture progress
    
    var imageName: String
}
