//
//  EntityTypes.swift
//  CoreDataCRUD
//
//  Created by c0d3r on 03/10/15.
//  Copyright © 2015 io pandacode. All rights reserved.
//

import Foundation

/**
Enum for holding different entity type names (Coredata Models)
*/
enum EntityTypes:String {
	case Friends = "Friends"

	
	static let getAll = [Friends] //[Event, Foo,Bar]
}
