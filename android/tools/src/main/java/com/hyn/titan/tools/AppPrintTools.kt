package com.hyn.titan.tools

object AppPrintTools {

    lateinit var appPrintInterface: AppPrintInterface

    fun printLog(logMsg: String) {
        if(appPrintInterface == null){
            return
        }
        appPrintInterface.printLog(logMsg)
    }
}