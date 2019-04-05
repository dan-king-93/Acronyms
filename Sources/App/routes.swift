import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    // MARK: - Post a new acronym to be saved to the database
    router.post("api", "acronyms") { req -> Future<Acronym> in
        
        return try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self, { acronym in
                
                return acronym.save(on: req)
            })
    }
    
    // MARK: - See all acronyms in the database
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        
        return Acronym.query(on: req).all()
    }
    
    // MARK: - Search for a specific acronym in the database by its id in database
    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        
        return try req.parameters.next(Acronym.self)
    }
    
    // MARK: - Update a specific acronym in the database (by id)
    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self),
                           { acronym, newAcronym -> Future<Acronym> in
                            
                            acronym.short = newAcronym.short
                            acronym.long = newAcronym.long
                            
                            return acronym.save(on: req)
        })
    }
    
    // MARK: - Delete a specific acronym in the database (by id)
    router.delete("api", "acronyms", Acronym.parameter) {
        req -> Future<HTTPStatus> in
        
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    // MARK: - Search for an acronym in the database by long or short terms
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Acronym.query(on: req).group(.or) { databaseAcronyms in
            
            databaseAcronyms.filter(\.short == searchTerm)
            databaseAcronyms.filter(\.long == searchTerm)
            }.all()
    }
    
    // MARK: - Search for the first acronym held in the database
    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
        
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self, { acronym -> Acronym in
                
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                
                return acronym
            })
    }
    
    // MARK: - Retrieve all acronyms sorted in Alphabetical order
    router.get("api", "acronyms", "sorted") { req -> Future<[Acronym]> in
        
        return Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
}
