package org.hyn.titan.wallet.typemsg;

import android.graphics.Typeface;
import android.text.style.StyleSpan;
import android.util.Base64;

import org.web3j.crypto.Keys;
import org.web3j.crypto.Sign;

import java.math.BigInteger;
import java.security.SignatureException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;

import wallet.core.jni.Hash;

public class CryptoFunctions implements CryptoFunctionsInterface {
    @Override
    public byte[] Base64Decode(String message) {
        return Base64.decode(message, Base64.URL_SAFE);
    }

    @Override
    public byte[] Base64Encode(byte[] data) {
        return Base64.encode(data, Base64.URL_SAFE | Base64.NO_WRAP);
    }

    @Override
    public BigInteger signedMessageToKey(byte[] data, byte[] signature) throws SignatureException {
        Sign.SignatureData sigData = sigFromByteArray(signature);
        if (sigData == null) return BigInteger.ZERO;
        return Sign.signedMessageToKey(data, sigData);
    }

    @Override
    public String getAddressFromKey(BigInteger recoveredKey) {
        return Keys.getAddress(recoveredKey);
    }

    @Override
    public byte[] keccak256(byte[] message) {
        return Hash.keccak256(message);
    }

    @Override
    public CharSequence formatTypedMessage(ProviderTypedData[] rawData) {
        return formatTypedMessageFunc(rawData);
    }

    @Override
    public CharSequence formatEIP712Message(String messageData) {
        CharSequence msgData = "";
        try {
            StructuredDataEncoder eip712Object = new StructuredDataEncoder(messageData);
            msgData = formatEIP712Message(eip712Object);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return msgData;
    }

    @Override
    public byte[] getStructuredData(String messageData) {
        try {
            StructuredDataEncoder eip721Object = new StructuredDataEncoder(messageData);
            return eip721Object.getStructuredData();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new byte[0];
    }

    public static Sign.SignatureData sigFromByteArray(byte[] sig) {
        if (sig.length < 64 || sig.length > 65) return null;

        byte subv = sig[64];
        if (subv < 27) subv += 27;

        byte[] subrRev = Arrays.copyOfRange(sig, 0, 32);
        byte[] subsRev = Arrays.copyOfRange(sig, 32, 64);

        BigInteger r = new BigInteger(1, subrRev);
        BigInteger s = new BigInteger(1, subsRev);

        return new Sign.SignatureData(subv, subrRev, subsRev);
    }

    public CharSequence formatTypedMessageFunc(ProviderTypedData[] rawData) {
        //produce readable text to display in the signing prompt
        StyledStringBuilder sb = new StyledStringBuilder();
        boolean firstVal = true;
        for (ProviderTypedData data : rawData) {
            if (!firstVal) sb.append("\n");
            sb.startStyleGroup().append(data.name).append(":");
            sb.setStyle(new StyleSpan(Typeface.BOLD));
            sb.append("\n  ").append(data.value.toString());
            firstVal = false;
        }

        sb.applyStyles();

        return sb;
    }

    public CharSequence formatEIP712Message(StructuredDataEncoder messageData) {
        HashMap<String, Object> messageMap = (HashMap<String, Object>) messageData.jsonMessageObject.getMessage();
        StyledStringBuilder sb = new StyledStringBuilder();
        for (String entry : messageMap.keySet()) {
            sb.startStyleGroup().append(entry).append(":").append("\n");
            sb.setStyle(new StyleSpan(Typeface.BOLD));
            Object v = messageMap.get(entry);
            if (v instanceof LinkedHashMap) {
                HashMap<String, Object> valueMap = (HashMap<String, Object>) messageMap.get(entry);
                for (String paramName : valueMap.keySet()) {
                    String value = valueMap.get(paramName).toString();
                    sb.startStyleGroup().append(" ").append(paramName).append(": ");
                    sb.setStyle(new StyleSpan(Typeface.BOLD));
                    sb.append(value).append("\n");
                }
            } else {
                sb.append(" ").append(v.toString()).append("\n");
            }
        }

        sb.applyStyles();

        return sb;
    }
}

