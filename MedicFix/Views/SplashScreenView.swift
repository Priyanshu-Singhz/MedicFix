//
//  SplashScreenView.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 24/02/25.
//

import SwiftUI
import Lottie

struct SplashScreenView: View {
    @State private var animateGradient = false
    @State private var navigateToNextScreen = false
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.239, green: 0.674, blue: 0.968, alpha: 1)),
                        Color(#colorLiteral(red: 0.219, green: 0.007, blue: 0.854, alpha: 1))
                    ]),
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
                
                // Lottie Animation in Center
                LottieView(name: "SplashLottie", loopMode: .playOnce)
                    .frame(width: 200, height: 200)
                
                // Navigation Trigger
                NavigationLink(
                    destination: authManager.isLoggedIn
                        ? AnyView(MedicationListView().environmentObject(authManager).navigationBarBackButtonHidden(true))
                        : AnyView(LoginView().environmentObject(authManager).navigationBarBackButtonHidden(true)),
                    isActive: $navigateToNextScreen
                ) {
                    EmptyView()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    navigateToNextScreen = true
                }
            }
            .navigationBarHidden(true) // Hides navigation bar completely
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures correct behavior on iPads
    }
}
struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.play()
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
