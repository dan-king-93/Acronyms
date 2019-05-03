import Vapor
import FluentPostgreSQL

// N.B. All Fluent models must be fully codable conformant (for writing to the database)
final class Acronym: Codable {
    
    var id: Int?
    var userID: User.ID
    var short: String
    var long: String
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

// Codable
extension Acronym: Content { }

extension Acronym: PostgreSQLModel  { }

// N.B. Can automatically infer scheme for the model due to Codable conformance
extension Acronym: Parameter { }

extension Acronym {
    
    // parent child relationship. Requires being in the same database
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
    
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
}

extension Acronym: Migration {
    
    static func prepare(on connection: PostgreSQLConnection
        ) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            
            try addProperties(to: builder)
            
            // setup of foreign key constraints
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

