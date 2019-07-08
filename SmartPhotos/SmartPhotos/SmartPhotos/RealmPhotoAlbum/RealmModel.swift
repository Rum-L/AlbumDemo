//
//  RealmModel.swift
//  Smart Photos
//
//  Created by 林铭杰 on 2019/5/13.
//  Copyright © 2019 林铭杰. All rights reserved.
//

import Foundation
import RealmSwift

// Album Model
class Album: Object {
    @objc dynamic var title: String = ""
    // for Realm Migration test(title2 -> subTitle)
//    dynamic var subTitle: String = ""
    @objc dynamic var saveDate: Date = Date()
    // UUID for Primary-key and Migarion test
    @objc dynamic var uuid: String = UUID().uuidString
    let photos: List<Photo> = List<Photo>()
    
    // set primary-key
//    override class func primaryKey() -> String? {
//        return "uuid"
//    }
}


// Photo Model
class Photo: Object {
    @objc dynamic var saveDate: Date = Date()
    @objc dynamic var imageData: Data = Data()
    @objc dynamic var uuid: String = UUID().uuidString
    @objc dynamic var image_id: String = ""
}

class Token: Object {
    @objc dynamic var image_id: String = ""
    @objc dynamic var face_token: String = ""
    @objc dynamic var group_id: String = ""
}
