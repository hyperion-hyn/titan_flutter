package org.hyn.titan.business.qrcode

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.Vibrator
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProviders
import cn.bingoogolapple.qrcode.core.QRCodeView
import com.trello.rxlifecycle3.android.lifecycle.kotlin.bindToLifecycle
import com.trello.rxlifecycle3.components.support.RxAppCompatActivity
import io.reactivex.Flowable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_qrcode_scan.*
import org.hyn.titan.R
import org.hyn.titan.databinding.ActivityQrcodeScanBinding
import org.jetbrains.anko.toast
import timber.log.Timber
import java.util.concurrent.TimeUnit

class QRCodeScanActivity : RxAppCompatActivity(), QRCodeView.Delegate {
    private lateinit var binding: ActivityQrcodeScanBinding
    private lateinit var viewModel: QRCodeScanViewModel

    private val REQUEST_CODE_CHOOSE_QRCODE_FROM_GALLERY = 666
    private val REQUEST_CAMERA_PERMISSION_CODE = 1

    private var isFlashOn = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(QRCodeScanViewModel::class.java)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_qrcode_scan)
        binding.viewModel = viewModel

        ivBack.setOnClickListener {
            onBackPressed()
        }

        tvAlbum.setOnClickListener {
            val albumIntent = Intent(Intent.ACTION_PICK)
            albumIntent.data = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
//            albumIntent.type = "image/*"
            startActivityForResult(albumIntent, REQUEST_CODE_CHOOSE_QRCODE_FROM_GALLERY)
        }

        ivFlashLight.setOnClickListener {
            val flashOn = viewModel.isFlashOn.get() ?: false
            if (flashOn) {
                zxingview.closeFlashlight()
            } else {
                zxingview.openFlashlight()
            }
            viewModel.isFlashOn.set(!flashOn)
        }

        zxingview.changeToScanQRCodeStyle()
        zxingview.setDelegate(this)
    }

    @SuppressLint("CheckResult")
    override fun onScanQRCodeSuccess(result: String?) {
        Timber.i("result: $result")
        vibrate();

        if (result?.length == 130) { //公钥长度
            val intent = Intent()
            intent.putExtra("code", result)
            setResult(Activity.RESULT_OK, intent)
            finish()
        } else {
            toast(getString(R.string.qrcode_scan_public_key_qrcode_tips))
            Flowable.timer(1, TimeUnit.SECONDS)
                    .bindToLifecycle(this)
                    .subscribe() {
                        zxingview.startSpot(); // 开始识别
                    }
        }
    }

    override fun onCameraAmbientBrightnessChanged(isDark: Boolean) {
    }

    override fun onScanQRCodeOpenCameraError() {
        toast(R.string.qrcode_open_camera_error)
    }

    private fun vibrate() {
        val vibrator = getSystemService(VIBRATOR_SERVICE) as Vibrator
        vibrator.vibrate(200);
    }

    override fun onStart() {
        super.onStart()

        startScan()
    }

    private fun startScan() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), REQUEST_CAMERA_PERMISSION_CODE)
        } else {
            zxingview.startCamera() // 打开后置摄像头开始预览，但是并未开始识别
            //        mZXingView.startCamera(Camera.CameraInfo.CAMERA_FACING_FRONT); // 打开前置摄像头开始预览，但是并未开始识别
            zxingview.startSpotAndShowRect() // 显示扫描框，并开始识别
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CAMERA_PERMISSION_CODE) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                startScan()
                recreate()
            } else {
                toast(R.string.qrcode_camera_auth_fail)
            }
        }
    }

    override fun onStop() {
        zxingview.stopCamera() // 关闭摄像头预览，并且隐藏扫描框
        super.onStop()
    }

    override fun onDestroy() {
        zxingview.onDestroy() // 销毁二维码扫描控件
        super.onDestroy()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        zxingview.startSpotAndShowRect(); // 显示扫描框，并开始识别
        if (resultCode == Activity.RESULT_OK && requestCode == REQUEST_CODE_CHOOSE_QRCODE_FROM_GALLERY) {
//            val picturePath = BGAPhotoPickerActivity.getSelectedPhotos(data)[0];
//            // 本来就用到 QRCodeView 时可直接调 QRCodeView 的方法，走通用的回调
            val uri = data?.data
            if (uri != null) {
                Flowable.fromCallable {
                    val bitmap = BitmapFactory.decodeStream(contentResolver.openInputStream(uri))
                    zxingview.decodeQRCode(bitmap);
                    return@fromCallable true
                }.subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe()
            }

        }
    }
}