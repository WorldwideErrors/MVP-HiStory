import SwiftUI

struct CapturePointDetailView: View {
    let point: CapturePoint

    var body: some View {
        VStack(spacing: 16) {
            Text(point.name)
                .font(.title)
                .bold()

            Text("Owner: \(point.owner.label)")
                .foregroundStyle(.secondary)

            ProgressView(value: point.progress)
                .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.medium])   // half-screen sheet
    }
}
