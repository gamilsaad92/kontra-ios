import Foundation

extension String {
    /// Parse an ISO-8601 timestamp (with or without fractional seconds) into a display date string.
    var asDisplayDate: String? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd",
        ]
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        for fmt in formats {
            f.dateFormat = fmt
            if let date = f.date(from: self) {
                let display = DateFormatter()
                display.dateStyle = .medium
                display.timeStyle = .none
                return display.string(from: date)
            }
        }
        return String(prefix(10)) // fallback: just show YYYY-MM-DD
    }
}
