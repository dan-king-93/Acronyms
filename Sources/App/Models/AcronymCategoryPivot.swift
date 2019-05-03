
import Foundation
import FluentPostgreSQL

final class AcronymCategoryPivot: PostgreSQLUUIDPivot, ModifiablePivot {
    
    static var leftIDKey: WritableKeyPath<AcronymCategoryPivot, Int> = \.acronymID
    static var rightIDKey: WritableKeyPath<AcronymCategoryPivot, Int> = \.categoryID
    
    init(_ left: AcronymCategoryPivot.Left, _ right: AcronymCategoryPivot.Right) throws {
        self.acronymID = try left.requireID()
        self.categoryID = try right.requireID()
    }
    
    typealias Left = Acronym
    typealias Right = Category
    
    var id: UUID?
    
    var acronymID: Acronym.ID
    var categoryID: Category.ID
}

extension AcronymCategoryPivot: Migration {
    
    static func prepare(on connection: PostgreSQLConnection
        ) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            
            try addProperties(to: builder)
            
            builder.reference(from: \.acronymID,
                              to: \Acronym.id,
                              onDelete: .cascade)
            
            builder.reference(from: \.categoryID,
                              to: \Category.id,
                              onDelete: .cascade)
        }
    }
}
