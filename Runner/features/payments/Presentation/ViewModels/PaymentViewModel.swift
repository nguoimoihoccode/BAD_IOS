import Foundation
import Combine

@MainActor
class PaymentViewModel: ObservableObject {
    @Published var outstandingInvoices: [Invoice] = []
    @Published var paymentHistory: [Invoice] = []
    @Published var totalBalance: Double = 0.0
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let repository: PaymentRepository

    init(repository: PaymentRepository = ServiceLocator.shared.paymentRepository) {
        self.repository = repository
        loadPayments()
    }

    func loadPayments() {
        isLoading = true
        errorMessage = nil
        Task {
            let resDues = await repository.getOutstandingFees()
            let resHistory = await repository.getPaymentHistory()
            isLoading = false
            
            if case .success(let dues) = resDues, case .success(let historyList) = resHistory {
                self.outstandingInvoices = dues
                self.paymentHistory = historyList
                self.totalBalance = dues.reduce(0.0) { $0 + $1.amount }
            } else {
                self.errorMessage = "Failed to load payment details"
            }
        }
    }

    func payInvoice(invoiceId: String) {
        isLoading = true
        Task {
            let _ = await repository.payInvoice(invoiceId: invoiceId)
            loadPayments()
        }
    }
}
