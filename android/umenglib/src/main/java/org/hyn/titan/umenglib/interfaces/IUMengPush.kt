package org.hyn.titan.umenglib.interfaces

import android.content.Context

interface IUMengPush{
    fun initUMeng(context: Context)
    fun getUMengToken():String
}