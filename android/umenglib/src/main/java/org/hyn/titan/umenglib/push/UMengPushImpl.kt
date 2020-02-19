package org.hyn.titan.umenglib.push

import android.content.Context
import android.util.Log
import android.widget.Toast
import com.umeng.commonsdk.UMConfigure
import org.hyn.titan.umenglib.interfaces.IUMengPush
import com.umeng.message.IUmengRegisterCallback
import com.umeng.message.PushAgent
import org.hyn.titan.umenglib.interfaces.OnPushChangeListener


class UMengPushImpl : IUMengPush{

    private val LOG_TAG : String = "umeng_push_titan"
    private var umengToken : String = ""

    override fun initUMeng(context: Context) {
        Log.i(LOG_TAG, "initUMeng")
        UMConfigure.init(context, "5e4b54e8570df363b800014c", "Umeng", UMConfigure.DEVICE_TYPE_PHONE, "baa106475d99b7351420ef740eb2a24f")

        //获取消息推送代理示例
        val mPushAgent = PushAgent.getInstance(context)
        //注册推送服务，每次调用register方法都会回调该接口
        mPushAgent.register(object : IUmengRegisterCallback {
            override fun onSuccess(deviceToken: String) {
                //注册成功会返回deviceToken deviceToken是推送消息的唯一标志
                Log.i(LOG_TAG, "register success：deviceToken：-------->  $deviceToken")
                umengToken = deviceToken
//                onPushChangeListener.onTokenSuccess(deviceToken)
            }

            override fun onFailure(s: String, s1: String) {
                Log.e(LOG_TAG, "register fail：-------->  s:$s,s1:$s1")
            }
        })
    }

    override fun getUMengToken() : String {
        return umengToken
    }

}