package com.hyn.titan.tools

import android.util.Log

object AppPrintTools {

    var appPrintInterface: AppPrintInterface? = null

    fun printLog(logMsg: String) {
        if(appPrintInterface == null){
            return
        }
        appPrintInterface?.printLog(logMsg)
    }
}