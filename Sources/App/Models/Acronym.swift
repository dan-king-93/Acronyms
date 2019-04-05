import Vapor
import FluentSQLite

// N.B. All Fluent models must be fully codable conformant (for writing to the database)
final class Acronym: Codable {
    
    var id: Int?
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}

// Codable
extension Acronym: Content { }

extension Acronym: SQLiteModel { }

// N.B. Can automatically infer scheme for the model due to Codable conformance
extension Acronym: Migration { }


