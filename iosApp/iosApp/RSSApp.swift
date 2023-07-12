//
//  App.swift
//  iosApp
//
//  Created by Ekaterina.Petrova on 13.11.2020.
//  Copyright © 2020 orgName. All rights reserved.
//

import Foundation
import SwiftUI
import RssReader

@main
class RSSApp: App {
    let rss: RssReader
    let store: ObservableFeedStore
    
    required init() {
        rss = RssReader.Companion().create(withLog: true)
        store = ObservableFeedStore(store: FeedStore(rssReader: rss))
    }
  
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store)
        }
    }
}

class ObservableFeedStore: ObservableObject {
    @Published public var error: KotlinThrowable?
    @Published public var loading: Bool = false
    @Published public var data: Array<Feed> = []
    @Published public var selected: Feed? = nil
    
    let feedStore: FeedStore
    
    var selectWatcher : Closeable?
    var stateWatcher : Closeable?

    init(store: FeedStore) {
        self.feedStore = store
        
        stateWatcher = self.feedStore.watchState().watch { [weak self] state in
            let feeds = state?.valueOrDefault(default: [])
            self?.data = feeds?.map { $0 as! Feed } ?? []
            
            if (state?.hasError() == true) {
                self?.error = state?.error()
            }
            
            self?.loading = state?.loading() ?? false
        }
        
        selectWatcher = self.feedStore.watchSelected().watch { [weak self] feed in
            self?.selected = feed
        }
    }
    
    deinit {
        selectWatcher?.close()
        stateWatcher?.close()
    }
}
