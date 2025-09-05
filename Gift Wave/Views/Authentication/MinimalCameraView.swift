//
//  MinimalCameraView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import UIKit

struct MinimalCameraView: View {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    @State private var debugMessage = "Starting camera view..."
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Camera Debug View")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(debugMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
            
            Button("Skip Camera (For Testing)") {
                // Create a dummy image for testing
                createDummyImage()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.green)
            .cornerRadius(10)
            
            Button("Cancel") {
                safelyDismiss()
            }
            .font(.headline)
            .foregroundColor(.red)
        }
        .padding(30)
        .onAppear {
            debugMessage = "Camera view loaded successfully"
            print("🔍 MinimalCameraView appeared")
        }
        .onDisappear {
            print("🔍 MinimalCameraView disappeared")
        }
    }
    
    private func createDummyImage() {
        DispatchQueue.main.async {
            do {
                // Create a simple colored image for testing
                let size = CGSize(width: 200, height: 200)
                let renderer = UIGraphicsImageRenderer(size: size)
                
                let image = renderer.image { context in
                    UIColor.blue.setFill()
                    context.fill(CGRect(origin: .zero, size: size))
                    
                    UIColor.white.setFill()
                    let rect = CGRect(x: 50, y: 50, width: 100, height: 100)
                    context.fill(rect)
                }
                
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    self.imageData = imageData
                    self.debugMessage = "✅ Dummy image created successfully"
                    print("✅ Dummy image created and assigned")
                    
                    // Delay dismissal to see the success message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.safelyDismiss()
                    }
                } else {
                    self.debugMessage = "❌ Failed to create image data"
                    print("❌ Failed to create image data")
                }
            } catch {
                self.debugMessage = "❌ Error: \(error.localizedDescription)"
                print("❌ Error creating dummy image: \(error)")
            }
        }
    }
    
    private func safelyDismiss() {
        DispatchQueue.main.async {
            print("🔍 Safely dismissing MinimalCameraView")
            self.dismiss()
        }
    }
}

#Preview {
    MinimalCameraView(imageData: .constant(nil))
} 