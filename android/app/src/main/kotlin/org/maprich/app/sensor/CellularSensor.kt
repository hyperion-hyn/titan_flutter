package org.maprich.app.sensor

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.os.Build
import android.telephony.*
import timber.log.Timber

class CellularSensor(val context: Context, val onSensorValueChangeListener: OnSensorValueChangeListener) : Sensor {

    companion object {
        const val SENSOR_TYPE = SensorType.CELLULAR
    }


    lateinit var mTelephonyManager: TelephonyManager;


    override fun init() {

        mTelephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
    }

    override fun startScan() {

        val allCellInfos = mTelephonyManager.allCellInfo;


        Timber.i("allCellInfos count:${allCellInfos.size}")

        for (cellIofo in allCellInfos) {
            val values = mutableMapOf<String, Any>();

            if (cellIofo is CellInfoGsm) {

                val cellIdentityGsm = cellIofo.cellIdentity;
                val cellSignalStrengthGsm = cellIofo.cellSignalStrength;

                val cid = cellIdentityGsm.cid
                val lac = cellIdentityGsm.lac

                val mcc = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    cellIdentityGsm.mccString
                } else {
                    cellIdentityGsm.mcc.toString()
                }

                val mnc = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    cellIdentityGsm.mncString
                } else {
                    cellIdentityGsm.mnc.toString()
                }

                val asu = cellSignalStrengthGsm.asuLevel
                val dbm = cellSignalStrengthGsm.dbm
                val level = cellSignalStrengthGsm.level


                Utils.addIfNonNull(values, "type", "GSM")
                Utils.addIfNonNull(values, "cid", cid)
                Utils.addIfNonNull(values, "lac", lac)
                Utils.addIfNonNull(values, "mcc", mcc)
                Utils.addIfNonNull(values, "mnc", mnc)
                Utils.addIfNonNull(values, "asu", asu)
                Utils.addIfNonNull(values, "dbm", dbm)
                Utils.addIfNonNull(values, "level", level)


                onSensorValueChangeListener.onSensorChange(SENSOR_TYPE, values)


            } else if (cellIofo is CellInfoCdma) {


                val cellIdentityCdma = cellIofo.cellIdentity
                val cellSignalStrengthCdma = cellIofo.cellSignalStrength


                val basestationId = cellIdentityCdma.basestationId;
                val latitude = cellIdentityCdma.latitude
                val longitude = cellIdentityCdma.longitude
                val networkId = cellIdentityCdma.networkId
                val systemId = cellIdentityCdma.systemId


                val asu = cellSignalStrengthCdma.asuLevel

                val cdmaDbm = cellSignalStrengthCdma.cdmaDbm
                val cdmaEcio = cellSignalStrengthCdma.cdmaEcio
                val cdmaLevel = cellSignalStrengthCdma.cdmaLevel

                val dbm = cellSignalStrengthCdma.dbm
                val evdoDbm = cellSignalStrengthCdma.evdoDbm
                val evdoEcio = cellSignalStrengthCdma.evdoEcio
                val evdoLevel = cellSignalStrengthCdma.evdoLevel
                val evdoSnr = cellSignalStrengthCdma.evdoSnr
                val level = cellSignalStrengthCdma.level


                Utils.addIfNonNull(values, "type", "CDMA")
                Utils.addIfNonNull(values, "basestationId", basestationId)
                Utils.addIfNonNull(values, "latitude", latitude)
                Utils.addIfNonNull(values, "longitude", longitude)
                Utils.addIfNonNull(values, "networkId", networkId)
                Utils.addIfNonNull(values, "systemId", systemId)
                Utils.addIfNonNull(values, "asu", asu)
                Utils.addIfNonNull(values, "cdmaDbm", cdmaDbm)
                Utils.addIfNonNull(values, "cdmaEcio", cdmaEcio)
                Utils.addIfNonNull(values, "cdmaLevel", cdmaLevel)
                Utils.addIfNonNull(values, "dbm", dbm)
                Utils.addIfNonNull(values, "evdoDbm", evdoDbm)
                Utils.addIfNonNull(values, "evdoEcio", evdoEcio)
                Utils.addIfNonNull(values, "evdoLevel", evdoLevel)
                Utils.addIfNonNull(values, "evdoSnr", evdoSnr)
                Utils.addIfNonNull(values, "level", level)

                onSensorValueChangeListener.onSensorChange(SENSOR_TYPE, values)


            } else if (cellIofo is CellInfoWcdma) {

                val cellIdentityWcdma = cellIofo.cellIdentity
                val cellSignalStrengthWcdma = cellIofo.cellSignalStrength


                val cid = cellIdentityWcdma.cid
                val lac = cellIdentityWcdma.lac


                val mcc= if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    cellIdentityWcdma.mccString
                } else {
                    cellIdentityWcdma.mcc.toString()
                }


                val mnc = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    cellIdentityWcdma.mncString
                } else {
                    cellIdentityWcdma.mnc.toString()
                }

                val psc = cellIdentityWcdma.psc

                val asu = cellSignalStrengthWcdma.asuLevel
                val dbm = cellSignalStrengthWcdma.dbm
                val level = cellSignalStrengthWcdma.level


                Utils.addIfNonNull(values, "type", "WCDMA")
                Utils.addIfNonNull(values, "cid", cid)
                Utils.addIfNonNull(values, "lac", lac)
                Utils.addIfNonNull(values, "mcc", mcc)
                Utils.addIfNonNull(values, "mnc", mnc)
                Utils.addIfNonNull(values, "psc", psc)
                Utils.addIfNonNull(values, "asu", asu)
                Utils.addIfNonNull(values, "dbm", dbm)
                Utils.addIfNonNull(values, "level", level)


                onSensorValueChangeListener.onSensorChange(SENSOR_TYPE, values)


            } else if (cellIofo is CellInfoLte) {

                val cellIdentityLte = cellIofo.cellIdentity
                val cellSignalStrengthLte = cellIofo.cellSignalStrength


                val ci = cellIdentityLte.ci


                val mcc = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    cellIdentityLte.mccString
                } else {
                    cellIdentityLte.mcc.toString()
                }

                val mnc = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    cellIdentityLte.mncString
                } else {
                    cellIdentityLte.mnc.toString()
                }
                val pci = cellIdentityLte.pci
                val tac = cellIdentityLte.tac
                val asu = cellSignalStrengthLte.asuLevel
                val dbm = cellSignalStrengthLte.dbm
                val level = cellSignalStrengthLte.level
                val timingAdvance = cellSignalStrengthLte.timingAdvance

                Utils.addIfNonNull(values, "type", "LTE")
                Utils.addIfNonNull(values, "ci", ci)
                Utils.addIfNonNull(values, "mcc", mcc)
                Utils.addIfNonNull(values, "mnc", mnc)
                Utils.addIfNonNull(values, "pci", pci)
                Utils.addIfNonNull(values, "tac", tac)
                Utils.addIfNonNull(values, "asu", asu)
                Utils.addIfNonNull(values, "dbm", dbm)
                Utils.addIfNonNull(values, "level", level)
                Utils.addIfNonNull(values, "timingAdvance", timingAdvance)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    val earfcn = cellIdentityLte.earfcn
                    Utils.addIfNonNull(values, "earfcn", earfcn)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val cqi = cellSignalStrengthLte.cqi
                    val rsrp = cellSignalStrengthLte.rsrp
                    val rsrq = cellSignalStrengthLte.rsrq
                    val rssnr = cellSignalStrengthLte.rssnr

                    Utils.addIfNonNull(values, "cqi", cqi)
                    Utils.addIfNonNull(values, "rsrp", rsrp)
                    Utils.addIfNonNull(values, "rsrq", rsrq)
                    Utils.addIfNonNull(values, "rssnr", rssnr)

                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val rssi = cellSignalStrengthLte.rssi
                    Utils.addIfNonNull(values, "rssi", rssi)

                }

                onSensorValueChangeListener.onSensorChange(SENSOR_TYPE, values)

            }



            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {

                if (cellIofo is CellInfoTdscdma) {

                    val cellIdentityTdscdma = cellIofo.cellIdentity
                    val cellSignalStrengthTdscdma = cellIofo.cellSignalStrength

                    val cid = cellIdentityTdscdma.cid
                    val cpid = cellIdentityTdscdma.cpid
                    val lac = cellIdentityTdscdma.lac
                    val mcc = cellIdentityTdscdma.mccString
                    val mnc = cellIdentityTdscdma.mncString
                    val uarfcn = cellIdentityTdscdma.uarfcn

                    val asu = cellSignalStrengthTdscdma.asuLevel
                    val dbm = cellSignalStrengthTdscdma.dbm
                    val level = cellSignalStrengthTdscdma.level
                    val rscp = cellSignalStrengthTdscdma.rscp

                    Utils.addIfNonNull(values, "type", "TDSCDMA")
                    Utils.addIfNonNull(values, "cid", cid)
                    Utils.addIfNonNull(values, "cpid", cpid)
                    Utils.addIfNonNull(values, "lac", lac)
                    Utils.addIfNonNull(values, "mcc", mcc)
                    Utils.addIfNonNull(values, "mnc", mnc)
                    Utils.addIfNonNull(values, "uarfcn", uarfcn)
                    Utils.addIfNonNull(values, "asu", asu)
                    Utils.addIfNonNull(values, "dbm", dbm)
                    Utils.addIfNonNull(values, "level", level)
                    Utils.addIfNonNull(values, "rscp", rscp)

                    onSensorValueChangeListener.onSensorChange(SENSOR_TYPE, values)

                } else if (cellIofo is CellInfoNr) {
                    val cellIdentityNr = cellIofo.cellIdentity as CellIdentityNr
                    val cellSignalStrengthNr = cellIofo.cellSignalStrength as CellSignalStrengthNr


                    val mcc = cellIdentityNr.mccString
                    val mnc = cellIdentityNr.mncString
                    val nci = cellIdentityNr.nci
                    val nrarfcn = cellIdentityNr.nrarfcn
                    val pci = cellIdentityNr.pci
                    val tac = cellIdentityNr.tac


                    val asu = cellSignalStrengthNr.asuLevel
                    val csiRsrp = cellSignalStrengthNr.csiRsrp
                    val csiRsrq = cellSignalStrengthNr.csiRsrq
                    val csiSinr = cellSignalStrengthNr.csiSinr
                    val dbm = cellSignalStrengthNr.dbm
                    val level = cellSignalStrengthNr.level

                    val ssRsrp = cellSignalStrengthNr.ssRsrp
                    val ssRsrq = cellSignalStrengthNr.ssRsrq
                    val ssSinr = cellSignalStrengthNr.ssSinr



                    Utils.addIfNonNull(values, "type", "NR")
                    Utils.addIfNonNull(values, "mcc", mcc ?: "")
                    Utils.addIfNonNull(values, "mnc", mnc ?: "")
                    Utils.addIfNonNull(values, "nci", nci)
                    Utils.addIfNonNull(values, "nrarfcn", nrarfcn)
                    Utils.addIfNonNull(values, "pci", pci)
                    Utils.addIfNonNull(values, "nci", nci)
                    Utils.addIfNonNull(values, "tac", tac)
                    Utils.addIfNonNull(values, "asu", asu)
                    Utils.addIfNonNull(values, "csiRsrp", csiRsrp)
                    Utils.addIfNonNull(values, "csiRsrq", csiRsrq)
                    Utils.addIfNonNull(values, "csiSinr", csiSinr)
                    Utils.addIfNonNull(values, "dbm", dbm)
                    Utils.addIfNonNull(values, "level", level)
                    Utils.addIfNonNull(values, "ssRsrp", ssRsrp)
                    Utils.addIfNonNull(values, "ssRsrq", ssRsrq)
                    Utils.addIfNonNull(values, "ssSinr", ssSinr)

                    onSensorValueChangeListener.onSensorChange(SENSOR_TYPE, values)

                }

            }


        }


    }

    override fun stopScan() {

    }

    override fun destory() {
    }

}