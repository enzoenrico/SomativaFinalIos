//
//  DataModel.xcdatamodeld
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import CoreData
import Foundation

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - UserEntity
@objc(UserEntity)
public class UserEntity: NSManagedObject {
    
}

extension UserEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var username: String?
    @NSManaged public var email: String?
    @NSManaged public var passwordHash: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var favorites: NSSet?
}

extension UserEntity {
    @objc(addFavoritesObject:)
    @NSManaged public func addToFavorites(_ value: FavoriteEntity)
    
    @objc(removeFavoritesObject:)
    @NSManaged public func removeFromFavorites(_ value: FavoriteEntity)
    
    @objc(addFavorites:)
    @NSManaged public func addToFavorites(_ values: NSSet)
    
    @objc(removeFavorites:)
    @NSManaged public func removeFromFavorites(_ values: NSSet)
}

extension UserEntity : Identifiable {
    
}

@objc(FavoriteEntity)
public class FavoriteEntity: NSManagedObject {
    
}

extension FavoriteEntity: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteEntity> {
        return NSFetchRequest<FavoriteEntity>(entityName: "FavoriteEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var pokemonId: Int32
    @NSManaged public var pokemonName: String?
    @NSManaged public var pokemonImageUrl: String?
    @NSManaged public var addedAt: Date?
    @NSManaged public var user: UserEntity?
}

