package org.hyn.titan.umenglib.interfaces

interface OnPushChangeListener{
    fun onTokenSuccess(deviceToken: String)
    fun onTokenFail(s: String, s1: String)
}