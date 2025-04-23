//
//  SceneDelegate.swift
//  Stills
//
//  Created by Esther Kim on 4/22/25.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?  // Stores reference to your app's main window

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // This is called when your app creates a new scene
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Create your main view
        let contentView = ReminderPlacementView()
        
        // Create a window and set up its root view controller
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
    }
}
