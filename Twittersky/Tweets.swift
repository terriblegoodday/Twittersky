//
//  Tweets.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import SwiftUI

protocol TweetDelegate {
    func shouldShowRemoveButton(for user: User) -> Bool
    func removeTweet(_ tweet: Tweet)
    func reply(to tweet: Tweet)
    func showParent(of tweet: Tweet)
    func showThread(parent tweet: Tweet)
    func edit(tweet: Tweet)
    func showAuthor(tweet: Tweet)
}

struct TweetView: View {
    @Environment(\.managedObjectContext) var context
    var tweet: Tweet
    var delegate: TweetDelegate?
    @State var showAlert: Bool = false
    
    init(tweet: Tweet, delegate: TweetDelegate? = nil) {
        self.tweet = tweet
        self.delegate = delegate
    }
    
    func showAuthor() {
        delegate?.showAuthor(tweet: tweet)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                if let avatarUrl = tweet.author?.avatarUrl, avatarUrl.count > 0, let nsImage = NSImage(contentsOfFile: avatarUrl) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24, alignment: .center)
                        .scaledToFit()
                        .background(Color.primary)
                        .clipShape(Circle())
                } else {
                    Circle().frame(width: 24, height: 24, alignment: .center)
                }
                HStack {
                    Button(action: {
                        showAuthor()
                    }, label: {
                        Text(tweet.author?.fullName ?? "Неизвестный автор").bold()
                    }).buttonStyle(BorderlessButtonStyle())
                    Text("@" + (tweet.author?.login ?? ""))
                    Spacer()
                    if let date = tweet.createdAt {
                        Text(date, style: .relative).fontWeight(.medium)
                    }
                }
            }
            if tweet.parent != nil {
                Spacer(minLength: 1.0)
                Button(action: showParent) {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.left.2")
                        Text("this tweet is a reply")
                    }
                }.buttonStyle(LinkButtonStyle()).padding(.vertical, 10)
            }
            Spacer(minLength: 1.0)
            Text(tweet.body ?? "")
            Spacer()
            HStack(alignment: .top, spacing: 2.0) {
                if tweet.replies?.count ?? 0 > 0 {
                    Button(action: {
                    print("Thread button was tapped")
                        showThread()
                    }) {
                        Image(systemName: "bubble.right").resizable().frame(width: 14, height: 14, alignment: .center)
                    }.buttonStyle(BorderlessButtonStyle()).padding(.trailing, 8)
                }
                Button(action: {
                    reply()
                }) {
                    Image(systemName: "arrowshape.turn.up.left").resizable().frame(width: 14, height: 14, alignment: .center)
                }.buttonStyle(BorderlessButtonStyle())
                Spacer()
                if let author = tweet.author, delegate?.shouldShowRemoveButton(for: author) ?? true {
                    HStack{
                        Button(action: editTweet) {
                            Image(systemName: "pencil.circle").resizable().frame(width: 14, height: 14, alignment: .center)
                        }.buttonStyle(BorderlessButtonStyle())
                    Button(action: {
                        showAlert.toggle()
                    }) {
                        Image(systemName: "trash").resizable().frame(width: 14, height: 14, alignment: .center)
                    }.buttonStyle(BorderlessButtonStyle()).alert(isPresented: $showAlert) {
                        Alert(title: Text("Are you sure you want to remove this tweet?"), message: Text("This action can't be undone"), primaryButton: .destructive(Text("Remove"), action: removeTweet), secondaryButton: .cancel(Text("Cancel")))
                    }}
                }
            }.controlSize(.large)
            .padding(.bottom, 10)
            Divider().padding(.bottom, 5)
        }
    }
    
    func editTweet() {
        delegate?.edit(tweet: tweet)
    }
    
    func showParent() {
        delegate?.showParent(of: tweet)
    }
    
    func reply() {
        delegate?.reply(to: tweet)
    }
    
    func removeTweet() {
        delegate?.removeTweet(tweet)
    }
    
    func showThread() {
        delegate?.showThread(parent: tweet)
    }
}

struct Tweets: View, TweetDelegate {
    var tweets: [Tweet] = [Tweet]()
    var delegate: TweetDelegate? = nil
    var toggleActive: Bool
    
    init() {
        self.toggleActive = true
        let tweet = Tweet(context: NSManagedObjectContext.shared)
        tweet.body = "hey"
        tweet.author = User(context: NSManagedObjectContext.shared)
        tweet.author?.fullName = "Eduard Dzhumagaliev"
        tweet.author?.login = "terriblegoodday"
        self.tweets.append(tweet)
    }
    
    init(tweets: [Tweet], delegate: TweetDelegate? = nil, toggleActive: Bool? = true) {
        self.tweets.append(contentsOf: tweets)
        self.delegate = delegate
        self.toggleActive = toggleActive ?? true
    }
    
    var body: some View {
        Group{
        VStack(alignment: .leading) {
//            if toggleActive {
//                CardView()
//                    .padding([.leading]).padding(.top, 8)
//            }
            List {
                ForEach(tweets, id: \.id) { tweet in
                    TweetView(tweet: tweet, delegate: self)
                }
            }
        }.background(Color.init(NSColor.controlBackgroundColor))}
    }
    
    func shouldShowRemoveButton(for user: User) -> Bool {
        return delegate?.shouldShowRemoveButton(for: user) ?? true
    }
    
    func removeTweet(_ tweet: Tweet) {
        delegate?.removeTweet(tweet)
    }
    
    func reply(to tweet: Tweet) {
        delegate?.reply(to: tweet)
    }
    
    func showParent(of tweet: Tweet) {
        delegate?.showParent(of: tweet)
    }
    
    func showThread(parent tweet: Tweet) {
        delegate?.showThread(parent: tweet)
    }
    
    func showAuthor(tweet: Tweet) {
        delegate?.showAuthor(tweet: tweet)
    }
    
    func edit(tweet: Tweet) {
        delegate?.edit(tweet: tweet)
    }
}

struct Tweets_Previews: PreviewProvider {
    static var previews: some View {
        Tweets()
    }
}
