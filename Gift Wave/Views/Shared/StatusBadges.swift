import SwiftUI

// Order Status Badge for GiftOrders
struct OrderStatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return .orange
        case .accepted:
            return .blue
        case .purchased:
            return .purple
        case .inTransit:
            return .yellow
        case .delivered:
            return .green
        case .cancelled:
            return .red
        }
    }
}

// Rider Status Badge for Admin Dashboard
struct RiderStatusBadge: View {
    let status: RiderStatus
    
    var badgeColor: Color {
        switch status {
        case .pending:
            return .orange
        case .approved:
            return .green
        case .rejected:
            return .red
        case .banned:
            return .black
        }
    }
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(badgeColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

// Payment Status Badge
struct PaymentStatusBadge: View {
    let status: PaymentStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending:
            return .orange
        case .confirmed:
            return .green
        case .disputed:
            return .red
        case .refunded:
            return .gray
        }
    }
} 