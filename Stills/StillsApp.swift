//
//  StillsApp.swift
//  Stills
//
//  Created by Kaitlin Chow on 4/15/25.
//

import SwiftUI

@main
struct StillsApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            //ContentView()
            ReminderPlacementView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
