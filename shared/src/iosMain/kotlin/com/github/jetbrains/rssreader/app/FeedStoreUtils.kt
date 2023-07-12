package com.github.jetbrains.rssreader.app

import com.github.jetbrains.rssreader.core.wrap

fun FeedStore.watchSelected() = selectedFeed.wrap()

fun FeedStore.watchState() = state.wrap()
