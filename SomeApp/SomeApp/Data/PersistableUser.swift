//
//  PersistableUser.swift
//  SomeApp
//
//  Created by Perry Shalom on 05/05/2017.
//  Copyright © 2017 PerrchicK. All rights reserved.
//

import Foundation

class PersistableUser: NSObject, NSCoding {
    var email: String
    var firstName: String
    var lastName: String
    var nickname: String
    
    init(email: String, firstName: String, lastName: String, nickname: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
    }

    required init?(coder aDecoder: NSCoder) {
        guard let email = aDecoder.decodeObject(forKey: "email") as? String, let firstName = aDecoder.decodeObject(forKey: "firstName") as? String,
            let lastName = aDecoder.decodeObject(forKey: "lastName") as? String,
            let nickname = aDecoder.decodeObject(forKey: "nickname") as? String else { return nil }
        
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: "email")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(nickname, forKey: "nickname")
    }

    override var description: String {
        return "first name: \(firstName), email: \(email)"
    }
    
    deinit {
        📘("\(self) is dead 💀")
    }
}
