//
//  EnvironmentValues+Twitter.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation
import SwiftUI

private struct UserInfoKey: EnvironmentKey {
    static let defaultValue: UserInfo = UserInfo()
}

extension EnvironmentValues {
    var userInfo: UserInfo {
        get { self[UserInfoKey.self] }
        set { self[UserInfoKey.self] = newValue }
    }
}
