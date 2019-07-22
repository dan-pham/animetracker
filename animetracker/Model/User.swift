//
//  User.swift
//  animetracker
//
//  Created by Dan Pham on 7/20/19.
//  Copyright © 2019 Dan Pham. All rights reserved.
//

import UIKit

class User: NSObject {
    var id: String?
    var username: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.username = dictionary["username"] as? String
        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"] as? String
        self.email = dictionary["email"] as? String
    }
}
