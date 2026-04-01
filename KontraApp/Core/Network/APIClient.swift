import Foundation

// MARK: - API Error

enum APIError: Error, LocalizedError {
    case unauthorized
    case notFound
    case serverError(String)
    case networkError(Error)
    case decodingError(Error)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .unauthorized:         return "Session expired. Please sign in again."
        case .notFound:             return "Resource not found."
        case .serverError(let m):   return m
        case .networkError(let e):  return e.localizedDescription
        case .decodingError(let e): return "Failed to parse response: \(e.localizedDescription)"
        case .invalidURL:           return "Invalid URL."
        }
    }
}

// MARK: - API Client

@MainActor
final class APIClient: ObservableObject {
    static let shared = APIClient()

    private let baseURL = "https://kontra-api.onrender.com"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)
    }

    // MARK: - Core request

    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let auth = AuthManager.shared
        if let token = auth.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let orgId = auth.orgId {
            req.setValue(orgId, forHTTPHeaderField: "X-Org-Id")
        }

        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: req)
        } catch {
            throw APIError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        if http.statusCode == 401 {
            auth.signOut()
            throw APIError.unauthorized
        }
        if http.statusCode == 404 {
            throw APIError.notFound
        }
        if http.statusCode >= 400 {
            let msg = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))?.message ?? "Request failed (\(http.statusCode))"
            throw APIError.serverError(msg)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Convenience helpers

    func get<T: Decodable>(_ path: String) async throws -> T {
        try await request(path, method: "GET")
    }

    func post<T: Decodable>(_ path: String, body: some Encodable) async throws -> T {
        try await request(path, method: "POST", body: body)
    }

    func patch<T: Decodable>(_ path: String, body: some Encodable) async throws -> T {
        try await request(path, method: "PATCH", body: body)
    }

    func delete(_ path: String) async throws {
        let _: EmptyResponse = try await request(path, method: "DELETE")
    }

    // MARK: - Entity helpers (generic CRUD)

    func listEntities<T: Decodable>(_ path: String) async throws -> EntityList<T> {
        try await get(path)
    }

    func createEntity(_ path: String, title: String? = nil) async throws -> KontraEntity {
        let body = CreateEntityBody(title: title ?? "New Item", status: "active", data: [:])
        return try await post(path, body: body)
    }

    func updateEntity(_ path: String, id: String, patch: UpdateEntityBody) async throws -> KontraEntity {
        try await self.patch("\(path)/\(id)", body: patch)
    }
}

// MARK: - Shared request/response types

struct EmptyResponse: Decodable {}

struct APIErrorResponse: Decodable {
    let message: String?
    let code: String?
}

struct EntityList<T: Decodable>: Decodable {
    let items: [T]
    let total: Int
}

struct CreateEntityBody: Encodable {
    let title: String
    let status: String
    let data: [String: String]
}

struct UpdateEntityBody: Encodable {
    var title: String?
    var status: String?
    var data: [String: String]?
}
