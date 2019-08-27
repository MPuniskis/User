import Foundation
import CoreData

public class User: NSObject {
    
    private var bundleID: String { return "com.cookieCrust.User" }
    private var userModel: String { return "UserModel" }
    
    private lazy var persistentContainer: NSPersistentContainer? = {
        let bundle = Bundle(identifier: bundleID)
        let modelURL = bundle?.url(forResource: userModel, withExtension: "momd")
        guard let url = modelURL, let managedObjectModel = NSManagedObjectModel(contentsOf: url) else { return nil }
        
        let container = NSPersistentContainer(name: userModel, managedObjectModel: managedObjectModel)
        container.loadPersistentStores { descriptor, error in
            if let error = error {
                fatalError("Failed loading persistent store with error: \(error)")
            }
        }
        return container
    }()
}

public extension User {
    
    var info: UserModel? {
        guard let context = persistentContainer?.viewContext else { return nil }
        let request = NSFetchRequest<UserModel>(entityName: userModel)
        do {
            return try context.fetch(request).first
        } catch {
            print(error)
            return nil
        }
    }
    
    func setUser(username: String, token: String) {
        guard
            let context = persistentContainer?.viewContext,
            let user = NSEntityDescription.insertNewObject(forEntityName: userModel, into: context) as? UserModel
            else { return }
        user.username = username
        user.token = token
        
        do {
            try context.save()
        } catch {
            print(error)
            return
        }
    }
    
    func deleteAll() {
        guard let context = persistentContainer?.viewContext else { return }
        let request = NSFetchRequest<UserModel>(entityName: userModel)
        do {
            let users = try context.fetch(request)
            users.forEach({ context.delete($0) })
            try context.save()
        } catch {
            print(error)
            return
        }
    }
}
