//
//  ContentView.swift
//  Gift Wave
//
//  Created by Abdullah Latif on 04/08/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var otpViewModel: OTPViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if let user = authViewModel.currentUser {
                    switch user.userType {
                    case .sender:
                        SenderHomeView()
                    case .rider:
                        RiderHomeView()
                    }
                } else {
                    ProgressView("Loading user...")
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(OTPViewModel())
}
