import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async -> Result<User, Error>
    func register(email: String, username: String, password: String, fullName: String?) async -> Result<User, Error>
    func logout() async -> Result<Void, Error>
    func getMe() async -> Result<User, Error>
    func isAuthenticated() -> Bool
    func getDeviceSessions() async -> Result<[DeviceSession], Error>
    func deleteDeviceSession(id: String) async -> Result<Void, Error>
}
