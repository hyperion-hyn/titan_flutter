package org.hyn.titan.sensor

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.os.Build
import android.telephony.*

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

        for (cellIofo in allCellInfos) {
            val values = mutableMapOf<String, Any>();

            if (cellIofo is CellInfoGsm) {

                val cellIdentityGsm = cellIofo.cellIdentity;
                val cellSignalStrengthGsm = cellIofo.cellSignalStrength;

                val cid = cellIdentityGsm.cid
                val lac = cellIdentityGsm.lac

                var mcc: String

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    mcc = cellIdentityGsm.mccString
                } else {
                    mcc = cellIdentityGsm.mcc.toString()
                }

                var mnc: String
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    mnc = cellIdentityGsm.mncString
                } else {
                    mnc = cellIdentityGsm.mnc.toString()
                }

                val asu = cellSignalStrengthGsm.asuLevel
                val dbm = cellSignalStrengthGsm.dbm
                val level = cellSignalStrengthGsm.level


                values.put("type", "GSM")
                values.put("cid", cid)
                values.put("lac", lac)
                values.put("mcc", mcc)
                values.put("mnc", mnc)
                values.put("asu", asu)
                values.put("dbm", dbm)
                values.put("level", level)


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


                values.put("type", "CDMA")
                values.put("basestationId", basestationId)
                values.put("latitude", latitude)
                values.put("longitude", longitude)
                values.put("networkId", networkId)
                values.put("systemId", systemId)
                values.put("asu", asu)
                values.put("cdmaDbm", cdmaDbm)
                values.put("cdmaEcio", cdmaEcio)
                values.put("cdmaLevel", cdmaLevel)
                values.put("dbm", dbm)
                values.put("evdoDbm", evdoDbm)
                values.put("evdoEcio", evdoEcio)
                values.put("evdoLevel", evdoLevel)
                values.put("evdoSnr", evdoSnr)
                values.put("level", level)

                onSensorValueChangeListener.onSensorChange(SENSOR_TYPE, values)


            } else if (cellIofo is CellInfoWcdma) {

                val cellIdentityWcdma = cellIofo.cellIdentity
                val cellSignalStrengthWcdma = cellIofo.cellSignalStrength


                val cid = cellIdentityWcdma.cid
                val lac = cellIdentityWcdma.lac

                var mcc: String

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    mcc = cellIdentityWcdma.mccString
                } else {
                    mcc = cellIdentityWcdma.mcc.toString()
                }

                var mnc: String
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    mnc = cellIdentityWcdma.mncString
                } else {
                    mnc = cellIdentityWcdma.mnc.toString()
                }

                val psc = cellIdentityWcdma.psc

                val asu = cellSignalStrengthWcdma.asuLevel
                val dbm = cellSignalStrengthWcdma.dbm
                val level = cellSignalStrengthWcdma.level


                values.put("type", "WCDMA")
                values.put("cid", cid)
                values.put("lac", lac)
                values.put("mcc", mcc)
                values.put("mnc", mnc)
                values.put("psc", psc)
                values.put("asu", asu)
                values.put("dbm", dbm)
                values.put("level", level)


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

                values.put("type", "LTE")
                values.put("ci", ci)
                values.put("mcc", mcc)
                values.put("mnc", mnc)
                values.put("pci", pci)
                values.put("tac", tac)
                values.put("asu", asu)
                values.put("dbm", dbm)
                values.put("level", level)
                values.put("timingAdvance", timingAdvance)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    val earfcn = cellIdentityLte.earfcn
                    values.put("earfcn", earfcn)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val cqi = cellSignalStrengthLte.cqi
                    val rsrp = cellSignalStrengthLte.rsrp
                    val rsrq = cellSignalStrengthLte.rsrq
                    val rssnr = cellSignalStrengthLte.rssnr

                    values.put("cqi", cqi)
                    values.put("rsrp", rsrp)
                    values.put("rsrq", rsrq)
                    values.put("rssnr", rssnr)

                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val rssi = cellSignalStrengthLte.rssi
                    values.put("rssi", rssi)

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

                    values.put("type", "TDSCDMA")
                    values.put("cid", cid)
                    values.put("cpid", cpid)
                    values.put("lac", lac)
                    values.put("mcc", mcc)
                    values.put("mnc", mnc)
                    values.put("uarfcn", uarfcn)
                    values.put("asu", asu)
                    values.put("dbm", dbm)
                    values.put("level", level)
                    values.put("rscp", rscp)

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



                    values.put("type", "NR")
                    values.put("mcc", mcc ?: "")
                    values.put("mnc", mnc ?: "")
                    values.put("nci", nci)
                    values.put("nrarfcn", nrarfcn)
                    values.put("pci", pci)
                    values.put("nci", nci)
                    values.put("tac", tac)
                    values.put("asu", asu)
                    values.put("csiRsrp", csiRsrp)
                    values.put("csiRsrq", csiRsrq)
                    values.put("csiSinr", csiSinr)
                    values.put("dbm", dbm)
                    values.put("level", level)
                    values.put("ssRsrp", ssRsrp)
                    values.put("ssRsrq", ssRsrq)
                    values.put("ssSinr", ssSinr)

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