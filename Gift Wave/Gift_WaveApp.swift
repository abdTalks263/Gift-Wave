//
//  Gift_WaveApp.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI
import Firebase

@main
struct Gift_WaveApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var otpViewModel = OTPViewModel()

    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(otpViewModel)

        }
    }
}
