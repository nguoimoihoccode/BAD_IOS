import SwiftUI

struct PaymentsScreen: View {
    @ObservedObject var viewModel: PaymentViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Title
                Text("Payments")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                    .padding(.top, 16)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    let hasPending = !viewModel.outstandingInvoices.isEmpty
                    let formattedBalance = "\(Int(viewModel.totalBalance).formattedWithSeparator())đ"

                    // Hero Card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TOTAL BALANCE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .kerning(1)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formattedBalance)
                                        .font(.system(size: 28, weight: .black))
                                        .foregroundColor(AppTheme.PremiumDark)
                                    if hasPending {
                                        HStack(spacing: 4) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(AppTheme.ErrorRed)
                                                .font(.system(size: 12))
                                            Text("Due by Friday")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(AppTheme.ErrorRed)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                if hasPending {
                                    Button(action: {
                                        for inv in viewModel.outstandingInvoices {
                                            viewModel.payInvoice(invoiceId: inv.id)
                                        }
                                    }) {
                                        Text("Pay Now")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(AppTheme.ErrorRed)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        Circle()
                            .fill(AppTheme.KineticGreen.opacity(0.05))
                            .frame(width: 80, height: 80)
                            .offset(x: 20, y: -20)
                    }

                    // Outstanding Fees Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Outstanding Fees")
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                            if hasPending {
                                Text("\(viewModel.outstandingInvoices.count) PENDING")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(AppTheme.ErrorRed)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.ErrorRed.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }

                        if viewModel.outstandingInvoices.isEmpty {
                            Text("No pending fees. You are all caught up!")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 24)
                                .background(Color.white)
                                .cornerRadius(12)
                        } else {
                            ForEach(viewModel.outstandingInvoices) { invoice in
                                InvoiceRow(invoice: invoice, isPending: true)
                            }
                        }
                    }

                    // Payment History Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment History")
                            .font(.system(size: 18, weight: .bold))

                        if viewModel.paymentHistory.isEmpty {
                            Text("No payment history")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(viewModel.paymentHistory) { invoice in
                                InvoiceRow(invoice: invoice, isPending: false)
                            }
                        }
                    }

                    // Apple Pay Linked Promo
                    HStack(spacing: 16) {
                        BoxContainer {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Apple Pay Linked")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("Fast checkout enabled for all your future court bookings.")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(AppTheme.PremiumDark)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
    }
}

struct BoxContainer<Content: View>: View {
    let content: () -> Content
    var body: some View {
        content()
    }
}

struct InvoiceRow: View {
    let invoice: Invoice
    let isPending: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isPending ? "doc.plaintext" : "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(isPending ? AppTheme.ErrorRed : AppTheme.KineticGreen)
                .frame(width: 44, height: 44)
                .background(isPending ? AppTheme.ErrorRed.opacity(0.08) : AppTheme.KineticGreen.opacity(0.08))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(invoice.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Text("\(invoice.date) • \(invoice.courtInfo)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(invoice.amount).formattedWithSeparator())đ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Text(invoice.status)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isPending ? AppTheme.ErrorRed : AppTheme.KineticGreen)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}
