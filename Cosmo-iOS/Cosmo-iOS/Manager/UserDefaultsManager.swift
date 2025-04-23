//
//  UserDefaultsManager.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/22/25.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    var isStart: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isStart")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isStart")
        }
    }
    
    var count: Int {
        get {
            UserDefaults.standard.integer(forKey: "count")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "count")
        }
    }
}
