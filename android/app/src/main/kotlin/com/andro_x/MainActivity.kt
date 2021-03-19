package com.andro_x

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.*
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.X509EncodedKeySpec
import java.util.*
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import javax.crypto.SecretKeyFactory

import javax.crypto.spec.PBEKeySpec

import java.security.spec.KeySpec


class MainActivity: FlutterActivity() {
    private val CHANNEL = "crypto"

    private val AES_KEY_SIZE = 256
    private val GCM_IV_LENGTH = 12
    private val GCM_TAG_LENGTH = 16

    private fun encryptMessage(call: MethodCall, result: MethodChannel.Result) {
        val message = call.argument<String>("message")
        val roomSecretKey = call.argument<String>("roomSecretKey")
        if (message != null && roomSecretKey != null) {
            val secretKeySpec = SecretKeySpec(Base64.getDecoder().decode(roomSecretKey), "AES")
            val IV = ByteArray(GCM_IV_LENGTH)
            val random = SecureRandom()
            random.nextBytes(IV)
            val returnable = HashMap<String, String>()
            val encryptedMessage = aesEncrypt(message.encodeToByteArray(), secretKeySpec, IV)
            returnable["IV"] = Base64.getEncoder().encodeToString(IV)
            returnable["encryptedMessage"] = Base64.getEncoder().encodeToString(encryptedMessage)
            result.success(returnable)
        } else {
            result.error("Encrypt Message failed", "'message' or 'roomSecretKey' field is NULL", "?")
        }
    }

    private fun decryptMessage(call: MethodCall, result: MethodChannel.Result) {
        val encryptedMessage = call.argument<String>("encryptedMessage")
        val roomSecretKey = call.argument<String>("roomSecretKey")
        val bytesOfIV = call.argument<String>("IV")
        if (encryptedMessage != null && roomSecretKey != null && bytesOfIV != null) {
            val secretKeySpec = SecretKeySpec(Base64.getDecoder().decode(roomSecretKey), "AES")
            val IV = Base64.getDecoder().decode(bytesOfIV)
            val decryptedMessage = aesDecrypt(Base64.getDecoder().decode(encryptedMessage), secretKeySpec, IV)
            result.success(String(decryptedMessage))
        } else {
            result.error("Decrypt Message failed", "'encryptedMessage' or 'roomSecretKey' of 'bytesOfIV' field is NULL", "?")
        }
    }

    private fun generateKeyPair(call: MethodCall, result: MethodChannel.Result) {
        val keyPairGenerator = KeyPairGenerator.getInstance("RSA")
        keyPairGenerator.initialize(4096)
        // Generate the KeyPair
        val keyPair: KeyPair = keyPairGenerator.generateKeyPair()
        // Get the public and private key
        val publicKey: PublicKey = keyPair.public
        val privateKey: PrivateKey = keyPair.private

        val returnable = HashMap<String, String>()
        returnable["publicKeyRsa"] = String(Base64.getEncoder().encode(publicKey.encoded))
        returnable["privateKeyRsa"] = String(Base64.getEncoder().encode(privateKey.encoded))

        result.success(returnable)
    }

    private fun generateRoomSecret(call: MethodCall, result: MethodChannel.Result) {
        try {
            val keyGenerator = KeyGenerator.getInstance("AES")
            keyGenerator.init(AES_KEY_SIZE)
            val secretKey: SecretKey = keyGenerator.generateKey()
            result.success(String(Base64.getEncoder().encode(secretKey.encoded)))
        } catch (e: Exception) {
            result.error("Generate room secret failed", e.message, e.stackTrace);
        }
    }

    private fun encryptRoomSecret(call: MethodCall, result: MethodChannel.Result) {
        try {
            val roomSecretKey = call.argument<String>("roomSecret")
            val rsaPublicKey = Base64.getDecoder().decode(call.argument<String>("rsaPublicKey"))
            val publicKey: PublicKey = KeyFactory.getInstance("RSA").generatePublic(X509EncodedKeySpec(rsaPublicKey));
            val encryptedRoomSecret = roomSecretKey?.let { rsaEncrypt(it, publicKey) }
            if (encryptedRoomSecret == null) {
                result.error("Encrypt room secret failed", "roomSecret argument is NULL", "?")
            } else {
                result.success(encryptedRoomSecret)
            }
        } catch (e: Exception) {
            result.error("Encrypt room secret failed", e.message, e.stackTrace);
        }
    }

    private fun decryptRoomSecret(call: MethodCall, result: MethodChannel.Result) {
        try {
            val roomSecretKeyEncrypted = call.argument<String>("roomSecretEncrypted")
            val rsaPrivateKey = Base64.getDecoder().decode(call.argument<String>("rsaPrivateKey"))
            val privateKey = KeyFactory.getInstance("RSA").generatePrivate(PKCS8EncodedKeySpec(rsaPrivateKey))
            val encryptedRoomSecret = roomSecretKeyEncrypted?.let { rsaDecrypt(it, privateKey) }
            if (encryptedRoomSecret == null) {
                result.error("Decrypt room secret failed", "roomSecretKeyEncrypted argument is NULL", "?")
            } else {
                result.success(encryptedRoomSecret)
            }
        } catch (e: Exception) {
            result.error("Encrypt room secret failed", e.message, e.stackTrace);
        }
    }

    private fun saveBackupKey(call: MethodCall, result: MethodChannel.Result) {
        try {
            val password = call.argument<String>("password")
            val salt = call.argument<String>("salt")
            val privateRsaKey = call.argument<String>("privateRsaKey")
            if (password !== null && salt !== null && privateRsaKey !== null) {
                val secretKey = getEncryptedPassword(password, salt)
                val secretKeySpec = SecretKeySpec(secretKey, "AES")
                val IV = ByteArray(GCM_IV_LENGTH)
                val random = SecureRandom()
                random.nextBytes(IV)
                println("Started encryption privateKey")
                println(privateRsaKey.length)
                val encryptedBackup = aesEncrypt(privateRsaKey.encodeToByteArray(), secretKeySpec, IV)
                println("Encrypted privateKey successfull")
                val returnable = HashMap<String, String>()
                returnable["encryptedBackup"] = Base64.getEncoder().encodeToString(encryptedBackup);
                returnable["IV"] = Base64.getEncoder().encodeToString(IV);
                result.success(returnable)
            } else {
                result.error("Save backup key failed", "password !== null && salt !== null && privateRsaKey !== null", "?")
            }
        } catch (e: Exception) {
            result.error("Save backup key failed", e.message, e.stackTrace);
        }
    }

    private fun restoreBackupKey(call: MethodCall, result: MethodChannel.Result) {
        try {
            val password = call.argument<String>("password")
            val salt = call.argument<String>("salt")
            val IV = call.argument<String>("IV")
            val cipherText = call.argument<String>("cipherText")
            if (password !== null && salt !== null && IV !== null && cipherText !== null) {
                val secretKey = getEncryptedPassword(password, salt)
                val secretKeySpec = SecretKeySpec(secretKey, "AES")
                val decryptedBackup = aesDecrypt(Base64.getDecoder().decode(cipherText), secretKeySpec, Base64.getDecoder().decode(IV))
                result.success(Base64.getEncoder().encodeToString(decryptedBackup))
            } else {
                result.error("Restore backup key failed", "password !== null && salt !== null && IV !== null && cipherText !== null", "?")
            }
        } catch (e: Exception) {
            result.error("Restore backup key failed", e.message, e.stackTrace)
        }
    }

//    @kotlin.Throws(NoSuchAlgorithmException::class, InvalidKeySpecException::class)
    private fun getEncryptedPassword(
            password: String,
            salt: String
    ): ByteArray {
        val spec: KeySpec = PBEKeySpec(
                password.toCharArray(),
                salt.toByteArray(),
                4096,
                AES_KEY_SIZE * 8
        )
        val f: SecretKeyFactory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
        return f.generateSecret(spec).encoded
    }

//    @Throws(java.lang.Exception::class)
    private fun rsaEncrypt(text: String, publicKey: PublicKey): String {
        //Get Cipher Instance RSA With ECB Mode and OAEPWITHSHA-512ANDMGF1PADDING Padding
        val cipher: Cipher = Cipher.getInstance("RSA/ECB/OAEPWITHSHA-512ANDMGF1PADDING")

        //Initialize Cipher for ENCRYPT_MODE
        cipher.init(Cipher.ENCRYPT_MODE, publicKey)

        //Perform Encryption
        return String(Base64.getEncoder().encode(cipher.doFinal(Base64.getDecoder().decode(text))))
    }

//    @Throws(java.lang.Exception::class)
    private fun rsaDecrypt(cipherTextArray: String, privateKey: PrivateKey): String {
        //Get Cipher Instance RSA With ECB Mode and OAEPWITHSHA-512ANDMGF1PADDING Padding
        val cipher = Cipher.getInstance("RSA/ECB/OAEPWITHSHA-512ANDMGF1PADDING")

        //Initialize Cipher for DECRYPT_MODE
        cipher.init(Cipher.DECRYPT_MODE, privateKey)

        //Perform Decryption
        val decryptedTextArray = cipher.doFinal(Base64.getDecoder().decode(cipherTextArray))
        return String(decryptedTextArray)
    }

//    @Throws(java.lang.Exception::class)
    private fun aesEncrypt(plaintext: ByteArray, key: SecretKeySpec, IV: ByteArray): ByteArray {
        // Get Cipher Instance
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")

        // Create GCMParameterSpec
        val gcmParameterSpec = GCMParameterSpec(GCM_TAG_LENGTH * 8, IV)

        // Initialize Cipher for ENCRYPT_MODE
        cipher.init(Cipher.ENCRYPT_MODE, key, gcmParameterSpec)

        // Perform Encryption
        return cipher.doFinal(plaintext)
    }

//    @Throws(java.lang.Exception::class)
    private fun aesDecrypt(cipherText: ByteArray, key: SecretKeySpec, IV: ByteArray): ByteArray {
        // Get Cipher Instance
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")

        // Create GCMParameterSpec
        val gcmParameterSpec = GCMParameterSpec(GCM_TAG_LENGTH * 8, IV)

        // Initialize Cipher for DECRYPT_MODE
        cipher.init(Cipher.DECRYPT_MODE, key, gcmParameterSpec)

        // Perform Decryption
        return cipher.doFinal(cipherText)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        // Note: this method is invoked on the main thread.
            call, result ->
            when (call.method) {
                "encryptMessage" -> {
                    encryptMessage(call, result)
                }
                "decryptMessage" -> {
                    decryptMessage(call, result)
                }
                "generateKeyPair" -> {
                    generateKeyPair(call, result)
                }
                "generateRoomSecret" -> {
                    generateRoomSecret(call, result)
                }
                "encryptRoomSecret" -> {
                    encryptRoomSecret(call, result)
                }
                "decryptRoomSecret" -> {
                    decryptRoomSecret(call, result)
                }
                "saveBackupKey" -> {
                    saveBackupKey(call, result)
                }
                "restoreBackupKey" -> {
                    restoreBackupKey(call, result)
                }
            }
        }
    }
}
