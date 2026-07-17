import Foundation

class AuthRepositoryImpl: AuthRepository {
    
    struct AuthResponse: Codable {
        let access: String
        let refresh: String
        let user: User
    }
    
    struct DeviceSessionDTO: Codable {
        let id: String
        let device_info: String?
        let user_agent: String?
        let created_at: String
        let is_current: Bool
        
        func toDomain() -> DeviceSession {
            let name = device_info ?? user_agent ?? "Unknown Device"
            return DeviceSession(id: id, deviceName: name, lastActive: created_at, isCurrent: is_current)
        }
    }
    
    struct DeviceSessionListDTO: Codable {
        let results: [DeviceSessionDTO]
    }

    func login(email: String, password: String) async -> Result<User, Error> {
        let body = ["email": email, "password": password]
        let res: Result<AuthResponse, Error> = await APIClient.shared.request(path: "/auth/login", method: "POST", body: body)
        
        switch res {
        case .success(let response):
            APIClient.shared.saveTokens(access: response.access, refresh: response.refresh)
            return .success(response.user)
        case .failure(let error):
            return .failure(error)
        }
    }

    func register(email: String, username: String, password: String, fullName: String?) async -> Result<User, Error> {
        var body: [String: Any] = ["email": email, "username": username, "password": password]
        if let fullName, !fullName.isEmpty {
            body["full_name"] = fullName
        }
        let res: Result<AuthResponse, Error> = await APIClient.shared.request(path: "/auth/register", method: "POST", body: body)
        
        switch res {
        case .success(let response):
            APIClient.shared.saveTokens(access: response.access, refresh: response.refresh)
            return .success(response.user)
        case .failure(let error):
            return .failure(error)
        }
    }

    func logout() async -> Result<Void, Error> {
        defer { APIClient.shared.clearTokens() }
        
        var body: [String: Any] = [:]
        if let refresh = APIClient.shared.getRefreshToken() {
            body["refresh"] = refresh
        }
        
        let res: Result<EmptyResponse, Error> = await APIClient.shared.request(
            path: "/auth/logout",
            method: "POST",
            body: body
        )
        
        switch res {
        case .success:
            return .success(())
        case .failure(let error):
            if let nsError = error as? NSError, nsError.code == 204 || nsError.domain == "NSCocoaErrorDomain" {
                return .success(())
            }
            return .failure(error)
        }
    }

    func getMe() async -> Result<User, Error> {
        return await APIClient.shared.request(path: "/me", method: "GET")
    }

    func isAuthenticated() -> Bool {
        return APIClient.shared.hasTokens()
    }

    func getDeviceSessions() async -> Result<[DeviceSession], Error> {
        let res: Result<DeviceSessionListDTO, Error> = await APIClient.shared.request(path: "/me/sessions", method: "GET")
        
        switch res {
        case .success(let list):
            return .success(list.results.map { $0.toDomain() })
        case .failure(let error):
            return .failure(error)
        }
    }

    func deleteDeviceSession(id: String) async -> Result<Void, Error> {
        let res: Result<EmptyResponse, Error> = await APIClient.shared.request(path: "/me/sessions/\(id)", method: "DELETE")
        
        switch res {
        case .success:
            return .success(())
        case .failure(let error):
            if let nsError = error as? NSError, nsError.code == 204 || nsError.domain == "NSCocoaErrorDomain" {
                return .success(())
            }
            return .failure(error)
        }
    }
}
