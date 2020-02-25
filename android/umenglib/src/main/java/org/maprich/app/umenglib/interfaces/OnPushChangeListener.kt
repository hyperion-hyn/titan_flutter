package org.maprich.app.umenglib.interfaces

interface OnPushChangeListener{
    fun onTokenSuccess(deviceToken: String)
    fun onTokenFail(s: String, s1: String)
}