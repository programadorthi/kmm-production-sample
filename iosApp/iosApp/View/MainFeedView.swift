import SwiftUI
import RssReader
import URLImage

struct MainFeedView: View {
   
    @EnvironmentObject var store: ObservableFeedStore
    @SwiftUI.State private var selectedFeed: Feed? = nil
    @SwiftUI.State private var showSelectFeed: Bool = false
    
    init() {
        UITableView.appearance().backgroundColor = .white
    }
    
    var body: some View {
        VStack {
            if showSelectFeed {
                feedPicker()
            }
            let posts = (selectedFeed?.posts ?? store.data.flatMap { $0.posts })
                .sorted { $0.date > $1.date }
            List(posts, rowContent: PostRow.init)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: refreshButton(), trailing: editFeedLink)
        .toolbar {
            ToolbarItem(placement: .principal) {
                navigationTitle()
            }
        }
        .onAppear {
            store.feedStore.loadAllFeeds(forceLoad: false)
        }
    }
    
    var refreshButtionAnimation: Animation {
        Animation.linear(duration: 0.8).repeatForever(autoreverses: false)
    }
    
    func navigationTitle() -> some View {
        VStack {
            HStack {
                Text("RSS Reader").font(.headline)
                Button(action: {
                    withAnimation { showSelectFeed.toggle() }
                }) {
                    Image(systemName: showSelectFeed ? "chevron.up" : "chevron.down").imageScale(.small)
                }
            }
            Text(selectedFeed?.title ?? "All").font(.subheadline).lineLimit(1)
        }
    }
    
    
    func feedPicker() -> some View {
        let binding = Binding<Feed?>(
            get: { store.selected },
            set: { store.selected = $0 }
        )
        return Picker("", selection: binding) {
            ForEach(store.data, id: \.self) { feed in
                HStack {
                    if let imageUrl = feed.imageUrl, let url = URL(string: imageUrl) {
                        
                        URLImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .frame(width: 24, height: 24)
                        .cornerRadius(12.0)
                        .clipped()
                    }
                    Text(feed.title)
                }
            }
        }
        .background(Color("FeedPicker"))
        .pickerStyle(.wheel)
    }
    
    func refreshButton() -> some View {
        Button(action: {
            store.feedStore.loadAllFeeds(forceLoad: true)
        }) {
            Image(systemName: "arrow.clockwise")
                .imageScale(.large)
                .rotationEffect(Angle.degrees(store.loading ? 360 : 0)).animation( store.loading ? refreshButtionAnimation : .default)
        }
    }
    
    var editFeedLink: some View {
        NavigationLink(destination: NavigationLazyView<FeedsList>(FeedsList())) {
            Image(systemName: "pencil.circle").imageScale(.large)
        }
    }
    
}

extension Post: Identifiable { }
