package com.github.jetbrains.rssreader.compose

import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.net.Uri
import com.github.jetbrains.rssreader.App

internal actual fun openUrl(url: String?) {
    val uri = url?.let { Uri.parse(it) } ?: return
    App.context.startActivity(
        Intent(Intent.ACTION_VIEW, uri).apply {
            flags += FLAG_ACTIVITY_NEW_TASK
        }
    )
}