//
//  UsersView.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 01.02.2021.
//

import SwiftUI

struct UserView: View {
    var user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        HStack {
            if let avatarUrl = user.avatarUrl, avatarUrl.count > 0, let nsImage = NSImage(contentsOfFile: avatarUrl) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64, alignment: .center)
                    .scaledToFit()
                    .background(Color.primary)
                    .clipShape(Circle())
            } else {
                Circle().frame(width: 64, height: 64, alignment: .center)
            }
            VStack(alignment: .leading) {
                Text(user.fullName ?? "")
                Text("@\(user.login ?? "")")
            }
            .padding(.leading, 8)
            Spacer()
        }
        Divider()
    }
}

protocol UsersViewDelegate {
    func dismiss()
}

struct UsersView: View {
    var users: [User]
    var delegate: UsersViewDelegate?
    
    init() {
        self.users = [User]()
    }
    
    init(users: [User], delegate: UsersViewDelegate) {
        self.users = users
        self.delegate = delegate
    }
    
    var body: some View {
        List {
            ForEach(users, id: \.login) { user in
                UserView(user: user)
            }
        }
        Divider()
        
        HStack {
            Button("Dismiss") {
                delegate?.dismiss()
            }.padding()
        }
    }
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
    }
}
