//
//  StorageManager.swift
//  MedicFix
//
//  Created by Zignuts Technolab on 19/02/25.
//
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()
    
    private lazy var db: Firestore = {
        guard FirebaseApp.app() != nil else {
            fatalError("Firebase has not been configured yet.")
        }
        print("Firestore Access Successful!")
        return Firestore.firestore()
    }()
    
    private lazy var storage: Storage = {
        return Storage.storage()
    }()
    
    private var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var medicationsCollection: CollectionReference? {
        guard let userId = currentUserId else { return nil }
        return db.collection("users").document(userId).collection("medications")
    }
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "com.medicfix", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "com.medicfix", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])))
            return
        }
        
        let storageRef = storage.reference().child("profile_images/\(userId).jpg")
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading profile image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    let error = NSError(domain: "com.medicfix", code: 404, userInfo: [NSLocalizedDescriptionKey: "Download URL is nil"])
                    completion(.failure(error))
                    return
                }
                
                completion(.success(downloadURL.absoluteString))
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(percentComplete)%")
        }
    }
    
    func loadMedications(completion: @escaping ([Medication]) -> Void) {
        guard let collection = medicationsCollection else {
            completion([])
            return
        }
        
        collection.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error loading medications: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let medications = documents.compactMap { document -> Medication? in
                let data = document.data()
                
                guard let name = data["name"] as? String,
                      let dosage = data["dosage"] as? String,
                      let timeStamp = data["timeOfDay"] as? Timestamp,
                      let daysOfWeek = data["daysOfWeek"] as? [Int],
                      let isActive = data["isActive"] as? Bool else {
                    return nil
                }
                
                let timeOfDay = timeStamp.dateValue()
                let notes = data["notes"] as? String
                let fromDate = (data["fromDate"] as? Timestamp)?.dateValue() ?? Date()
                let toDate = (data["toDate"] as? Timestamp)?.dateValue() ?? Date()
                
                return Medication(
                    id: UUID(uuidString: document.documentID) ?? UUID(),
                    name: name,
                    dosage: dosage,
                    timeOfDay: timeOfDay,
                    notes: notes,
                    daysOfWeek: daysOfWeek,
                    fromDate: fromDate,
                    toDate: toDate,
                    isActive: isActive
                )
            }
            
            completion(medications)
        }
    }

    
    func addMedication(_ medication: Medication, to medications: [Medication], completion: @escaping ([Medication]) -> Void) {
        guard let collection = medicationsCollection else {
            completion(medications)
            return
        }
        
        let docData: [String: Any] = [
            "name": medication.name,
            "dosage": medication.dosage,
            "timeOfDay": Timestamp(date: medication.timeOfDay),
            "notes": medication.notes ?? "",
            "daysOfWeek": medication.daysOfWeek,
            "isActive": medication.isActive,
            "fromDate": Timestamp(date: medication.fromDate),
            "toDate": Timestamp(date: medication.toDate)
        ]
        
        collection.document(medication.id.uuidString).setData(docData) { error in
            if let error = error {
                print("Error adding medication: \(error.localizedDescription)")
                completion(medications)
            } else {
                var updatedMedications = medications
                updatedMedications.append(medication)
                completion(updatedMedications)
            }
        }
    }
    
    func updateMedication(_ medication: Medication, in medications: [Medication], completion: @escaping ([Medication]) -> Void) {
        guard let collection = medicationsCollection else {
            completion(medications)
            return
        }
        
        let docData: [String: Any] = [
            "name": medication.name,
            "dosage": medication.dosage,
            "timeOfDay": Timestamp(date: medication.timeOfDay),
            "notes": medication.notes ?? "",
            "daysOfWeek": medication.daysOfWeek,
            "isActive": medication.isActive,
            "fromDate": Timestamp(date: medication.fromDate),
            "toDate": Timestamp(date: medication.toDate)
        ]
        
        collection.document(medication.id.uuidString).setData(docData) { error in
            if let error = error {
                print("Error updating medication: \(error.localizedDescription)")
                completion(medications)
            } else {
                var updatedMedications = medications
                if let index = updatedMedications.firstIndex(where: { $0.id == medication.id }) {
                    updatedMedications[index] = medication
                }
                completion(updatedMedications)
            }
        }
    }
    
    func deleteMedication(at indexSet: IndexSet, from medications: [Medication], completion: @escaping ([Medication]) -> Void) {
        guard let collection = medicationsCollection else {
            completion(medications)
            return
        }
        
        var updatedMedications = medications
        let dispatchGroup = DispatchGroup()
        
        for index in indexSet {
            let medicationToDelete = medications[index]
            dispatchGroup.enter()
            
            collection.document(medicationToDelete.id.uuidString).delete { error in
                if let error = error {
                    print("Error deleting medication: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            updatedMedications.remove(atOffsets: indexSet)
            completion(updatedMedications)
        }
    }
}
