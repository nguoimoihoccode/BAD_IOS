import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseUrl = "http://localhost:8000/api/v1"
    
    private var refreshTask: Task<Result<String, Error>, Never>?
    
    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "access_token") }
    }
    
    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "refresh_token") }
        set { UserDefaults.standard.set(newValue, forKey: "refresh_token") }
    }
    
    func saveTokens(access: String, refresh: String) {
        self.accessToken = access
        self.refreshToken = refresh
    }
    
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
    }
    
    func hasTokens() -> Bool {
        return accessToken != nil
    }
    
    func getRefreshToken() -> String? {
        return refreshToken
    }
    
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        isRetry: Bool = false
    ) async -> Result<T, Error> {
        let urlString = "\(baseUrl)\(path)"
        guard let url = URL(string: urlString) else {
            return .failure(NSError(domain: "InvalidURL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid API Path URL"]))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !path.contains("/auth/login") && !path.contains("/auth/register") && !path.contains("/auth/refresh") {
            if let token = accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        if let body = body {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NSError(domain: "InvalidResponse", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP Response"]))
            }
            
            if httpResponse.statusCode == 401 && !isRetry && !path.contains("/auth/login") && !path.contains("/auth/register") && !path.contains("/auth/refresh") {
                let refreshResult = await rotateToken()
                if case .success = refreshResult {
                    return await request(path: path, method: method, body: body, isRetry: true)
                } else {
                    clearTokens()
                    NotificationCenter.default.post(name: NSNotification.Name("SessionExpired"), object: nil)
                    return .failure(NSError(domain: "Unauthorized", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please log in again."]))
                }
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let serverMessage = String(data: data, encoding: .utf8) ?? "Server returned error"
                return .failure(NSError(domain: "ServerHTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: serverMessage]))
            }
            
            if data.isEmpty, T.self == EmptyResponse.self {
                return .success(EmptyResponse() as! T)
            }
            
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
    
    private func rotateToken() async -> Result<String, Error> {
        if let existing = refreshTask {
            return await existing.value
        }
        let task = Task { await self.performRotateToken() }
        refreshTask = task
        let result = await task.value
        refreshTask = nil
        return result
    }
    
    private func performRotateToken() async -> Result<String, Error> {
        guard let refresh = refreshToken else {
            return .failure(NSError(domain: "NoRefreshToken", code: 400, userInfo: [NSLocalizedDescriptionKey: "No refresh token stored"]))
        }
        
        let path = "/auth/refresh"
        let body = ["refresh": refresh]
        
        struct RefreshResponse: Codable {
            let access: String
            let refresh: String
        }
        
        let urlString = "\(baseUrl)\(path)"
        guard let url = URL(string: urlString) else {
            return .failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return .failure(NSError(domain: "RefreshFailed", code: 401, userInfo: nil))
            }
            
            let res = try JSONDecoder().decode(RefreshResponse.self, from: data)
            saveTokens(access: res.access, refresh: res.refresh)
            return .success(res.access)
        } catch {
            return .failure(error)
        }
    }
}

struct EmptyResponse: Codable {}
