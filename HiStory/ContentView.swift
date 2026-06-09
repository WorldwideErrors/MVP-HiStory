import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = GameMapViewModel()

    var body: some View {
        TabView{
            // Map tab
            ZStack {
                GameMapView(viewModel: viewModel)
                    .ignoresSafeArea()
            }
            .sheet(item: $viewModel.selectedPoint) { point in
                CapturePointDetailView(point: point)
            }
            .tabItem {
                Label("Kaart", systemImage: "map.fill")
            }
            
            //Inventaris
            InventoryView()
                .tabItem {
                    Label("Voorraden", systemImage: "shippingbox.fill")
                }
            
            AugmentedView()
                .tabItem {
                    Label("AR", systemImage: "shippingbox.fill")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
