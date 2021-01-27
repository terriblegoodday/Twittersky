//
//  SearchView.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 01.02.2021.
//

import SwiftUI

protocol CardViewDelegate {
    func showTweetsFromSubscribers()
    func showGlobalTweets()
}

struct CardView: View {
    @Binding var query: String
    
    init(query: Binding<String>) {
        _query = query
    }
    
    var body: some View {
        VStack(alignment: .leading, content: {
            HStack {
                TextField("Search tweets", text: $query).textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding(.trailing, 15 )
        })
    }
}

struct CardView_Previews: PreviewProvider {
    @State static var query: String = ""
    
    static var previews: some View {
        CardView(query: $query).frame(width: 320, height: 100, alignment: .center)
    }
}

struct SearchView: View, TweetDelegate {
    @State var currentQuery: String = ""
    @State var tweets: [Tweet]
    var delegate: TweetDelegate?
    
    func loadAllTweets() {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Tweet.createdAt, ascending: false)]
        if let response = try? NSManagedObjectContext.shared.fetch(request) {
            self.tweets = response
        } else {
            self.tweets = []
        }
    }
    
    init(with delegate: TweetDelegate?) {
        self.delegate = delegate
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Tweet.createdAt, ascending: false)]
        if let response = try? NSManagedObjectContext.shared.fetch(request) {
            _tweets = State(initialValue: response)
        } else {
            _tweets = State(initialValue: [])
        }
    }
    
    var body: some View {
        Group{
        VStack(alignment: .leading) {
            CardView(query: $currentQuery)
                .padding([.leading]).padding(.top, 8)
            List {
                ForEach(tweets) { (tweet: Tweet) in
                    TweetView(tweet: tweet, delegate: self)
                }
            }.onChange(of: currentQuery, perform: { value in
                if value.count == 0 {
                    loadAllTweets()
                    return
                }
                let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \Tweet.createdAt, ascending: false)]
                request.predicate = NSPredicate(format: "body CONTAINS[dc] %@", currentQuery.uppercased())
                if let response = try? NSManagedObjectContext.shared.fetch(request) {
                    self.tweets = response
                } else {
                    self.tweets = [Tweet]()
                }
            })
        }.background(Color.init(NSColor.controlBackgroundColor))}
    }
    
    // MARK: - TweetDelegate
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
    
    func edit(tweet: Tweet) {
        delegate?.edit(tweet: tweet)
    }
    
    func showAuthor(tweet: Tweet) {
        delegate?.showAuthor(tweet: tweet)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(with: nil)
    }
}
