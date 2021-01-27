//
//  NewTweet.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 29.01.2021.
//

import SwiftUI
import Foundation
import AppKit

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
        }

    }
}

struct NewTweet: View {
    var presenter: NewTweetPresenter
    var existingTweet: Bool?
    @State var text: String = ""
    
    init() {
        self.presenter = NewTweetPresenterMock()
    }
    
    init(presenter: NewTweetPresenter) {
        self.presenter = presenter
    }
    
    init(presenter: NewTweetPresenter, text: String, existingTweet: Bool) {
        self.init(presenter: presenter)
        _text = State(wrappedValue: text)
        self.existingTweet = existingTweet
    }
    
    var hintForeground: Color {
        return (255 - text.count) < 0 ? .red : .gray
    }
    var sendShouldBeDisabled: Bool {
        return (text.isEmpty || text.count > 255)
    }
    
    func sendTweet() {
        presenter.sendTweet(body: text)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("What's on your mind?").font(.title2).foregroundColor(.gray).padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/).padding(.leading, 5)
                }
                TextEditor(text: $text).padding().font(.title2).background(Color.clear)
            }
            Divider()
            HStack {
                Text("\(255 - text.count) characters left").font(.title3).foregroundColor(self.hintForeground)
                Spacer()
                Button(action: {sendTweet()}, label: {
                    if !(existingTweet ?? false) {
                        Image(systemName: "arrow.up.circle.fill").resizable().frame(width: 24, height: 24, alignment: .center)
                    } else {
                        Image(systemName: "checkmark.circle.fill").resizable().frame(width: 24, height: 24, alignment: .center)
                    }
                }).buttonStyle(LinkButtonStyle()).border(Color.clear, width: 0).disabled(sendShouldBeDisabled)
            }.padding()
        }
    }
}

struct NewTweet_Previews: PreviewProvider {
    static var previews: some View {
        NewTweet().frame(width: 320, height: 600, alignment: .center)
    }
}
