import Foundation

// MARK: - Core entity model (used across all modules)
// Handles both UUID (canonical tables) and integer (legacy tables) IDs

struct KontraEntity: Identifiable, Decodable {
    var id: String
    var orgId: String?
    var title: String?
    var status: String
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, status
        case orgId = "org_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // ID can be String (UUID tables) or Int (legacy tables)
        if let str = try? c.decode(String.self, forKey: .id) {
            id = str
        } else if let int = try? c.decode(Int.self, forKey: .id) {
            id = String(int)
        } else {
            id = UUID().uuidString
        }
        orgId      = try? c.decode(String.self, forKey: .orgId)
        title      = try? c.decode(String.self, forKey: .title)
        status     = (try? c.decode(String.self, forKey: .status)) ?? "active"
        createdAt  = try? c.decode(String.self, forKey: .createdAt)
        updatedAt  = try? c.decode(String.self, forKey: .updatedAt)
    }

    var displayTitle: String { title?.isEmpty == false ? title! : "Untitled" }
    var statusBadge: StatusBadge { StatusBadge(status) }
    var formattedDate: String? {
        guard let raw = createdAt else { return nil }
        return DateFormatter.kontraDisplay.string(from: DateFormatter.kontraISO.date(from: raw) ?? Date())
    }
}

// MARK: - Auth models

struct SignInRequest: Encodable {
    let email: String
    let password: String
}

struct SignInResponse: Decodable {
    let accessToken: String
    let user: UserProfile?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

struct UserProfile: Decodable {
    let id: String
    let email: String?
    let appMetadata: AppMetadata?

    enum CodingKeys: String, CodingKey {
        case id, email
        case appMetadata = "app_metadata"
    }
}

struct AppMetadata: Decodable {
    let organizationId: String?
    let role: String?

    enum CodingKeys: String, CodingKey {
        case organizationId = "organization_id"
        case role
    }
}

// MARK: - Loan (legacy table — has domain-specific fields)

struct Loan: Identifiable, Decodable {
    var id: String
    var title: String?
    var borrowerName: String?
    var amount: Double?
    var interestRate: Double?
    var termMonths: Int?
    var startDate: String?
    var status: String
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, status
        case borrowerName = "borrower_name"
        case amount
        case interestRate = "interest_rate"
        case termMonths = "term_months"
        case startDate = "start_date"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let str = try? c.decode(String.self, forKey: .id) { id = str }
        else if let int = try? c.decode(Int.self, forKey: .id) { id = String(int) }
        else { id = UUID().uuidString }
        title        = try? c.decode(String.self, forKey: .title)
        borrowerName = try? c.decode(String.self, forKey: .borrowerName)
        amount       = try? c.decode(Double.self, forKey: .amount)
        interestRate = try? c.decode(Double.self, forKey: .interestRate)
        termMonths   = try? c.decode(Int.self, forKey: .termMonths)
        startDate    = try? c.decode(String.self, forKey: .startDate)
        status       = (try? c.decode(String.self, forKey: .status)) ?? "active"
        createdAt    = try? c.decode(String.self, forKey: .createdAt)
    }

    var displayName: String { title?.isEmpty == false ? title! : (borrowerName ?? "Untitled Loan") }
    var formattedAmount: String? {
        guard let amt = amount else { return nil }
        return NumberFormatter.currency.string(from: NSNumber(value: amt))
    }
    var statusBadge: StatusBadge { StatusBadge(status) }
}

// MARK: - Pool (markets)

struct Pool: Identifiable, Decodable {
    var id: String
    var title: String?
    var status: String
    var orgId: String?
    var createdAt: String?
    var tokenStatus: String?
    var tokenSymbol: String?
    var tokenSupply: Int?
    var tokenNetwork: String?

    enum CodingKeys: String, CodingKey {
        case id, title, status
        case orgId = "org_id"
        case createdAt = "created_at"
        case data
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let str = try? c.decode(String.self, forKey: .id) { id = str }
        else if let int = try? c.decode(Int.self, forKey: .id) { id = String(int) }
        else { id = UUID().uuidString }
        title     = try? c.decode(String.self, forKey: .title)
        status    = (try? c.decode(String.self, forKey: .status)) ?? "active"
        orgId     = try? c.decode(String.self, forKey: .orgId)
        createdAt = try? c.decode(String.self, forKey: .createdAt)
        // Pool data is stored in the `data` JSONB column
        if let dataDict = try? c.decode([String: JSONValue].self, forKey: .data) {
            tokenStatus  = dataDict["token_status"]?.stringValue
            tokenSymbol  = dataDict["token_symbol"]?.stringValue
            tokenSupply  = dataDict["token_supply"]?.intValue
            tokenNetwork = dataDict["token_network"]?.stringValue
        }
    }

    var displayTitle: String { title?.isEmpty == false ? title! : "Unnamed Pool" }
    var isTokenized: Bool { tokenStatus == "tokenized" }
    var statusBadge: StatusBadge { StatusBadge(status) }
}

// MARK: - AI Review

struct AIReview: Identifiable, Decodable {
    var id: String
    var type: String?
    var entityType: String?
    var entityId: String?
    var status: String
    var summary: String?
    var riskLevel: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, type, status, summary
        case entityType = "entity_type"
        case entityId = "entity_id"
        case riskLevel = "risk_level"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id         = (try? c.decode(String.self, forKey: .id)) ?? UUID().uuidString
        type       = try? c.decode(String.self, forKey: .type)
        entityType = try? c.decode(String.self, forKey: .entityType)
        entityId   = try? c.decode(String.self, forKey: .entityId)
        status     = (try? c.decode(String.self, forKey: .status)) ?? "pending"
        summary    = try? c.decode(String.self, forKey: .summary)
        riskLevel  = try? c.decode(String.self, forKey: .riskLevel)
        createdAt  = try? c.decode(String.self, forKey: .createdAt)
    }
}

// MARK: - Status badge helper

struct StatusBadge {
    let status: String

    init(_ status: String) { self.status = status }

    var color: String {
        switch status.lowercased() {
        case "active", "approved", "listed", "tokenized": return "green"
        case "pending", "draft", "review":                 return "yellow"
        case "inactive", "rejected", "closed":             return "red"
        default:                                            return "gray"
        }
    }
    var label: String { status.replacingOccurrences(of: "_", with: " ").capitalized }
}

// MARK: - JSONValue (arbitrary JSON decoder helper)

enum JSONValue: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil()                              { self = .null }
        else if let b = try? c.decode(Bool.self)      { self = .bool(b) }
        else if let i = try? c.decode(Int.self)       { self = .int(i) }
        else if let d = try? c.decode(Double.self)    { self = .double(d) }
        else if let s = try? c.decode(String.self)    { self = .string(s) }
        else if let a = try? c.decode([JSONValue].self) { self = .array(a) }
        else { self = .object(try c.decode([String: JSONValue].self)) }
    }

    var stringValue: String? {
        if case .string(let s) = self { return s }
        if case .int(let i) = self { return String(i) }
        return nil
    }
    var intValue: Int? {
        if case .int(let i) = self { return i }
        if case .double(let d) = self { return Int(d) }
        return nil
    }
    var doubleValue: Double? {
        if case .double(let d) = self { return d }
        if case .int(let i) = self { return Double(i) }
        return nil
    }
}

// MARK: - Formatters

extension DateFormatter {
    static let kontraISO: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    static let kontraDisplay: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = 0
        return f
    }()
}
