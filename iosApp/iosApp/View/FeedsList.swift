//
//  FeedsList.swift
//  iosApp
//
//  Created by Ekaterina.Petrova on 11.11.2020.
//  Copyright © 2020 orgName. All rights reserved.
//

import SwiftUI
import RssReader

struct FeedsList: View {
    @EnvironmentObject var store: ObservableFeedStore
    @SwiftUI.State var showsAlert: Bool = false
    
    var body: some View {
        let defaultFeeds = store.data.filter { $0.isDefault }
        let userFeeds = store.data.filter { !$0.isDefault }
        
        List {
            ForEach(defaultFeeds) { FeedRow(feed: $0) }
            ForEach(userFeeds) { FeedRow(feed: $0) }
                .onDelete( perform: { set in
                    set.map { userFeeds[$0] }.forEach { store.feedStore.deleteFeed(url: $0.sourceUrl) }
                })
        }
        .alert(isPresented: $showsAlert, TextAlert(title: "Title") {
            if let url = $0 {
                store.feedStore.addFeed(url: url)
            }
        })
        .navigationTitle("Feeds list")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            showsAlert = true
        }) {
            Image(systemName: "plus.circle").imageScale(.large)
        })
    }
}

extension Feed: Identifiable { }

