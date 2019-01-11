//
//  Category.swift
//  ToDoList
//
//  Created by Christopher Vera on 1/11/19.
//  Copyright © 2019 FSCApps. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
