package org.hyn.titan.wallet.bitcoin


class BitcoinTransEntity(var fileName: String,
                         var password: String,
                         var fromAddress: String,
                         var toAddress: String,
                         var fee: Long,
                         var amount: Long,
                         var utxo: List<Utxo>,
                         var change: Change)

class Utxo(var sub: Int,
           var index: Int,
           var txHash: String,
           var address: String,
           var txOutputN: Int,
           var value: Long)

class Change(var address: String,
             var value: Int)