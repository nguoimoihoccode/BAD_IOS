import Foundation

protocol PaymentRepository {
    func getOutstandingFees() async -> Result<[Invoice], Error>
    func getPaymentHistory() async -> Result<[Invoice], Error>
    func payInvoice(invoiceId: String) async -> Result<Void, Error>
}
