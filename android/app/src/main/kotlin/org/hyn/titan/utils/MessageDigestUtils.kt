package org.hyn.titan.utils

import java.security.MessageDigest

object MessageDigestUtils {
    /**
     * md5加密字符串
     * md5使用后转成16进制变成32个字节
     */
    fun md5(str: String): String {
        val digest = MessageDigest.getInstance("MD5")
        val result = digest.digest(str.toByteArray())
        //没转16进制之前是16位
        println("result${result.size}")
        //转成16进制后是32字节
        return toHex(result)
    }

    fun toHex(byteArray: ByteArray): String {
        val result = with(StringBuilder()) {
            byteArray.forEach {
                val hex = it.toInt() and (0xFF)
                val hexStr = Integer.toHexString(hex)
                if (hexStr.length == 1) {
                    this.append("0").append(hexStr)
                } else {
                    this.append(hexStr)
                }
            }
            this.toString()
        }
        //转成16进制后是32字节
        return result
    }

    fun sha1(str: String): String {
        val digest = MessageDigest.getInstance("SHA-1")
        val result = digest.digest(str.toByteArray())
        return toHex(result)
    }

    fun sha256(str: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val result = digest.digest(str.toByteArray())
        return toHex(result)
    }
}

//fun main(args: Array<String>) {
//    /**
//     * md5 加密16字节，加密转16进制后32字节
//     * sha1 加密20字节 加密转16进制后40
//     * sha256 加密32字节 加密转16进制后64
//     */
//
//    val str = "我爱编程"
//    val md5 = MessageDigestUtils.md5(str)
//    println(md5)
//    println(md5.toCharArray().size)
//    val sha1 = MessageDigestUtils.sha1(str)
//    println(sha1)
//
//    val sha256 = MessageDigestUtils.sha256(str)
//    println(sha256)
//
//}