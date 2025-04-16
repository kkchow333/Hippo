//
//  ContentView.swift
//  Stills
//
//  Created by Kaitlin Chow on 4/15/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @State private var snappedItem = 0.0
    @State private var draggingItem = 0.0
    @State private var activeIndex: Int = 0
    @State private var selectedProfile: Int? = nil
    
    let xDistance: CGFloat = 150
    let profiles = ProfileInfo.mockProfiles()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.clear.edgesIgnoringSafeArea(.all)
                
                // Carousel
                ZStack(alignment: .center) {
                    ForEach(0..<profiles.count, id: \.self) { index in
                        let dist = distance(index)
                        let isSelected = selectedProfile == index
                        
                        ProfileCarousel(
                            name: profiles[index].name,
                            imageURL: profiles[index].imageURL,
                            id: index,
                            isSelected: isSelected,
                            distance: dist
                        )
                        .frame(width: 200, height: 200)
                        .offset(x: selectedProfile == nil ? offset(index) : (selectedProfile == index ? 0 : offset(index) * 2))
                        .zIndex(isSelected ? 1 : (1.0 - abs(dist) * 0.1))
                        .opacity(selectedProfile == nil ? 1 : 0)  // Hide all profiles when one is selected
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                if selectedProfile == index {
                                    selectedProfile = nil
                                } else {
                                    draggingItem = Double(index)
                                    snappedItem = Double(index)
                                    selectedProfile = index
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Profile Detail Pop-up
                if let selected = selectedProfile {
                    ReminderView(
                        name: profiles[selected].name,
                        imageURL: profiles[selected].imageURL,
                        onDismiss: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedProfile = nil
                            }
                        }
                    )
                    .zIndex(2)  // Ensure pop-up is always on top
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard selectedProfile == nil else { return }
                        draggingItem = snappedItem + value.translation.width / 100
                    }
                    .onEnded { value in
                        guard selectedProfile == nil else { return }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            draggingItem = snappedItem + value.predictedEndTranslation.width / 100
                            draggingItem = round(draggingItem).remainder(dividingBy: Double(profiles.count))
                            snappedItem = draggingItem
                            
                            activeIndex = profiles.count + Int(draggingItem)
                            if activeIndex > profiles.count || Int(draggingItem) >= 0 {
                                activeIndex = Int(draggingItem)
                            }
                        }
                    }
            )
        }
        .background(.clear)
    }
    
    func distance(_ item: Int) -> Double {
        return (draggingItem - Double(item)).remainder(dividingBy: Double(profiles.count))
    }
    
    func offset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(profiles.count) * distance(item)
        return sin(angle) * Double(xDistance)
    }
}

#Preview(windowStyle: .plain) {
    ContentView()
        .environment(AppModel())
}
