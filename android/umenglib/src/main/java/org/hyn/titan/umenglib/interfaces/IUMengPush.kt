package org.hyn.titan.umenglib.interfaces

import android.content.Context

interface IUMengPush{
    fun initUMeng(context: Context,onPushListener: OnPushListener)
    fun getUMengToken():String
}