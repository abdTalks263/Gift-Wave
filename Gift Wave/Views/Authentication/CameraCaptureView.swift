//
//  CameraCaptureView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Check if camera is available on main thread
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                picker.cameraDevice = .front
            } else {
                print("Camera is not available on this device, using photo library")
                picker.sourceType = .photoLibrary
            }
            picker.allowsEditing = true
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCaptureView
        
        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            DispatchQueue.main.async {
                do {
                    if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                        if let imageData = image.jpegData(compressionQuality: 0.8) {
                            self.parent.imageData = imageData
                            print("✅ Photo captured and processed successfully")
                        } else {
                            print("❌ Failed to convert image to JPEG data")
                        }
                    } else {
                        print("❌ No image found in picker info")
                    }
                } catch {
                    print("❌ Error processing image: \(error.localizedDescription)")
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

 