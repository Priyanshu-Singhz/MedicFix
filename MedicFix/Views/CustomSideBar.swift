//
//  CustomSideBar.swift
//  MedicFix
//
//  Created by Zignuts Technolab on 24/02/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var isSidebarVisible: Bool
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            // Background Overlay (Click to close)
            if isSidebarVisible {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isSidebarVisible = false
                        }
                    }
            }
            
            // Sidebar Content
            VStack(alignment: .leading, spacing: 20) {
                // App Logo and Name
                HStack {
                    Image(uiImage: UIImage(named: "playstore")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.top, 40)
                    
                    Text("MedicFix")
                        .font(.title2)
                        .bold()
                        .padding(.top, 40)
                }
                .padding(.leading)

                // Sidebar Options
                NavigationLink(destination: ProfileView()) {
                    SidebarItem(icon: "person.crop.circle", title: "Profile")
                }

                NavigationLink(destination: SettingsView()) {
                    SidebarItem(icon: "gear", title: "Settings")
                }
                
                Divider()
                
                // Logout Button
                Button(action: {
                    authManager.signOut()
                    isSidebarVisible = false
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Sign Out")
                            .bold()
                    }
                    .foregroundColor(.red)
                    .padding()
                }

                Spacer()
            }
            .frame(width: 250)
            .background(Color(.systemGray6))
            .edgesIgnoringSafeArea(.vertical)
            .offset(x: isSidebarVisible ? 0 : -250)
            .animation(.easeInOut(duration: 0.3), value: isSidebarVisible)
        }
    }
}

// Sidebar Item View Component
struct SidebarItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
            Text(title)
                .fontWeight(.bold)
        }
        .padding(.vertical, 10)
        .foregroundColor(.black)
        .padding(.horizontal)
    }
}

// Updated Settings View with actual functionality
struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("reminderSound") private var reminderSound = "Default"
    @State private var showResetConfirmation = false
    
    var body: some View {
        List {           Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                
                if notificationsEnabled {
                    NavigationLink(destination: Text("Configure your notification preferences").padding()) {
                        Text("Notification Preferences")
                    }
                }
                
                
            }
            
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $darkModeEnabled)
            }
            
            Section(header: Text("Sounds")) {
                Picker("Reminder Sound", selection: $reminderSound) {
                    Text("Default").tag("Default")
                    Text("Chime").tag("Chime")
                    Text("Bell").tag("Bell")
                    Text("Vibrate Only").tag("Vibrate")
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            Section {
                Button(action: { showResetConfirmation = true }) {
                    HStack {
                        Text("Reset All Settings")
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .alert(isPresented: $showResetConfirmation) {
            Alert(
                title: Text("Reset Settings"),
                message: Text("Are you sure you want to reset all settings to default values?"),
                primaryButton: .destructive(Text("Reset")) {
                    // Reset all settings
                    notificationsEnabled = true
                    darkModeEnabled = false
                    reminderSound = "Default"
                },
                secondaryButton: .cancel()
            )
        }
    }
}
