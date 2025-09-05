import SwiftUI

struct EarningEntry: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let deliveryId: String
    let status: String
}

struct EarningsHistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var earnings: [EarningEntry] = []
    @State private var isLoading = true
    @State private var totalEarnings: Double = 0
    @State private var selectedTimeFrame = TimeFrame.week
    
    enum TimeFrame: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
        case all = "All Time"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time Frame Picker
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Earnings Summary Card
                VStack(spacing: 16) {
                    Text("Total Earnings")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Rs. \(String(format: "%.2f", totalEarnings))")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        StatBox(title: "Deliveries", value: "\(earnings.count)")
                        StatBox(title: "Average", value: "Rs. \(String(format: "%.2f", averageEarning))")
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Earnings List
                if isLoading {
                    ProgressView()
                        .padding()
                } else if earnings.isEmpty {
                    EmptyStateView()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(earnings) { entry in
                            EarningEntryRow(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Earnings History")
        .onAppear(perform: loadEarnings)
        .onChange(of: selectedTimeFrame) { _ in
            loadEarnings()
        }
    }
    
    private var averageEarning: Double {
        guard !earnings.isEmpty else { return 0 }
        return totalEarnings / Double(earnings.count)
    }
    
    private func loadEarnings() {
        isLoading = true
        
        // Simulate API call with sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Sample data - replace with actual API call
            self.earnings = [
                EarningEntry(date: Date(), amount: 500, deliveryId: "DEL001", status: "Completed"),
                EarningEntry(date: Date().addingTimeInterval(-86400), amount: 750, deliveryId: "DEL002", status: "Completed"),
                EarningEntry(date: Date().addingTimeInterval(-172800), amount: 600, deliveryId: "DEL003", status: "Completed")
            ]
            self.totalEarnings = self.earnings.reduce(0) { $0 + $1.amount }
            self.isLoading = false
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct EarningEntryRow: View {
    let entry: EarningEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Order #\(entry.deliveryId)")
                    .font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Rs. \(String(format: "%.2f", entry.amount))")
                    .font(.headline)
                Text(entry.status)
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No earnings yet")
                .font(.headline)
            Text("Complete deliveries to start earning")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationView {
        EarningsHistoryView()
            .environmentObject(AuthViewModel())
    }
}
