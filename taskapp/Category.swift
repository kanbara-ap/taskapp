//
//  Category.swift
//  taskapp
//
//  Created by WEBSYSTEM-MAC31 on 2022/05/09.
//

import RealmSwift
import SwiftUI

class Category : Object{
    static var realm = try! Realm()
    
    @objc dynamic var id = 0
    
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    

    
    static func loadAll() -> [Category] {
        let categories = realm.objects(Category.self).sorted(byKeyPath: "id", ascending: true)
        var ret: [Category] = []
        for category in categories {
            ret.append(category)
        }
        return ret
    }
    
}
