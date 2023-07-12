package com.github.jetbrains.rssreader.app

import com.github.jetbrains.rssreader.core.RssReader
import com.github.jetbrains.rssreader.core.entity.Feed
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class FeedStore(
    private val rssReader: RssReader
) : CoroutineScope by CoroutineScope(Dispatchers.Main) {

    private val mutableState = MutableStateFlow<UIState<List<Feed>>>(UIState.loading())
    private val mutableSelectedFeed = MutableStateFlow<Feed?>(null)

    val state: StateFlow<UIState<List<Feed>>>
        get() = mutableState
    val selectedFeed: StateFlow<Feed?>
        get() = mutableSelectedFeed

    fun selectFeed(feed: Feed?) {
        launch {
            mutableSelectedFeed.emit(feed)
        }
    }

    fun loadAllFeeds(forceLoad: Boolean) {
        wrapAction {
            rssReader.getAllFeeds(forceLoad)
        }
    }

    fun addFeed(url: String) {
        wrapAction {
            rssReader.addFeed(url)
            rssReader.getAllFeeds(false).also(::doSelection)
        }
    }

    fun deleteFeed(url: String) {
        wrapAction {
            rssReader.deleteFeed(url)
            rssReader.getAllFeeds(false).also(::doSelection)
        }
    }

    private fun doSelection(feeds: List<Feed>) {
        val toSelect = feeds.firstOrNull { it == selectedFeed.value }
        selectFeed(toSelect)
    }

    private fun wrapAction(action: suspend () -> List<Feed>) {
        launch {
            mutableState.emit(UIState.loading())
            runCatching {
                mutableState.emit(UIState.content(action()))
            }.getOrElse { exception ->
                mutableState.emit(UIState.error(exception))
            }
        }
    }
}
