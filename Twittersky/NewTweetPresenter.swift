//
//  NewTweetPresenter.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import Foundation

protocol NewTweetPresenter {
    func sendTweet(body: String)
}

class NewTweetPresenterMock: NewTweetPresenter {
    func sendTweet(body: String) {}
}
