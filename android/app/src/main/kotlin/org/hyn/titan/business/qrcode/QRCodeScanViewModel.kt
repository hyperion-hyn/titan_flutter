package org.hyn.titan.business.qrcode

import androidx.databinding.ObservableField
import androidx.lifecycle.ViewModel


class QRCodeScanViewModel : ViewModel() {
    val isFlashOn = ObservableField<Boolean>(false)
}
