package org.maprich.app.umenglib.interfaces

import android.content.Context

interface IUMengPush{
    fun initUMeng(context: Context)
    fun getUMengToken():String
}