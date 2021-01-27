//
//  ContentView.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 27.01.2021.
//

import SwiftUI
import AppKit

struct ListItem: Identifiable {
    var id = UUID()
    var title: String
    var link: AnyView
}

struct ContentView: View, TweetDelegate, TweetManagerDelegate {
    @ObservedObject var userInfo: UserInfo
    var tweetManager: TweetManager
    var items = [ListItem]()
    @State var __currentUser: User?
    var delegate: MainWindowDelegate?
    @State var selection: String?
    
    var currentUser: User {
        userInfo.currentUser ?? User(context: NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType))
    }
    
    mutating func loadMenuItems() {
        items.append(ListItem(title: "Tweets", link: AnyView(TweetsView(userInfo: userInfo))))
        items.append(ListItem(title: "Search", link: AnyView(SearchView(with: self))))
        items.append(ListItem(title: "Profile", link: AnyView(ProfileView(userInfo: userInfo, self.delegate))))
    }
    
    init() {
        self.userInfo = UserInfo()
        self.tweetManager = TweetManager()
        self.tweetManager.delegate = self
    }
    
    init(delegate: MainWindowDelegate, viewModel: UserInfo) {
        self.userInfo = viewModel
        self.delegate = delegate
        self.tweetManager = TweetManager()
        self.tweetManager.delegate = self
        self.loadMenuItems()
    }
    
    var body: some View {
        NavigationView {
            List {
                VStack{
                    HStack(alignment: .center) {
                        Spacer()
                        if let avatarUrl = userInfo.currentUser?.avatarUrl, avatarUrl.count > 0, let nsImage = NSImage(contentsOfFile: avatarUrl) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48, alignment: .center)
                                .scaledToFit()
                                .background(Color.primary)
                                .clipShape(Circle())
                        } else {
                            Circle().frame(width: 48, height: 48, alignment: .center)
                        }
                        Spacer()
                    }
                    if userInfo.currentUser != nil {
                        Button(action: delegate?.didClickSignInButton ?? {}) {
                            Text("@\(userInfo.currentUser?.login ?? "unknown login")").frame(maxWidth: .infinity)
                        }.frame(maxWidth: .infinity).buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: delegate?.didClickSignInButton ?? {}) {
                            Text("Sign in").frame(maxWidth: .infinity)
                        }.frame(maxWidth: .infinity).buttonStyle(PlainButtonStyle())
                    }
                    if userInfo.currentUser?.role == "admin" {
                        Text("administrator").foregroundColor(Color.yellow)
                    } else if userInfo.currentUser?.role == "moderator" {
                        Text("moderator").foregroundColor(Color.yellow)
                    }
                    Spacer()
                }
                ForEach(items) { item in
                    NavigationLink(destination: item.link, tag: item.title, selection: $selection) {
                        HStack {
                            Text(item.title)
                        }
                    }.navigationTitle(item.title)
                }
                
            }.listStyle(SidebarListStyle())
            .onAppear(perform: {
                self.selection = "Tweets"
            })
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
        .navigationTitle("Twitter")
    }
    
    func shouldShowRemoveButton(for user: User) -> Bool {
        return userInfo.currentUser == user
    }
    
    func removeTweet(_ tweet: Tweet) {
        tweetManager.removeTweet(tweet)
    }
    
    func reply(to tweet: Tweet) {
        tweetManager.reply(to: tweet)
    }
    
    func showParent(of tweet: Tweet) {
        tweetManager.showParent(of: tweet)
    }
    
    func showThread(parent tweet: Tweet) {
        tweetManager.showThread(parent: tweet)
    }
    
    func edit(tweet: Tweet) {
        tweetManager.edit(tweet: tweet)
    }
    
    func showAuthor(tweet: Tweet) {
        tweetManager.showAuthor(tweet: tweet)
    }
}

struct TweetsView: View, TweetDelegate, TweetManagerDelegate {
    @ObservedObject var userInfo: UserInfo
    @Environment(\.managedObjectContext) var managedObjectContext
    var tweetManager: TweetManager
    @FetchRequest(fetchRequest: getLatestTweets()) var tweets: FetchedResults<Tweet>
    
    var currentUser: User { userInfo.currentUser! }

    init() {
        self.userInfo = UserInfo()
        self.tweetManager = TweetManager()
        tweetManager.delegate = self
    }
    
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
        self.tweetManager = TweetManager()
        tweetManager.delegate = self
    }
    
    var body: some View {
        if userInfo.currentUser != nil {
            var tweets = (userInfo.currentUser?.follows?.allObjects as? [User])?.reduce(into: [Tweet](), { (result: inout [Tweet], user) in
                result.append(contentsOf: user.tweets?.allObjects as! [Tweet])
            }) ?? [Tweet]()
            tweets.append(contentsOf: userInfo.currentUser?.tweets?.allObjects as? [Tweet] ?? [])
            tweets.sort { (lhs, rhs) -> Bool in
                guard let lhs = lhs.createdAt, let rhs = rhs.createdAt else {
                    return false
                }
                return lhs > rhs
            }
            return AnyView(Tweets(tweets: tweets, delegate: self))
        } else {
            return AnyView(Text("Please log in"))
        }
    }
    
    static func getLatestTweets() -> NSFetchRequest<Tweet> {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Tweet.createdAt, ascending: false)
        ]
        return request
    }
    
    func shouldShowRemoveButton(for user: User) -> Bool {
        return userInfo.currentUser == user || userInfo.currentUser?.role == "admin" || userInfo.currentUser?.role == "moderator"
    }
    
    func removeTweet(_ tweet: Tweet) {
        tweetManager.removeTweet(tweet)
    }
    
    func reply(to tweet: Tweet) {
        tweetManager.reply(to: tweet)
    }
    
    func showParent(of tweet: Tweet) {
        tweetManager.showParent(of: tweet)
    }
    
    func showThread(parent tweet: Tweet) {
        tweetManager.showThread(parent: tweet)
    }
    
    func edit(tweet: Tweet) {
        tweetManager.edit(tweet: tweet)
    }
    
    func showAuthor(tweet: Tweet) {
        tweetManager.showAuthor(tweet: tweet)
    }
}

struct ProfileView: View, TweetDelegate, TweetManagerDelegate, ProfileEditViewDelegate, UsersViewDelegate {
    @ObservedObject var userInfo: UserInfo
    @State var tweetToRemove: Tweet?
    var tweetManager: TweetManager
    var window: NSWindow?
    var delegate: MainWindowDelegate?
    @State var shouldShowEditProfileSheet = false
    @State var shouldShowFollowersSheet = false
    @State var shouldShowFollowsSheet = false
    @State var shouldShowAdminBanInterface = false
    @State var canEditProfile: Bool
    
    init() {
        let user = User(context: NSManagedObjectContext.shared)
        user.fullName = "Eduard Dzhumagaliev"
        user.login = "terriblegoodday"
        user.registrationDate = Date()
        user.biography = "20yo old iOS developer"
        let userInfo = UserInfo()
        userInfo.currentUser = user
        let tweet1 = Tweet(context: NSManagedObjectContext.shared)
        let tweet2 = Tweet(context: NSManagedObjectContext.shared)
        tweet1.body = "hello this is me"
        tweet2.body = "hello this is my second tweet"
        tweet1.createdAt = Date()
        tweet2.createdAt = Date()
        tweet1.author = user
        tweet2.author = user
        self.tweetManager = TweetManager()
        self.userInfo = userInfo
        _canEditProfile = State(initialValue: true)
        self.tweetManager.delegate = self
    }
    
    var currentUser: User { self.userInfo.currentUser! }
    
    init(userInfo: UserInfo, window: NSWindow? = nil, _ delegate: MainWindowDelegate? = nil) {
        self.userInfo = userInfo
        self.tweetManager = TweetManager()
        self.window = window
        _canEditProfile = State(initialValue: true)
        self.tweetManager.delegate = self
        self.delegate = delegate
    }
    
    init(userInfoForAnotherUser: UserInfo, window: NSWindow? = nil) {
        self.userInfo = userInfoForAnotherUser
        self.tweetManager = TweetManager()
        self.window = window
        _canEditProfile = State(initialValue: false)
        self.tweetManager.delegate = self
    }
    
    func isBanned() -> Bool {
        return userInfo.currentUser?.bannedBy?.contains(userInfo.user) ?? false
    }
    
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    
    var body: some View {
        ZStack {
            if userInfo.user != nil && !isBanned() {
            VStack(alignment: .leading) {
                HStack {
                    if let avatarUrl = userInfo.user?.avatarUrl, avatarUrl.count > 0, let nsImage = NSImage(contentsOfFile: avatarUrl) {
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
                        Text(userInfo.user?.fullName ?? "")
                        Text("@\(userInfo.user?.login ?? "")")
                        if let date = userInfo.user?.registrationDate {
                            HStack(spacing: 4) { Text("registered on"); Text(date, style: .date) }
                        }
                        Text(userInfo.user!.city?.name ?? "no city specified")
                        Text(userInfo.user!.biography ?? "no biography")
                        HStack { Button(action: {showFollows()}) {
                            Text("follows: \(userInfo.user!.follows?.count ?? 0)")
                        }.buttonStyle(BorderlessButtonStyle()).padding(0).sheet(isPresented: $shouldShowFollowsSheet) {
                            UsersView(users: userInfo.user?.follows?.allObjects as [User] ?? [User](), delegate: self).frame(width: 480, height: 320, alignment: .center)
                        }
                        Button(action: {showFollowers()}) {
                            Text("followers: \(userInfo.user!.followers?.count ?? 0)")
                        }.buttonStyle(BorderlessButtonStyle()).padding(0).sheet(isPresented: $shouldShowFollowersSheet) {
                            UsersView(users: userInfo.user?.followers?.allObjects as [User] ?? [User](), delegate: self).frame(width: 480, height: 320, alignment: .center)
                        }
                        }
                    }
                    .padding(.leading, 8)
                    Spacer()
                    if canEditProfile {
                        Button(action: {
                            shouldShowEditProfileSheet.toggle()
                        }, label: {
                            Text("Edit profile")
                        }).buttonStyle(BorderedButtonStyle()).sheet(isPresented: $shouldShowEditProfileSheet) {
                            ProfileEditView(with: userInfo.user!, delegate: self).frame(width: 480, height: 320, alignment: .center)
                        }
                    } else if userInfo.currentUser?.login != nil {
                        VStack {
                            if !(userInfo.currentUser!.follows?.contains(userInfo.user) ?? false) && userInfo.currentUser != userInfo.user {
                                Button(action: {
                                    subscribeToProfile()
                                }) {
                                    Text("Subscribe")
                                }
                            } else if userInfo.currentUser != userInfo.user {
                                Button(action: {
                                    unsubscribeFromProfile()
                                }) {
                                    Text("Unsubscribe")
                                }
                            }
                            if userInfo.currentUser != userInfo.user && userInfo.currentUser != nil && !(userInfo.user?.bannedBy?.contains(userInfo.currentUser) ?? false) {
                                Button(action: {
                                    blockUser()
                                }) {
                                    Text("Block")
                                }
//                                }.sheet(isPresented: $shouldShowAdminBanInterface, content: {
//                                    AdminBanView(startDate: $startDate)
//                                })
                            } else if userInfo.currentUser != userInfo.user {
                                Button(action: {
                                    unblockUser()
                                }) {
                                    Text("Unblock")
                                }
                            }
                        }
                        
                    }
                }.padding()
                Divider()
                if let tweets = userInfo.user?.tweets {
                    Tweets(tweets: tweets.sortedArray(using: [NSSortDescriptor(keyPath: \Tweet.createdAt, ascending: false)]) as! [Tweet], delegate: self, toggleActive: false).background(Color.clear)
                }
                Spacer()
            }.background(Color.init(NSColor.controlBackgroundColor))
            .frame(alignment: .topLeading)
            } else if userInfo.currentUser?.bannedBy?.contains(userInfo.user) ?? false {
                VStack {
                    Text(userInfo.user?.fullName ?? "")
                    Text("@\(userInfo.user?.login ?? "")")
                    if let date = userInfo.user?.registrationDate {
                        HStack(spacing: 4) { Text("registered on"); Text(date, style: .date) }
                    }
                    Text("You're banned by \(userInfo.user?.login ?? "")")
                }
            }
            else {
            Text("No profile to show").font(.title)
            }
        }
    }
    
    func blockUser() {
        if userInfo.currentUser?.role == "admin" || userInfo.currentUser?.role == "moderator" {
            shouldShowAdminBanInterface.toggle()
        } else {
            userInfo.currentUser?.addToBannedUsers(userInfo.user!)
            NSManagedObjectContext.saveShared()
        }
    }
    
    func unblockUser() {
        userInfo.currentUser?.removeFromBannedUsers(userInfo.user!)
        NSManagedObjectContext.saveShared()
    }
    
    func dismiss() {
        shouldShowFollowersSheet = false
        shouldShowFollowsSheet = false
    }
    
    func showFollows() {
        self.shouldShowFollowsSheet = true
    }
    
    func showFollowers() {
        self.shouldShowFollowersSheet = true
    }
    
    func subscribeToProfile() {
        userInfo.currentUser?.addToFollows(userInfo.user!)
        NSManagedObjectContext.saveShared()
    }
    
    func unsubscribeFromProfile() {
        userInfo.currentUser?.removeFromFollows(userInfo.user!)
        NSManagedObjectContext.saveShared()
    }
    
    func editProfile() {
        tweetManager.edit(profile: userInfo.currentUser!)
    }
    
    func shouldShowRemoveButton(for user: User) -> Bool {
        return userInfo.currentUser == user
    }
    
    func removeTweet(_ tweet: Tweet) {
        tweetManager.removeTweet(tweet)
    }
    
    func reply(to tweet: Tweet) {
        tweetManager.reply(to: tweet)
    }
    
    func showAuthor(tweet: Tweet) {
        tweetManager.showAuthor(tweet: tweet)
    }
    
    func showParent(of tweet: Tweet) {
        tweetManager.showParent(of: tweet)
    }
    
    func showThread(parent tweet: Tweet) {
        tweetManager.showThread(parent: tweet)
    }
    
    func edit(tweet: Tweet) {
        tweetManager.edit(tweet: tweet)
    }
    
    func cancelEdit() {
        shouldShowEditProfileSheet = false
    }
    
    func saveChanges() {
        NSManagedObjectContext.saveShared()
        shouldShowEditProfileSheet = false
    }
    
    func logout() {
        delegate?.logout()
    }
    
    func destroy() {
        delegate?.destroy()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            #if DEBUG
            let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            ContentView().frame(minWidth: 320, idealWidth: 320, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 600, idealHeight: 600, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .environment(\.managedObjectContext, context)
            #endif
            TweetsView().frame(minWidth: 320, idealWidth: 320, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 600, idealHeight: 600, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            ProfileView().frame(minWidth: 320, idealWidth: 320, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 600, idealHeight: 600, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}


