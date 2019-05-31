package org.hyn.titan

import android.os.Bundle
import android.os.Handler
import android.util.Log
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val TAG by lazy { this::class.java.simpleName }

    private val callChannel by lazy { MethodChannel(flutterView, "org.hyn.titan/call_channel") }
    private val cipherEventChannel by lazy { EventChannel(flutterView, "org.hyn.titan/event_stream") }

    private val cipher by lazy { mobile.Cipher() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        callChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "nativeGreet" -> {
                    val m = mapOf("where" to "native", "name" to "moo", "age" to 19)
                    callChannel.invokeMethod("dartGreet", m, object : MethodChannel.Result {
                        override fun notImplemented() {
                            result.notImplemented()
                        }

                        override fun error(p0: String?, p1: String?, p2: Any?) {
                            result.error(p0, p1, p2)
                        }

                        override fun success(p0: Any?) {
                            result.success(p0)
                        }

                    })
                }
                "genKeyPair" -> {
                    result.success("not ready")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        cipherEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                Log.i(TAG, "onListen ${arguments?.toString()}")
                //do some test
                tickTimes = 5
                tickSink(eventSink)
            }

            override fun onCancel(arguments: Any?) {
                Log.i(TAG, "onCancel listener ${arguments?.toString()}")
            }
        })
    }

    private var tickTimes = 0
    private fun tickSink(eventSink: EventChannel.EventSink) {
        if (tickTimes > 0) {
            tickTimes--
            Handler().postDelayed(Runnable {
                eventSink.success(tickTimes)
                if (tickTimes > 0) {
                    tickSink(eventSink)
                }
            }, 1000)
        }
    }
}
