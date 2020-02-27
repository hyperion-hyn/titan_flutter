package org.hyn.titan.umenglib.push

import android.app.Application
import android.content.Context
import android.util.Log
import android.widget.Toast
import com.taobao.accs.utl.ALog
import com.umeng.commonsdk.UMConfigure
import org.hyn.titan.umenglib.interfaces.IUMengPush
import com.umeng.message.IUmengRegisterCallback
import com.umeng.message.PushAgent
import org.android.agoo.huawei.HuaWeiRegister
import org.android.agoo.mezu.MeizuRegister
import org.android.agoo.xiaomi.MiPushRegistar
import org.hyn.titan.umenglib.interfaces.OnPushChangeListener


class UMengPushImpl : IUMengPush{

    private val LOG_TAG : String = "umeng_push_titan"
    private var umengToken : String = ""

    override fun initUMeng(context: Context) {
        Log.i(LOG_TAG, "initUMeng")
        UMConfigure.setLogEnabled(true)
        UMConfigure.init(context, UMengConstants.UMENG_APPKEY, "Umeng", UMConfigure.DEVICE_TYPE_PHONE, UMengConstants.UMENG_MESSAGE_SECRET)

        //获取消息推送代理示例
        val mPushAgent = PushAgent.getInstance(context)
        //注册推送服务，每次调用register方法都会回调该接口
        mPushAgent.register(object : IUmengRegisterCallback {
            override fun onSuccess(deviceToken: String) {
                //注册成功会返回deviceToken deviceToken是推送消息的唯一标志
                Log.i(LOG_TAG, "register success：deviceToken：-------->  $deviceToken")
                umengToken = deviceToken
            }

            override fun onFailure(s: String, s1: String) {
                Log.e(LOG_TAG, "register fail：-------->  s:$s,s1:$s1")
            }
        })

        MiPushRegistar.register(context, UMengConstants.UMENG_XIAOMI_APPID, UMengConstants.UMENG_XIAOMI_SECRET)

        HuaWeiRegister.register(context as Application)

        MeizuRegister.register(context, UMengConstants.UMENG_MEIZU_APPID, UMengConstants.UMENG_MEIZU_APPKEY)
    }

    override fun getUMengToken() : String {
        return umengToken
    }

}