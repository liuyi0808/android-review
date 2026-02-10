# MASVS-CRYPTO: Cryptography

Use strong, modern algorithms. Never hardcode keys. Never roll your own crypto.

## Bad: Hardcoded Key + ECB Mode

```kotlin
// BAD: Hardcoded key, ECB mode (deterministic), no IV
val secretKey = "MyS3cr3tK3y12345".toByteArray()
val cipher = Cipher.getInstance("AES/ECB/PKCS5Padding")
cipher.init(Cipher.ENCRYPT_MODE, SecretKeySpec(secretKey, "AES"))
```

## Good: Android Keystore + AES-GCM

```kotlin
// GOOD: Hardware-backed Keystore, AES-GCM with auto-generated IV
object SecureCrypto {
    private const val KEY_ALIAS = "app_encryption_key"

    fun generateKey() {
        val spec = KeyGenParameterSpec.Builder(
            KEY_ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        ).setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256).build()
        KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
            .apply { init(spec) }.generateKey()
    }

    fun encrypt(plaintext: ByteArray): Pair<ByteArray, ByteArray> {
        val key = KeyStore.getInstance("AndroidKeyStore")
            .apply { load(null) }.getKey(KEY_ALIAS, null) as SecretKey
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key)
        return Pair(cipher.iv, cipher.doFinal(plaintext))
    }

    fun decrypt(iv: ByteArray, ciphertext: ByteArray): ByteArray {
        val key = KeyStore.getInstance("AndroidKeyStore")
            .apply { load(null) }.getKey(KEY_ALIAS, null) as SecretKey
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(128, iv))
        return cipher.doFinal(ciphertext)
    }
}
```

## Checklist

- [ ] No hardcoded encryption keys, IVs, or salts in source code
- [ ] AES-256-GCM for symmetric encryption (not ECB, not CBC without HMAC)
- [ ] Keys stored in Android Keystore (hardware-backed when available)
- [ ] RSA >= 2048 bits; no MD5, SHA-1 (security), DES, 3DES, RC4
- [ ] Unique IV per encryption; `SecureRandom` for all crypto randomness
- [ ] PBKDF2/Argon2/scrypt for key derivation with sufficient iterations

| Anti-Pattern | Risk | Fix |
|---|---|---|
| Hardcoded `SecretKeySpec` | Key extraction via RE | Android Keystore |
| `AES/ECB/*` | Pattern leakage | `AES/GCM/NoPadding` |
| `java.util.Random` for crypto | Predictable | `java.security.SecureRandom` |
| Keys in `strings.xml` / `BuildConfig` | Trivially extractable | Android Keystore |
