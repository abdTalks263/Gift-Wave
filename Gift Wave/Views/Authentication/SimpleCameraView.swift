//
//  SimpleCameraView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import UIKit

struct SimpleCameraView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Set up camera on main thread
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraDevice = .front
        } else {
            picker.sourceType = .photoLibrary
        }
        
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: SimpleCameraView
        
        init(_ parent: SimpleCameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Process image on main thread
            DispatchQueue.main.async {
                if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        self.parent.imageData = imageData
                        print("✅ Photo captured successfully")
                    } else {
                        print("❌ Failed to convert image to data")
                    }
                } else {
                    print("❌ No image found")
                }
                self.parent.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async {
                self.parent.dismiss()
            }
        }
    }
} 