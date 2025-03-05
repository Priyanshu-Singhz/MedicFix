//
//  ProfileView.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 24/02/25.
//

import Foundation
import SwiftUI
import Firebase

struct ProfileView: View {
    @State private var profileImage: UIImage? = UIImage(named: "default_profile")
    @State private var isImagePickerPresented = false
    @State private var isEditing = false
    @State private var isLoading = false
    @State private var name = ""
    @State private var age = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var healthIssues: [String] = []
    @State private var newHealthIssue = ""
    @State private var profileImageURL: String = ""

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Modern gradient background
                LinearGradient(colors: [Color(hex: "4361EE"), Color(hex: "3A0CA3")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header with Title & Edit Button
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "arrow.left")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Text("My Profile")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { isEditing.toggle() }) {
                                Text(isEditing ? "Cancel" : "Edit")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // Profile Image with animation
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 150, height: 150)
                            
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 5)
                                    .animation(.spring(), value: profileImage)
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                               
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                            }

                            if isEditing {
                                Button(action: { isImagePickerPresented = true }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "4CC9F0"))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                }
                                .offset(x: 50, y: 50)
                                .transition(.scale)
                                .animation(.spring(), value: isEditing)
                            }
                        }
                        .padding(.top, 10)

                        // Profile Card
                        VStack(spacing: 20) {
                            // Section Header
                            HStack {
                                Text("Personal Information")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                if !isEditing {
                                    Image(systemName: "person.text.rectangle.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(.bottom, 5)
                            
                            // Input Fields
                            CustomTextField(icon: "person.fill", placeholder: "Full Name", text: $name, isEditing: isEditing)
                            
                            CustomTextField(icon: "calendar", placeholder: "Age", text: $age, isEditing: isEditing)
                                .keyboardType(.numberPad)
                            
                            CustomTextField(icon: "envelope.fill", placeholder: "Email Address", text: $email, isEditing: isEditing)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled(true)
                            
                            CustomTextField(icon: "phone.fill", placeholder: "Phone Number", text: $phone, isEditing: isEditing)
                                .keyboardType(.phonePad)
                            
                            // Health Issues Section
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Health Conditions")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Spacer()
                                    
                                    if !isEditing {
                                        Image(systemName: "heart.text.square.fill")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                if healthIssues.isEmpty {
                                    Text("No health conditions added")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(.vertical, 5)
                                } else {
                                    // Health tags layout
                                    FlowLayout(spacing: 10) {
                                        ForEach(healthIssues, id: \.self) { issue in
                                            HealthTag(text: issue, isEditing: isEditing) {
                                                removeHealthIssue(issue)
                                            }
                                        }
                                    }
                                }
                                
                                if isEditing {
                                    HStack(spacing: 10) {
                                        ZStack(alignment: .leading) {
                                            if newHealthIssue.isEmpty {
                                                Text("Add condition")
                                                    .foregroundColor(.white.opacity(0.6))
                                                    .padding(.leading, 15)
                                            }
                                            
                                            TextField("", text: $newHealthIssue)
                                                .padding(.horizontal, 15)
                                                .padding(.vertical, 12)
                                                .foregroundColor(.white)
                                                .font(.subheadline)
                                                .autocapitalization(.words)
                                        }
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.15))
                                        )
                                        
                                        Button(action: addHealthIssue) {
                                            Image(systemName: "plus.circle.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(Color(hex: "4CC9F0"))
                                        }
                                        .disabled(newHealthIssue.isEmpty)
                                        .opacity(newHealthIssue.isEmpty ? 0.5 : 1.0)
                                    }
                                }
                            }
                        }
                        .padding(25)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.3))
                                .blur(radius: 0.5)
                        )
                        .padding(.horizontal)

                        // Save Button
                        if isEditing {
                            Button(action: {
                                isLoading = true
                                saveUserProfile()
                            }) {
                                HStack {
                                    Text("Save Changes")
                                        .fontWeight(.bold)
                                    
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.leading, 5)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(hex: "4CC9F0"))
                                )
                                .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                            .disabled(isLoading)
                        }
                        
                        // Logout Button
                        if !isEditing {
                            Button(action: logout) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Logout")
                                }
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        .background(Color.white.opacity(0.1))
                                )
                                .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom, 30)
                }
                
            }
            
            .navigationBarHidden(true)
            .onAppear { fetchUserProfile() }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $profileImage, didFinishPicking: { image in
                    // New callback for when image is selected
                    if let image = image {
                        profileImage = image
                    }
                })
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // Add and Remove Health Issues
    func addHealthIssue() {
        if !newHealthIssue.isEmpty && !healthIssues.contains(newHealthIssue) {
            withAnimation {
                healthIssues.append(newHealthIssue)
                newHealthIssue = ""
            }
        }
    }

    func removeHealthIssue(_ issue: String) {
        withAnimation {
            healthIssues.removeAll { $0 == issue }
        }
    }
    
    // Logout function
    func logout() {
        do {
            try Auth.auth().signOut()
            // Navigate to login screen or perform other logout actions
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

// **🔹 Health Tag Component**
struct HealthTag: View {
    var text: String
    var isEditing: Bool
    var onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 5) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, isEditing ? 8 : 12)
                .padding(.vertical, 8)
            
            if isEditing {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14))
                }
                .padding(.trailing, 8)
            }
        }
        .background(
            Capsule()
                .fill(LinearGradient(
                    colors: [Color(hex: "4361EE").opacity(0.5), Color(hex: "4CC9F0").opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

// **🔹 Flow Layout for Health Tags**
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
        }
        
        height = y + maxHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
        }
    }
}

// **🔹 Custom TextField Component**
struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isEditing: Bool
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)
            
            if isEditing {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .font(.body)
                    .keyboardType(keyboardType)
            } else {
                Text(text.isEmpty ? placeholder : text)
                    .foregroundColor(text.isEmpty ? .white.opacity(0.6) : .white)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// **🔹 Firebase Functions**
extension ProfileView {
    func fetchUserProfile() {
        isLoading = true
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid ?? "defaultUser"

        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                name = data?["name"] as? String ?? ""
                age = data?["age"] as? String ?? ""
                email = data?["email"] as? String ?? ""
                phone = data?["phone"] as? String ?? ""
                healthIssues = data?["healthIssues"] as? [String] ?? []
                profileImageURL = data?["profileImageURL"] as? String ?? ""
                
                // Load image from URL if available
                if !profileImageURL.isEmpty {
                    loadImageFromURL(profileImageURL)
                }
            }
            isLoading = false
        }
    }
    
    // New function to load image from URL
    func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }.resume()
    }

    func saveUserProfile() {
        // Check if there's a new profile image to upload
        if let image = profileImage, image != UIImage(named: "default_profile") {
            // Upload the image to Firebase Storage
            StorageManager.shared.uploadProfileImage(image) { result in
                switch result {
                case .success(let imageURL):
                    // Store image URL in Firestore along with other user data
                    self.profileImageURL = imageURL
                    self.saveUserDataToFirestore()
                    
                case .failure(let error):
                    print("Error uploading profile image: \(error.localizedDescription)")
                    // Continue saving other user data even if image upload fails
                    self.saveUserDataToFirestore()
                }
            }
        } else {
            // No new image to upload, just save user data
            self.saveUserDataToFirestore()
        }
    }
    
    // Helper method to save user data to Firestore
    private func saveUserDataToFirestore() {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid ?? "defaultUser"
        
        var userData: [String: Any] = [
            "name": name,
            "age": age,
            "email": email,
            "phone": phone,
            "healthIssues": healthIssues
        ]
        
        // Add profile image URL if it exists
        if !profileImageURL.isEmpty {
            userData["profileImageURL"] = profileImageURL
        }

        db.collection("users").document(userID).setData(userData, merge: true) { error in
            isLoading = false
            if error == nil {
                isEditing = false
            } else {
                print("Error saving user data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

// Image Picker for Profile Picture
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var didFinishPicking: ((UIImage?) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
                parent.didFinishPicking?(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
                parent.didFinishPicking?(originalImage)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
