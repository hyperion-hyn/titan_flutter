package org.hyn.titan.encryption.rsa;

import android.content.Context;
import android.os.Build;
import android.security.KeyPairGeneratorSpec;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Log;

import org.hyn.titan.encryption.exception.CertException;
import org.hyn.titan.encryption.exception.NoKeyException;

import java.io.IOException;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.SecureRandom;
import java.security.SignatureException;
import java.security.UnrecoverableEntryException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.AlgorithmParameterSpec;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.security.auth.x500.X500Principal;

public class RsaEncryption {
    private static final String TAG = RsaEncryption.class.getSimpleName();

    private static final String ALGORITHM = "RSA/ECB/PKCS1Padding";

    private int mKeySize = 4096;
    private String mAlias = "Titan";

    public RsaEncryption() {
    }

    public RsaEncryption(int keysize) {
        this.mKeySize = keysize;
    }

    /**
     * 加密字符串
     *
     * @param data 明文
     * @return 密文
     * @throws Exception
     */
    public String encrypt(String data) throws Exception {
        KeyStore.PrivateKeyEntry entry = getKeyEntry();
        RSAPublicKey publicKey = (RSAPublicKey) entry.getCertificate().getPublicKey();
        Cipher cipher = Cipher.getInstance(ALGORITHM);
        cipher.init(Cipher.ENCRYPT_MODE, publicKey);
        // 模长
        int key_len = publicKey.getModulus().bitLength() / 8;
        // 加密数据长度 <= 模长-11
        String iosDatas = new String(data.getBytes(), StandardCharsets.ISO_8859_1);
        String[] datas = splitString(iosDatas, key_len - 11);
        StringBuilder mi = new StringBuilder();
        //如果明文长度大于模长-11则要分组加密
        for (String s : datas) {
            String t = bcd2Str(cipher.doFinal(s.getBytes(StandardCharsets.ISO_8859_1)));
            System.out.println(t);
            System.out.println(t.length());
            mi.append(t);
        }
        return mi.toString();
    }

    /**
     * 解密
     *
     * @param data 密文
     * @return 明文
     * @throws Exception
     */
    public String decrypt(String data) throws Exception {
        KeyStore.PrivateKeyEntry entry = getKeyEntry();
        PrivateKey privateKey = entry.getPrivateKey();
        Cipher cipher = Cipher.getInstance(ALGORITHM);
        cipher.init(Cipher.DECRYPT_MODE, privateKey);
        //模长
//        int key_len = privateKey.getModulus().bitLength() / 8;
        int key_len = mKeySize / 8;
        byte[] bytes = data.getBytes(StandardCharsets.ISO_8859_1);
        byte[] bcd = ASCII_To_BCD(bytes, bytes.length);
        //如果密文长度大于模长则要分组解密
        StringBuilder ming = new StringBuilder();
        byte[][] arrays = splitArray(bcd, key_len);
        for (byte[] arr : arrays) {
            ming.append(new String(cipher.doFinal(arr), StandardCharsets.ISO_8859_1));
        }
        return new String(ming.toString().getBytes(StandardCharsets.ISO_8859_1));
    }

    public byte[] encrypt(byte[] data) throws CertificateException,
            NoSuchAlgorithmException,
            IOException,
            KeyStoreException,
            UnrecoverableEntryException,
            NoSuchPaddingException,
            InvalidKeyException,
            BadPaddingException,
            IllegalBlockSizeException, NoKeyException, CertException, NoSuchProviderException, SignatureException {
        KeyStore.PrivateKeyEntry entry = getKeyEntry();
        Cipher cipher = Cipher.getInstance(ALGORITHM);
        if (entry != null) {
            cipher.init(Cipher.ENCRYPT_MODE, entry.getCertificate().getPublicKey());
            return cipher.doFinal(data);
        } else {
            throw new NoKeyException("No PublicKey Exception");
        }
    }

    public byte[] decrypt(byte[] encryptedData) throws CertificateException,
            UnrecoverableEntryException,
            NoSuchAlgorithmException,
            KeyStoreException,
            IOException,
            NoSuchPaddingException,
            InvalidKeyException,
            BadPaddingException,
            IllegalBlockSizeException,
            NoKeyException, NoSuchProviderException, SignatureException, CertException {
        KeyStore.PrivateKeyEntry entry = getKeyEntry();

        Cipher cipher = Cipher.getInstance(ALGORITHM);
        if (entry != null) {
            cipher.init(Cipher.DECRYPT_MODE, entry.getPrivateKey());

            return cipher.doFinal(encryptedData);
        } else {
            throw new NoKeyException("No PublicKey Exception");
        }
    }

    public KeyStore.PrivateKeyEntry getKeyEntry() throws KeyStoreException,
            CertificateException, NoSuchAlgorithmException, IOException, UnrecoverableEntryException, InvalidKeyException, NoSuchProviderException, SignatureException, CertException {
        KeyStore ks = KeyStore.getInstance("AndroidKeyStore");

        // Weird artifact of Java API.  If you don't have an InputStream to load, you still need
        // to call "load", or it'll crash.
        ks.load(null);

        // Load the key pair from the Android Key Store
        KeyStore.Entry entry = ks.getEntry(mAlias, null);

        /* If the entry is null, keys were never stored under this alias.
         * Debug steps in this situation would be:
         * -Check the list of aliases by iterating over Keystore.aliases(), be sure the alias
         *   exists.
         * -If that's empty, verify they were both stored and pulled from the same keystore
         *   "AndroidKeyStore"
         */
        if (entry == null) {
            Log.w(TAG, "No key found under alias: " + mAlias);
            return null;
        }

        /* If entry is not a KeyStore.PrivateKeyEntry, it might have gotten stored in a previous
         * iteration of your application that was using some other mechanism, or been overwritten
         * by something else using the same keystore with the same alias.
         * You can determine the type using entry.getClass() and debug from there.
         */
        if (!(entry instanceof KeyStore.PrivateKeyEntry)) {
            Log.w(TAG, "Not an instance of a PrivateKeyEntry");
            Log.w(TAG, "Exiting signData()...");
            return null;
        }

        X509Certificate cert = (X509Certificate) ((KeyStore.PrivateKeyEntry) entry).getCertificate();
        Date expireDate = cert.getNotAfter();
        if (System.currentTimeMillis() > expireDate.getTime()) {
            throw new CertException("certificate is expired");
        }

        return (KeyStore.PrivateKeyEntry) entry;
    }


    /**
     * Creates a public and private key and stores it using the Android Key Store, so that only
     * this application will be able to access the keys.
     *
     * @param context
     * @param expireAt expire at time
     * @throws NoSuchProviderException
     * @throws NoSuchAlgorithmException
     * @throws InvalidAlgorithmParameterException
     */
    public KeyPair createKeys(Context context, long expireAt) throws NoSuchProviderException,
            NoSuchAlgorithmException, InvalidAlgorithmParameterException {

        // BEGIN_INCLUDE(create_valid_dates)
        // Create a start and end time, for the validity range of the key pair that's about to be
        // generated.
        Calendar start = new GregorianCalendar();
        Calendar end = new GregorianCalendar();
        end.setTimeInMillis(expireAt);
        //END_INCLUDE(create_valid_dates)

        // BEGIN_INCLUDE(create_keypair)
        // Initialize a KeyPair generator using the the intended algorithm (in this example, RSA
        // and the KeyStore.  This example uses the AndroidKeyStore.
        KeyPairGenerator kpGenerator = KeyPairGenerator
                .getInstance("RSA", "AndroidKeyStore");
        // END_INCLUDE(create_keypair)

        // BEGIN_INCLUDE(create_spec)
        // The KeyPairGeneratorSpec object is how parameters for your key pair are passed
        // to the KeyPairGenerator.
        AlgorithmParameterSpec spec;

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            // Below Android M, use the KeyPairGeneratorSpec.Builder.

            spec = new KeyPairGeneratorSpec.Builder(context)
                    // You'll use the alias later to retrieve the key.  It's a key for the key!
                    .setAlias(mAlias)
                    .setKeySize(mKeySize)
                    // The subject used for the self-signed certificate of the generated pair
                    .setSubject(new X500Principal("CN=" + mAlias + " OU=" + context.getPackageName()))
                    // The serial number used for the self-signed certificate of the
                    // generated pair.
                    .setSerialNumber(BigInteger.valueOf(1337))
                    // Date range of validity for the generated pair.
                    .setStartDate(start.getTime())
                    .setEndDate(end.getTime())
                    .build();


        } else {
            // On Android M or above, use the KeyGenparameterSpec.Builder and specify permitted
            // properties  and restrictions of the key.
            spec = new KeyGenParameterSpec.Builder(mAlias, KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
                    .setCertificateSubject(new X500Principal("CN=" + mAlias + " OU=" + context.getPackageName()))
//                    .setDigests(KeyProperties.DIGEST_SHA256)
//                    .setSignaturePaddings(KeyProperties.SIGNATURE_PADDING_RSA_PKCS1)
                    .setKeySize(mKeySize)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_RSA_PKCS1)
                    .setRandomizedEncryptionRequired(false)
                    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                    .setCertificateSerialNumber(BigInteger.valueOf(1337))
                    .setCertificateNotBefore(start.getTime())
                    .setCertificateNotAfter(end.getTime())
                    .build();
        }

        kpGenerator.initialize(spec, new SecureRandom());

        KeyPair kp = kpGenerator.generateKeyPair();
        // END_INCLUDE(create_spec)
        Log.d(TAG, "Public Key is: " + kp.getPublic().toString());

        return kp;
    }

    /**
     * 拆分字符串
     */
    private String[] splitString(String string, int len) {
        int x = string.length() / len;
        int y = string.length() % len;
        int z = 0;
        if (y != 0) {
            z = 1;
        }
        String[] strings = new String[x + z];
        String str = "";
        for (int i = 0; i < x + z; i++) {
            if (i == x + z - 1 && y != 0) {
                str = string.substring(i * len, i * len + y);
            } else {
                str = string.substring(i * len, i * len + len);
            }
            strings[i] = str;
        }
        return strings;
    }

    /**
     * 拆分数组
     */
    private byte[][] splitArray(byte[] data, int len) {
        int x = data.length / len;
        int y = data.length % len;
        int z = 0;
        if (y != 0) {
            z = 1;
        }
        byte[][] arrays = new byte[x + z][];
        byte[] arr;
        for (int i = 0; i < x + z; i++) {
            arr = new byte[len];
            if (i == x + z - 1 && y != 0) {
                System.arraycopy(data, i * len, arr, 0, y);
            } else {
                System.arraycopy(data, i * len, arr, 0, len);
            }
            arrays[i] = arr;
        }
        return arrays;
    }

    /**
     * BCD转字符串
     */
    private String bcd2Str(byte[] bytes) {
        char[] temp = new char[bytes.length * 2];
        char val;

        for (int i = 0; i < bytes.length; i++) {
            val = (char) (((bytes[i] & 0xf0) >> 4) & 0x0f);
            temp[i * 2] = (char) (val > 9 ? val + 'A' - 10 : val + '0');

            val = (char) (bytes[i] & 0x0f);
            temp[i * 2 + 1] = (char) (val > 9 ? val + 'A' - 10 : val + '0');
        }
        return new String(temp);
    }

    /**
     * ASCII码转BCD码
     */
    private byte[] ASCII_To_BCD(byte[] ascii, int asc_len) {
        byte[] bcd = new byte[asc_len / 2];
        int j = 0;
        for (int i = 0; i < (asc_len + 1) / 2; i++) {
            bcd[i] = asc_to_bcd(ascii[j++]);
            bcd[i] = (byte) (((j >= asc_len) ? 0x00 : asc_to_bcd(ascii[j++])) + (bcd[i] << 4));
        }
        return bcd;
    }

    private byte asc_to_bcd(byte asc) {
        byte bcd;

        if ((asc >= '0') && (asc <= '9'))
            bcd = (byte) (asc - '0');
        else if ((asc >= 'A') && (asc <= 'F'))
            bcd = (byte) (asc - 'A' + 10);
        else if ((asc >= 'a') && (asc <= 'f'))
            bcd = (byte) (asc - 'a' + 10);
        else
            bcd = (byte) (asc - 48);
        return bcd;
    }

    public void setKeySize(int keySize) {
        this.mKeySize = keySize;
    }

    public void setAlias(String alias) {
        mAlias = alias;
    }
}
