//
//  ProfileModel.swift
//  BoostTest
//
//  Created by Sonya Hew on 10/06/2021.
//

import Foundation

struct ProfileModel: Codable {
    var id, firstName, lastName, email: String?
    var phone: String?
}
