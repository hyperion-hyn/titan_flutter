package org.maprich.app.wallet;

import com.google.gson.Gson;

import org.web3j.abi.FunctionEncoder;
import org.web3j.abi.FunctionReturnDecoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.Address;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.Type;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.crypto.Credentials;
import org.web3j.crypto.ECKeyPair;
import org.web3j.crypto.RawTransaction;
import org.web3j.crypto.TransactionEncoder;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.request.Transaction;
import org.web3j.protocol.core.methods.response.EthCall;
import org.web3j.protocol.core.methods.response.EthEstimateGas;
import org.web3j.protocol.core.methods.response.EthGasPrice;
import org.web3j.protocol.core.methods.response.EthGetBalance;
import org.web3j.protocol.core.methods.response.EthGetTransactionCount;
import org.web3j.protocol.core.methods.response.EthSendTransaction;
import org.web3j.utils.Numeric;

import java.io.IOException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

import timber.log.Timber;

public class EthHelper {
    /**
     * get the next available nonce
     *
     * @param web3j
     * @param address
     * @return
     * @throws IOException
     */
    public static BigInteger getNonce(Web3j web3j, String address) throws IOException {
        EthGetTransactionCount nonce = web3j.ethGetTransactionCount(address, DefaultBlockParameterName.LATEST).send();
        if (nonce == null) {
            throw new RuntimeException("net error");
        }
        return nonce.getTransactionCount();
    }


    /**
     * Estimated fee limit
     *
     * @param web3j
     * @param transaction
     * @return
     * @throws IOException
     */
    public static BigInteger getTransactionGasAmountUsed(Web3j web3j, Transaction transaction) throws IOException {
        EthEstimateGas ethEstimateGas = web3j.ethEstimateGas(transaction).send();
        if (ethEstimateGas.hasError()) {
            throw new RuntimeException(ethEstimateGas.getError().getMessage());
        }
        return ethEstimateGas.getAmountUsed();
    }

    /**
     * get eth balance
     *
     * @param web3j
     * @param address
     * @return
     * @throws IOException
     */
    public static BigInteger getBalance(Web3j web3j, String address) throws IOException {
        EthGetBalance ethGetBalance = web3j.ethGetBalance(address, DefaultBlockParameterName.LATEST).send();
        return ethGetBalance.getBalance();
//        return Convert.fromWei(new BigDecimal(ethGetBalance.getBalance()), Convert.Unit.ETHER);
    }


    /**
     * get erc20 token balance
     *
     * @param web3j
     * @param fromAddress
     * @param contractAddress
     * @return
     * @throws IOException
     */
    public static BigInteger getTokenBalance(Web3j web3j, String fromAddress, String contractAddress) throws IOException {
        String methodName = "balanceOf";
        List<Type> inputParameters = new ArrayList<>();
        List<TypeReference<?>> outputParameters = new ArrayList<>();
        Address address = new Address(fromAddress);
        inputParameters.add(address);

        TypeReference<Uint256> typeReference = new TypeReference<Uint256>() {
        };
        outputParameters.add(typeReference);
        Function function = new Function(methodName, inputParameters, outputParameters);
        String data = FunctionEncoder.encode(function);
        Transaction transaction = Transaction.createEthCallTransaction(fromAddress, contractAddress, data);

        EthCall ethCall;
        BigInteger balanceValue;
        ethCall = web3j.ethCall(transaction, DefaultBlockParameterName.LATEST).send();
        List<Type> results = FunctionReturnDecoder.decode(ethCall.getValue(), function.getOutputParameters());
        balanceValue = (BigInteger) results.get(0).getValue();

        return balanceValue;
    }

    public static BigInteger getLastGasPrice(Web3j web3j) throws IOException {
        EthGasPrice ethGasPrice = web3j.ethGasPrice().send();
        return ethGasPrice.getGasPrice();
    }

    public static String transferETH(Web3j web3j, String fromAddr, String privateKey, String toAddr, BigInteger amount, String data) throws IOException {
        // get nonce
        BigInteger nonce = getNonce(web3j, fromAddr);
        // value convert
//        BigInteger value = Convert.toWei(amount, Convert.Unit.ETHER).toBigInteger();

        BigInteger gasPrice = getLastGasPrice(web3j);

        // make transaction
        Transaction transaction = Transaction.createEtherTransaction(fromAddr, nonce, gasPrice, null, toAddr, amount);
        // calculate gasLimit
        BigInteger gasAmountUsed = getTransactionGasAmountUsed(web3j, transaction);

        // check balance
        BigInteger ethBalance = getBalance(web3j, fromAddr);
//        BigDecimal balance = Convert.toWei(ethBalance, Convert.Unit.ETHER);
        // balance < amount + gasLimit ??
//        BigDecimal amountWeiDecimal = new BigDecimal(amount.toString());
        BigInteger gasUsed = gasAmountUsed.multiply(gasPrice);
//        Timber.i("ethBalance " + ethBalance.toString(10) + " amount: " + amount + " gasLimit:" + gasLimit + " gasUsed:" + gasUsed + " fromAddr:" + fromAddr);
        if (ethBalance.compareTo(amount.add(gasUsed)) < 0) {
            throw new RuntimeException("Insufficient balance.");
        }

//        Timber.i("1111 nonce:" + nonce + " gasPrice:" + gasPrice + " gasLimit:" + gasLimit + " privateKey:" + privateKey);

        return signAndSend(web3j, nonce, gasPrice, gasAmountUsed, toAddr, amount, data, privateKey);
    }

    public static String signAndSend(Web3j web3j, BigInteger nonce, BigInteger gasPrice, BigInteger gasLimit, String to, BigInteger value, String data, String privateKey) throws IOException {
        String txHash = "";
        RawTransaction rawTransaction = RawTransaction.createTransaction(nonce, gasPrice, gasLimit, to, value, data == null ? "" : data);
        if (privateKey.startsWith("0x")) {
            privateKey = privateKey.substring(2);
        }

        ECKeyPair ecKeyPair = ECKeyPair.create(new BigInteger(privateKey, 16));
        Credentials credentials = Credentials.create(ecKeyPair);

        byte[] signMessage;
        signMessage = TransactionEncoder.signMessage(rawTransaction, credentials);

        String signData = Numeric.toHexString(signMessage);
        EthSendTransaction send = web3j.ethSendRawTransaction(signData).send();
        txHash = send.getTransactionHash();
        Timber.i(new Gson().toJson(send));
        return txHash;
    }

    /**
     * transfer erc20 token
     *
     * @param web3j
     * @param fromAddr
     * @param privateKey
     * @param toAddr
     * @param contractAddr
     * @param amount
     * @return
     */
    public static String transferToken(Web3j web3j, String privateKey, String fromAddr, String toAddr, String contractAddr, BigInteger amount) throws IOException {
        BigInteger nonce = getNonce(web3j, fromAddr);
        // method name
        String method = "transfer";

        BigInteger gasPrice = getLastGasPrice(web3j);

        // call parameters
        List<Type> inputArgs = new ArrayList<>();
        inputArgs.add(new Address(toAddr));
        inputArgs.add(new Uint256(amount));
        // return type
        List<TypeReference<?>> outputArgs = new ArrayList<>();

        String funcABI = FunctionEncoder.encode(new Function(method, inputArgs, outputArgs));

        Transaction transaction = Transaction.createFunctionCallTransaction(fromAddr, nonce, gasPrice, null, contractAddr, funcABI);
//        RawTransaction rawTransaction = RawTransaction.createTransaction(nonce, gasPrice, null, contractAddr, null, funcABI);

        BigInteger gasLimit = getTransactionGasAmountUsed(web3j, transaction);

        // get balance
        BigInteger ethBalance = getBalance(web3j, fromAddr);
        BigInteger tokenBalance = getTokenBalance(web3j, fromAddr, contractAddr);
//        BigInteger balance = Convert.toWei(ethBalance, Convert.Unit.ETHER).toBigInteger();

        BigInteger gasUsed = gasLimit.multiply(gasPrice);

        if (ethBalance.compareTo(gasUsed) < 0) {
            throw new RuntimeException("Insufficient gas fee, please verify");
        }
        if (tokenBalance.compareTo(amount) < 0) {
            throw new RuntimeException("Insufficient tokens, please verify");
        }

        return signAndSend(web3j, nonce, gasPrice, gasLimit, contractAddr, BigInteger.ZERO, funcABI, privateKey);
    }

    public static BigInteger tokenTransferEstimateGas(Web3j web3j, String fromAddr, String toAddr, String contractAddr, BigInteger amount) throws IOException {
        // method name
        String method = "transfer";

        BigInteger nonce = getNonce(web3j, fromAddr);
        BigInteger gasPrice = getLastGasPrice(web3j);

        // call parameters
        List<Type> inputArgs = new ArrayList<>();
        inputArgs.add(new Address(toAddr));
        inputArgs.add(new Uint256(amount));
        // return type
        List<TypeReference<?>> outputArgs = new ArrayList<>();

        String funcABI = FunctionEncoder.encode(new Function(method, inputArgs, outputArgs));

        Transaction transaction = Transaction.createFunctionCallTransaction(fromAddr, nonce, gasPrice, null, contractAddr, funcABI);
        BigInteger gasUsed = getTransactionGasAmountUsed(web3j, transaction);
        Timber.i("token nonce " + nonce + ", gasPrice " + gasPrice + ", gasUsed " + gasUsed);
        return gasUsed.multiply(gasPrice);
    }

    public static BigInteger ethTransferEstimateGas(Web3j web3j, String fromAddr, String toAddr, BigInteger amount) throws IOException {
        BigInteger nonce = getNonce(web3j, fromAddr);
        // value convert
//        BigInteger value = Convert.toWei(amount, Convert.Unit.ETHER).toBigInteger();

        BigInteger gasPrice = getLastGasPrice(web3j);

        // make transaction
        Transaction transaction = Transaction.createEtherTransaction(fromAddr, nonce, gasPrice, null, toAddr, amount);
        // calculate gasLimit
        BigInteger amountUsed = getTransactionGasAmountUsed(web3j, transaction);
        Timber.i("eth nonce " + nonce + ", gasPrice " + gasPrice + ", gasUsed " + amountUsed);
        return amountUsed.multiply(gasPrice);
    }

}
