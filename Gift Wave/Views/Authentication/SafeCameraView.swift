//
//  SafeCameraView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import UIKit
import AVFoundation

struct SafeCameraView: View {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var cameraAvailable = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Take Profile Photo")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please take a live photo for your rider profile")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
            
            Button("Open Camera") {
                checkCameraAndOpen()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(cameraAvailable ? Color.blue : Color.gray)
            .cornerRadius(10)
            .disabled(!cameraAvailable)
            
            Button("Cancel") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.red)
        }
        .padding(30)
        .onAppear {
            checkCameraAvailability()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(imageData: $imageData, sourceType: .camera)
        }
        .alert("Camera Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func checkCameraAvailability() {
        DispatchQueue.main.async {
            self.cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    private func checkCameraAndOpen() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            alertMessage = "Camera is not available on this device."
            showingAlert = true
            return
        }
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            showingImagePicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showingImagePicker = true
                    } else {
                        self.alertMessage = "Camera access is required to take your profile photo."
                        self.showingAlert = true
                    }
                }
            }
        case .denied, .restricted:
            alertMessage = "Camera access is denied. Please enable it in Settings > Privacy & Security > Camera."
            showingAlert = true
        @unknown default:
            alertMessage = "Unknown camera permission status."
            showingAlert = true
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            defer {
                DispatchQueue.main.async {
                    self.parent.dismiss()
                }
            }
            
            guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
                return
            }
            
            // Resize image to reasonable size
            let resizedImage = image.resized(to: CGSize(width: 800, height: 800))
            
            DispatchQueue.main.async {
                self.parent.imageData = resizedImage.jpegData(compressionQuality: 0.8)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async {
                self.parent.dismiss()
            }
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

#Preview {
    SafeCameraView(imageData: .constant(nil))
} 