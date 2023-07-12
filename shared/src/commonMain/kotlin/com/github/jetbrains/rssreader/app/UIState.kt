package com.github.jetbrains.rssreader.app

data class UIState<T>(
    private val loading: Boolean = false,
    private val error: Throwable? = null,
    private val data: T? = null
) {
    fun hasError(): Boolean = error != null

    fun loading(): Boolean = loading

    fun error(): Throwable = error ?: error("There is no error in $this")

    fun valueOrDefault(default: T): T = data ?: default

    companion object {
        fun <T> loading(): UIState<T> = UIState(loading = true)

        fun <T> error(error: Throwable): UIState<T> = UIState(error = error)

        fun <T> content(data: T): UIState<T> = UIState(data = data)
    }
}
