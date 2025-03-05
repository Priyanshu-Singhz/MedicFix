//
//  SceneDelegate.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 19/02/25.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseAuth

class SceneDelegate: UIResponder,UIApplicationDelegate, UIWindowSceneDelegate {
    var window: UIWindow?

        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            let isLoggedIn = Auth.auth().currentUser != nil
            
            let contentView = isLoggedIn ?
                AnyView(MedicationListView()) :
                AnyView(LoginView())

            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: contentView)
                self.window = window
                window.makeKeyAndVisible()
            }
        }
}
