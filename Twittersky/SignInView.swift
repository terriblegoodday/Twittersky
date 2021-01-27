//
//  SignInView.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import SwiftUI

struct SignInView: View {
    private var presenter: SignInPresenter?
    
    @State var nickname: String = ""
    @State var password: String = ""
    
    var authManager: AuthManager?
    
    init() {
        
    }
    
    init(presenter: SignInPresenter, authManager: AuthManager) {
        self.authManager = authManager
        self.presenter = presenter
    }
    
    var body: some View {
        VStack {
            Text("Twitter").font(.title)
            Text("version 0.0.1").font(.title2)
            TextField("Nickname", text: $nickname)
            SecureField("Password", text: $password)
            Button(action: signIn, label: {
                Text("Sign in")
            })
        }.frame(minWidth: 250, idealWidth: 250, maxWidth: 250, minHeight: 320, idealHeight: 320, maxHeight: 320, alignment: .center).padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
    }
    
    func signIn() {
        authManager?.authenticate(login: nickname, password: password, completionHandler: completeSignIn(user:), onFail: {
            shakeWindow()
        })
    }
    
    func completeSignIn(user: User) {
        presenter?.completeSignIn(user: user)
    }
    
    func shakeWindow() {
        self.presenter?.shakeWindow()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView().frame(width: 250, height: 320, alignment: .center)
    }
}
