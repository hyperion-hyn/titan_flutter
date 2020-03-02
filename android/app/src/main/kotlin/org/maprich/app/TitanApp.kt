package org.maprich.app

import android.util.Log
import io.flutter.app.FlutterApplication
import io.reactivex.exceptions.UndeliverableException
import io.reactivex.functions.Consumer
import io.reactivex.plugins.RxJavaPlugins
import org.hyn.titan.umenglib.BuildConfig
import org.hyn.titan.umenglib.interfaces.IUMengPush
import org.hyn.titan.umenglib.interfaces.OnPushChangeListener
import org.hyn.titan.umenglib.push.UMengPushImpl
import org.jetbrains.anko.runOnUiThread
import org.jetbrains.anko.toast
import timber.log.Timber
import java.io.IOException


class TitanApp : FlutterApplication() {

    var iUMengPush = UMengPushImpl()

    override fun onCreate() {
        super.onCreate()
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }

        //https://github.com/ReactiveX/RxJava/wiki/What%27s-different-in-2.0#error-handling
        RxJavaPlugins.setErrorHandler(Consumer<Throwable> { t: Throwable? ->
            var e = t
            if (e is UndeliverableException) {
                e = e.cause
            }
            if (e is IOException) {
                // fine, irrelevant network problem or API that throws on cancellation
                return@Consumer
            }
            if (e is InterruptedException) {
                // fine, some blocking code was interrupted by a dispose call
                return@Consumer
            }
            if (e is NullPointerException || e is IllegalArgumentException) {
                // that's likely a bug in the application
                Thread.currentThread().uncaughtExceptionHandler
                        .uncaughtException(Thread.currentThread(), e)
                return@Consumer
            }
            if (e is IllegalStateException) {
                // that's a bug in RxJava or in a custom operator
                Thread.currentThread().uncaughtExceptionHandler
                        .uncaughtException(Thread.currentThread(), e)
                return@Consumer
            }
            e?.printStackTrace()
            Timber.w("rx exception")
        })

        /** umeng init **/
        iUMengPush.initUMeng(this)

//        iUMengPush.initUMeng(this)
    }

    private val onPushChangeListener = object : OnPushChangeListener {
        override fun onTokenSuccess(deviceToken: String) {
        }

        override fun onTokenFail(s: String, s1: String) {
            print("push#onTokenFail")
        }

    }

    /*fun getUMengToken() : String{
        return iUMengPush.getUMengToken()
    }*/
}