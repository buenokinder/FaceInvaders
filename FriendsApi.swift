import UIKit
import CoreData

/**
Event API contains the endpoints to Create/Read/Update/Delete Events.
*/
@available(iOS 10.0, *)
class FriendsAPI {
	
	fileprivate let persistenceManager: PersistenceManager!
	fileprivate var mainContextInstance:NSManagedObjectContext!
	
	fileprivate let idNamespace = FriendsAttributes.id.rawValue
	fileprivate let imageNamescpace = FriendsAttributes.image.rawValue
		
	//Utilize Singleton pattern by instanciating EventAPI only once.
	class var sharedInstance: FriendsAPI {
		struct Singleton {
			static let instance = FriendsAPI()
		}
		
		return Singleton.instance
	}
	
	init() {
		self.persistenceManager = PersistenceManager.sharedInstance
		self.mainContextInstance = persistenceManager.getMainContextInstance()
	}
	
	
	func saveFriends(_ eventDetails: Dictionary<String, AnyObject>) {
		
		
		let minionManagedObjectContextWorker:NSManagedObjectContext =
			NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
		minionManagedObjectContextWorker.parent = self.mainContextInstance
		
	
		let eventItem = NSEntityDescription.insertNewObject(forEntityName: EntityTypes.Friends.rawValue,
		                                                    into: minionManagedObjectContextWorker) as! Friends
		
		//Assign field values
		for (key, value) in eventDetails {
			for attribute in FriendsAttributes.getAll {
				if (key == attribute.rawValue) {
					eventItem.setValue(value, forKey: key)
				}
			}
		}
		
		//Save current work on Minion workers
		self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
		
		//Save and merge changes from Minion workers with Main context
		self.persistenceManager.mergeWithMainContext()
		
		//Post notification to update datasource of a given Viewcontroller/UITableView
		//self.postUpdateNotification()
	}
	
	/**
	Create new Events from a given list, and persist it to Datastore via Worker(minion),
	that synchronizes with Main context.
	
	- Parameter eventsList: Array<AnyObject> Contains events to be persisted to the Datastore.
	- Returns: Void
	*/
	func saveFriendsList(_ eventsList:Array<AnyObject>){
		DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: { () -> Void in
			
			//Minion Context worker with Private Concurrency type.
			let minionManagedObjectContextWorker:NSManagedObjectContext =
				NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
			minionManagedObjectContextWorker.parent = self.mainContextInstance
			
			//Create eventEntity, process member field values
			for index in 0..<eventsList.count {
				var eventItem:Dictionary<String, NSObject> = eventsList[index] as! Dictionary<String, NSObject>
				
				
				
				//Create new Object of Event entity
				let item = NSEntityDescription.insertNewObject(forEntityName: EntityTypes.Friends.rawValue,
				                                               into: minionManagedObjectContextWorker) as! Friends
				
				
				item.setValue(eventItem[self.idNamespace], forKey: self.idNamespace)
				item.setValue(eventItem[self.imageNamescpace], forKey: self.imageNamescpace)
				
				//Save current work on Minion workers
				self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
				
			}
			
			//Save and merge changes from Minion workers with Main context
			self.persistenceManager.mergeWithMainContext()
			
			//Post notification to update datasource of a given Viewcontroller/UITableView
			DispatchQueue.main.async {
				//self.postUpdateNotification()
			}
		})
	}
	
	// MARK: Read
	
	/**
	Retrieves all event items stored in the persistence layer, default (overridable)
	parameters:
	
	- Parameter sortedByDate: Bool flag to add sort rule: by Date
	- Parameter sortAscending: Bool flag to set rule on sorting: Ascending / Descending date.
	
	- Returns: Array<Event> with found events in datastore
	*/
	func getAllFriends(_ sortedByDate:Bool = true, sortAscending:Bool = true) -> Array<Friends> {
		var fetchedResults:Array<Friends> = Array<Friends>()
		
		// Create request on Event entity
		if #available(iOS 10.0, *) {
			let fetchRequest: NSFetchRequest<Friends> = Friends.fetchRequest() as! NSFetchRequest<Friends>
			//Execute Fetch request
			do {
				fetchedResults = try  self.mainContextInstance.fetch(fetchRequest) as! [Friends]
			} catch let fetchError as NSError {
				print("retrieveById error: \(fetchError.localizedDescription)")
				fetchedResults = Array<Friends>()
			}
		} else {
			// Fallback on earlier versions
		}
		
		//Create sort descriptor to sort retrieved Events by Date, ascending
		
	
		
		return fetchedResults
	}
	
	
}
