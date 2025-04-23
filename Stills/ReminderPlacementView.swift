import SwiftUI
import RealityKit

struct ReminderPlacementView: View {
    @State private var showReminderView = false
    @State private var dragOffset: CGSize = .zero
    @GestureState private var dragState = false
    
    var body: some View {
        ZStack {
            // Background content
            RealityView { content in
                // Create a floor anchor for spatial awareness
                let anchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: [0.5, 0.5]))
                content.add(anchor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Main content
            if showReminderView {
                ReminderView(
                    name: "New Reminder",
                    imageURL: URL(string: "https://example.com/placeholder.jpg")!,
                    onDismiss: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showReminderView = false
                        }
                    },
                    showProfileImage: false
                )
                .frame(width: 800)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showReminderView = true
                    }
                } label: {
                    Image(systemName: "hand.point.up.fill")
                        .font(.system(size: 30))
                }
                .frame(width: 100, height: 100, alignment: .topLeading)
                .position(x: 50, y: 0) // Align with top of window
            }
        }
        .frame(width: showReminderView ? 800 : 100, height: showReminderView ? 600 : 100)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showReminderView)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    dragOffset = .zero
                }
        )
        .offset(dragOffset)
    }
}

struct TransparentBackground: ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        Color.clear
    }
}

struct ReminderCreationView: View {
    let position: SIMD3<Float>
    let onComplete: (Reminder) -> Void
    
    @State private var name: String = ""
    @State private var imageURL: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder Details") {
                    TextField("Name", text: $name)
                    TextField("Image URL", text: $imageURL)
                }
            }
            .navigationTitle("Create Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        if let url = URL(string: imageURL) {
                            let reminder = Reminder(name: name, imageURL: url)
                            onComplete(reminder)
                        }
                    }
                    .disabled(name.isEmpty || imageURL.isEmpty)
                }
            }
        }
    }
}

struct Reminder {
    let name: String
    let imageURL: URL
}

#Preview {
    ReminderPlacementView()
        .frame(width: 100, height: 100)
}
