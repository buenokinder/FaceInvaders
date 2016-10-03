//
//  Event.swift
//  CoreDataCRUD
//  Written by Steven R.
//

import Foundation
import CoreData

/**
Enum for Event Entity member fields
*/
enum FriendsAttributes : String {
	case
	id    = "id",
	image      = "image"

	
	static let getAll = [
		id,
		image	]
}

@objc(Friends)

/**
The Core Data Model: Event
*/
class Friends: NSManagedObject {
	@NSManaged var id: String
	@NSManaged var image: NSData

}
