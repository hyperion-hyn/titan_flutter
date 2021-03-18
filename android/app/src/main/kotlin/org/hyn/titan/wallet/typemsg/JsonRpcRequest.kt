package org.hyn.titan.wallet.typemsg

data class JsonRpcRequest<T>(
    val id: Long,
    val jsonrpc: String = "2.0",
    val method: String?,
    val params: T
)