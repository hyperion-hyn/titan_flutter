package org.hyn.titan.umenglib.push

import android.app.Application
import android.app.Notification
import android.content.Context
import android.util.Log
import android.widget.Toast
import com.google.gson.Gson
import com.hyn.titan.tools.AppPrintTools
import com.taobao.accs.utl.ALog
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import org.hyn.titan.umenglib.interfaces.IUMengPush
import com.umeng.message.IUmengRegisterCallback
import com.umeng.message.PushAgent
import com.umeng.message.UmengMessageHandler
import com.umeng.message.UmengNotificationClickHandler
import com.umeng.message.entity.UMessage
import org.android.agoo.huawei.HuaWeiRegister
import org.android.agoo.mezu.MeizuRegister
import org.android.agoo.xiaomi.MiPushRegistar
import org.hyn.titan.umenglib.interfaces.OnPushListener
import org.json.JSONObject


class UMengPushImpl : IUMengPush{

    private val LOG_TAG : String = "umeng_push_titan"
    private lateinit var onPushListener: OnPushListener
//    private var umengToken : String = "default"

    companion object{
        var umengToken : String = "default"
    }

    override fun initUMeng(context: Context,onPushListener: OnPushListener) {
        Log.i(LOG_TAG, "initUMeng")
        this.onPushListener = onPushListener
        UMConfigure.setLogEnabled(true)
        UMConfigure.init(context, UMengConstants.UMENG_APPKEY, "Umeng", UMConfigure.DEVICE_TYPE_PHONE, UMengConstants.UMENG_MESSAGE_SECRET)

        // 选用AUTO页面采集模式
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO)

        //获取消息推送代理示例
        val mPushAgent = PushAgent.getInstance(context)

        /**注册点击响应**/
        mPushAgent.notificationClickHandler = notificationClickHandler

        //注册推送服务，每次调用register方法都会回调该接口
        mPushAgent.register(object : IUmengRegisterCallback {
            override fun onSuccess(deviceToken: String) {
                //注册成功会返回deviceToken deviceToken是推送消息的唯一标志
                umengToken = deviceToken
                Log.i(LOG_TAG, "register success：deviceToken：-------->  $deviceToken")
//                AppPrintTools.printLog("flutter ====== register success：deviceToken：-------->  $deviceToken")
            }

            override fun onFailure(s: String, s1: String) {
                Log.e(LOG_TAG, "register fail：-------->  s:$s,s1:$s1")
            }
        })

        MiPushRegistar.register(context, UMengConstants.UMENG_XIAOMI_APPID, UMengConstants.UMENG_XIAOMI_SECRET)

        HuaWeiRegister.register(context as Application)

        MeizuRegister.register(context, UMengConstants.UMENG_MEIZU_APPID, UMengConstants.UMENG_MEIZU_APPKEY)
    }

    private val notificationClickHandler = object : UmengNotificationClickHandler() {
        override fun dealWithCustomAction(p0: Context?, p1: UMessage?) {
            AppPrintTools.printLog("notificationClickHandler")
            onPushListener?.onPushClick(p1?.title,p1?.extra?.get("out_link") ?: "",p1?.extra?.get("content") ?: "")
            AppPrintTools.printLog("notificationClickHandler = " + p1?.title + " "
                    + p1?.extra?.get("out_link")+ " " + p1?.extra?.get("content"))
            AppPrintTools.printLog("notificationClickHandler = " + Gson().toJson(p1))
//            super.dealWithCustomAction(p0, p1)
        }
    }

    override fun getUMengToken() : String {
        return umengToken
    }

}