import Foundation

class PaymentRepositoryImpl: PaymentRepository {
    private var outstanding = [
        Invoice(id: "invoice-1", title: "Tuesday Night Lights", date: "Oct 24", courtInfo: "Court 3 • Advanced", amount: 150000, status: "PENDING")
    ]

    private var history = [
        Invoice(id: "invoice-2", title: "Weekend Smashfest", date: "Oct 21, 2023", courtInfo: "Court 1 • Intermediate", amount: 125000, status: "PAID"),
        Invoice(id: "invoice-3", title: "Drill Session: Backhand", date: "Oct 18, 2023", courtInfo: "Court 2 • All Levels", amount: 200000, status: "PAID"),
        Invoice(id: "invoice-4", title: "Mixed Doubles Open", date: "Oct 14, 2023", courtInfo: "Court 4 • Mixed", amount: 150000, status: "PAID")
    ]

    func getOutstandingFees() async -> Result<[Invoice], Error> {
        return .success(outstanding)
    }

    func getPaymentHistory() async -> Result<[Invoice], Error> {
        return .success(history)
    }

    func payInvoice(invoiceId: String) async -> Result<Void, Error> {
        if let idx = outstanding.firstIndex(where: { $0.id == invoiceId }) {
            var invoice = outstanding.remove(at: idx)
            invoice.status = "PAID"
            invoice.date = "Today"
            history.insert(invoice, at: 0)
            return .success(())
        }
        return .failure(NSError(domain: "InvoiceNotFound", code: 404, userInfo: nil))
    }
}
