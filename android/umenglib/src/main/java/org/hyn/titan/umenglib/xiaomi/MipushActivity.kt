package org.hyn.titan.umenglib.xiaomi

import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.hyn.titan.tools.AppPrintTools
import org.android.agoo.common.AgooConstants
import com.umeng.message.UmengNotifyClickActivity
import org.hyn.titan.umenglib.R


class MipushActivity : UmengNotifyClickActivity() {

    override fun onCreate(p0: Bundle?) {
        super.onCreate(p0)
        setContentView(R.layout.activity_mipush)
    }

    override
    fun onMessage(intent: Intent) {
        super.onMessage(intent)  //此方法必须调用，否则无法统计打开数

        val body = intent.getStringExtra(AgooConstants.MESSAGE_BODY)
        AppPrintTools.printLog("MipushActivity onMessage $body")
        Log.i(TAG, "register success：deviceToken：-------->clickclick")
        Log.i(TAG, body)
    }

    companion object {
        private val TAG = MipushActivity::class.java.name
    }
}