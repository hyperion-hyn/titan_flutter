package org.hyn.titan

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.hyn.titan.tools.AppPrintTools
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.hyn.titan.utils.AppToolsPlugin
import org.jetbrains.anko.intentFor

class SplashActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        /*GeneratedPluginRegistrant.registerWith(this)
        AppToolsPlugin.registerWith(this)
        GlobalScope.launch {
            Thread.sleep(2000)
            withContext(Dispatchers.Main) {
                var data = intent.data
                intent.setClass(,MainActivity.class)
                AppPrintTools.printLog("main splash onCreate = $data")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

                startActivity(intent)
                finish()
            }
        }*/

        var data = intent.data
        intent.setClass(this,MainActivity::class.java)
        AppPrintTools.printLog("main splash onCreate = $data")
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

        startActivity(intent)
        finish()
    }
}
