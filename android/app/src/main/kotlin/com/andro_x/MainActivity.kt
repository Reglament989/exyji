package com.andro_x

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.security.*
import java.security.spec.KeySpec
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.X509EncodedKeySpec
import java.util.*
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec


class MainActivity : FlutterActivity() {
    private val CHANNEL = "crypto"

    private val AES_KEY_SIZE = 256
    private val GCM_IV_LENGTH = 12
    private val GCM_TAG_LENGTH = 16

    private fun encryptMessage(message: String, roomSecretKey: String): HashMap<String, String> {
        val secretKeySpec = SecretKeySpec(Base64.getDecoder().decode(roomSecretKey), "AES")
        val IV = ByteArray(GCM_IV_LENGTH)
        val random = SecureRandom()
        random.nextBytes(IV)
        val returnable = HashMap<String, String>()
        val encryptedMessage = aesEncrypt(message.encodeToByteArray(), secretKeySpec, IV)
        returnable["IV"] = Base64.getEncoder().encodeToString(IV)
        returnable["encryptedMessage"] = Base64.getEncoder().encodeToString(encryptedMessage)
        return returnable
    }

    private fun decryptMessage(encryptedMessage: String, roomSecretKey: String, bytesOfIV: String): String {
        val secretKeySpec = SecretKeySpec(Base64.getDecoder().decode(roomSecretKey), "AES")
        val IV = Base64.getDecoder().decode(bytesOfIV)
        val decryptedMessage = aesDecrypt(Base64.getDecoder().decode(encryptedMessage), secretKeySpec, IV)
        return String(decryptedMessage);
    }

    private fun generateKeyPair(): HashMap<String, String> {
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

        return returnable
    }

    private fun generateRoomSecret(): String {
        val keyGenerator = KeyGenerator.getInstance("AES")
        keyGenerator.init(AES_KEY_SIZE)
        val secretKey: SecretKey = keyGenerator.generateKey()
        return String(Base64.getEncoder().encode(secretKey.encoded))
    }

    private fun encryptRoomSecret(roomSecretKey: ByteArray, rsaPublicKey: ByteArray): String {
        try {
            val publicKey: PublicKey = KeyFactory.getInstance("RSA").generatePublic(X509EncodedKeySpec(rsaPublicKey))
            return rsaEncrypt(roomSecretKey, publicKey)
        } catch (e: Exception) {
            throw e
        }
    }

    private fun decryptRoomSecret(roomSecretKeyEncrypted: String, rsaPrivateKey: ByteArray): String {
        try {
            val privateKey = KeyFactory.getInstance("RSA").generatePrivate(PKCS8EncodedKeySpec(rsaPrivateKey))
            return rsaDecrypt(roomSecretKeyEncrypted, privateKey)
        } catch (e: Exception) {
            throw e
        }
    }

    private fun saveBackupKey(password: String, salt: String, privateRsaKey: String): HashMap<String, String> {
        try {
            val secretKey = getEncryptedPassword(password, salt)
            val secretKeySpec = SecretKeySpec(secretKey, "AES")
            val encryptedBackup = encryptBackup(secretKeySpec, privateRsaKey)
            val returnable = HashMap<String, String>()
            returnable["encryptedBackup"] = Base64.getEncoder().encodeToString(encryptedBackup[1])
            returnable["IV"] = Base64.getEncoder().encodeToString(encryptedBackup[0])
            return returnable
        } catch (e: Exception) {
            throw  e
        }
    }

    private fun restoreBackupKey(password: String, salt: String, IV: String, cipherText: String): String {
        try {
            val secretKey = getEncryptedPassword(password, salt)
            val secretKeySpec = SecretKeySpec(secretKey, "AES")
            return decryptBackup(secretKeySpec, Base64.getDecoder().decode(cipherText), IvParameterSpec(Base64.getDecoder().decode(IV)))
        } catch (e: Exception) {
            throw e
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
                65536,
                256
        )
        val f: SecretKeyFactory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
        return f.generateSecret(spec).encoded
    }

    private fun encryptBackup(key: SecretKeySpec, cipherTextArray: String): Array<ByteArray> {
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, key)
        val params: AlgorithmParameters = cipher.parameters
        val iv = params.getParameterSpec(IvParameterSpec::class.java).iv
        val ciphertext = cipher.doFinal(cipherTextArray.toByteArray())
        return arrayOf(iv, ciphertext)
    }

    private fun decryptBackup(key: SecretKeySpec, cipherText: ByteArray, ivParameterSpec: IvParameterSpec): String {
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.DECRYPT_MODE, key, ivParameterSpec)
        return String(cipher.doFinal(cipherText))
    }

    //    @Throws(java.lang.Exception::class)
    private fun rsaEncrypt(text: ByteArray, publicKey: PublicKey): String {
        //Get Cipher Instance RSA With ECB Mode and OAEPWITHSHA-512ANDMGF1PADDING Padding
        val cipher: Cipher = Cipher.getInstance("RSA/ECB/OAEPWITHSHA-512ANDMGF1PADDING")

        //Initialize Cipher for ENCRYPT_MODE
        cipher.init(Cipher.ENCRYPT_MODE, publicKey)

        //Perform Encryption
        return String(Base64.getEncoder().encode(cipher.doFinal(text)))
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
                    CoroutineScope(Dispatchers.Default).launch {
                        try {
                            val message = call.argument<String>("message")
                            val roomSecretKey = call.argument<String>("roomSecretKey")
                            if (message != null && roomSecretKey != null) {
                                val response = encryptMessage(message, roomSecretKey)
                                launch(Dispatchers.Main) {
                                    result.success(response)
                                }
                            } else {
                                launch(Dispatchers.Main) {
                                    result.error("Encrypt Message failed", "WHERE PAYLOAD???? - message=$message roomSecretKey=$roomSecretKey", "?")
                                }

                            }
                        } catch (e: Exception) {
                            launch(Dispatchers.Main) {
                                result.error("Encrypt Message failed", e.message, e.stackTrace)
                            }
                        }
                    }
                }
                "decryptMessage" -> {
                    CoroutineScope(Dispatchers.Default).launch {
                        try {
                            val encryptedMessage = call.argument<String>("encryptedMessage")
                            val roomSecretKey = call.argument<String>("roomSecretKey")
                            val bytesOfIV = call.argument<String>("IV")
                            if (encryptedMessage != null && roomSecretKey != null && bytesOfIV != null) {
                                val response = decryptMessage(encryptedMessage, roomSecretKey, bytesOfIV)
                                launch(Dispatchers.Main) {
                                    result.success(response)
                                }
                            } else {
                                launch(Dispatchers.Main) {
                                    result.error("decryptMessage failed", "WHERE PAYLOAD???? - message=$encryptedMessage roomSecretKey=$roomSecretKey bytesOfIV=$bytesOfIV", "?")
                                }

                            }
                        } catch (e: Exception) {
                            launch(Dispatchers.Main) {
                                result.error("decryptMessage failed", e.message, e.stackTrace)
                            }
                        }
                    }
                }
                //
                "generateKeyPair" -> {
                    CoroutineScope(Dispatchers.Default).launch {
                        try {
                            val response = generateKeyPair()
                            launch(Dispatchers.Main) {
                                result.success(response)
                            }
                        } catch (e: Exception) {
                            launch(Dispatchers.Main) {
                                result.error("generateKeyPair failed", e.message, e.stackTrace)
                            }
                        }
                    }
                }
                "generateRoomSecret" -> {
                    CoroutineScope(Dispatchers.Default).launch {
                        try {
                            val response = generateRoomSecret()
                            launch(Dispatchers.Main) {
                                result.success(response)
                            }
                        } catch (e: Exception) {
                            launch(Dispatchers.Main) {
                                result.error("generateRoomSecret failed", e.message, e.stackTrace)
                            }
                        }
                    }
                }
                //
                "encryptRoomSecret" -> {
                    CoroutineScope(Dispatchers.Default).launch {
                        try {
                            val roomSecretKey = call.argument<String>("roomSecret")
                            val rsaPublicKey = Base64.getDecoder().decode(call.argument<String>("rsaPublicKey"))
                            if (roomSecretKey != null && rsaPublicKey != null) {
                                val response = encryptRoomSecret(roomSecretKey.encodeToByteArray(), rsaPublicKey)
                                launch(Dispatchers.Main) {
                                    result.success(response)
                                }
                            } else {
                                throw Exception("assert roomSecretKey != null && rsaPublicKey != null")
                            }
                        } catch (e: Exception) {
                            launch(Dispatchers.Main) {
                                result.error("encryptRoomSecret failed", e.message, e.stackTrace)
                            }
                        }
                    }
                }

                "decryptRoomSecret" -> {
                    CoroutineScope(Dispatchers.Default).launch {
                        try {
                            val roomSecretKeyEncrypted = call.argument<String>("roomSecretEncrypted")
                            val rsaPrivateKey = Base64.getDecoder().decode(call.argument<String>("rsaPrivateKey"))
                            if (roomSecretKeyEncrypted !== null && rsaPrivateKey !== null) {
                                val response = decryptRoomSecret(roomSecretKeyEncrypted, rsaPrivateKey)
                                launch(Dispatchers.Main) {
                                    result.success(response)
                                }
                            } else {
                                throw Exception("assert roomSecretKeyEncrypted !== null && rsaPrivateKey !== null")
                            }
                        } catch (e: Exception) {
                            launch(Dispatchers.Main) {
                                result.error("decryptRoomSecret failed", e.message, e.stackTrace)
                            }
                        }
                    }
                }
                "saveBackupKey" -> {
                    CoroutineScope(Dispatchers.Default).launch {
                        try {
                            val password = call.argument<String>("password")
                            val salt = call.argument<String>("salt")
                            val privateRsaKey = call.argument<String>("privateRsaKey")
                            if (password !== null && salt !== null && privateRsaKey !== null) {
                                val response = saveBackupKey(password, salt, privateRsaKey)
                                launch(Dispatchers.Main) {
                                    result.success(response)
                                }
                            } else {
                                throw Exception("assert roomSecretKeyEncrypted !== null && rsaPrivateKey !== null")
                            }
                        } catch (e: Exception) {
                            launch(Dispatchers.Main) {
                                result.error("saveBackupKey failed", e.message, e.stackTrace)
                            }
                        }
                    }
                }
                "restoreBackupKey" -> {
                    CoroutineScope(Dispatchers.Default).launch {
                        try {
                            val password = call.argument<String>("password")
                            val salt = call.argument<String>("salt")
                            val IV = call.argument<String>("IV")
                            val cipherText = call.argument<String>("encryptedBackup")
                            if (password !== null && salt !== null && IV !== null && cipherText !== null) {
                                val response = restoreBackupKey(password, salt, IV, cipherText)
                                launch(Dispatchers.Main) {
                                    result.success(response)
                                }
                            } else {
                                throw Exception("password !== null && salt !== null && IV !== null && encryptedBackup !== null")
                            }
                        } catch (e: Exception) {
                            launch(Dispatchers.Main) {
                                result.error("restoreBackupKey failed", e.message, e.stackTrace)
                            }
                        }
                    }
                }
            }
        }
    }
}
