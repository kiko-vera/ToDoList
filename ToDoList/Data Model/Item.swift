//
//  Item.swift
//  ToDoList
//
//  Created by Christopher Vera on 1/11/19.
//  Copyright © 2019 FSCApps. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var cellBackgroundColor: String = ""
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
