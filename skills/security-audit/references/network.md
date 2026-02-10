# MASVS-NETWORK: Network Security

Enforce TLS 1.2+, certificate pinning, and block all cleartext traffic.

## Bad: Trusting All Certificates

```kotlin
// BAD: Disabling certificate validation = MITM wide open
val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
    override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {}
    override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {}
    override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
})
```

## Good: Network Security Config + Certificate Pinning

```xml
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors><certificates src="system" /></trust-anchors>
    </base-config>
    <domain-config>
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2025-12-31">
            <pin digest="SHA-256">BASE64_PRIMARY_PIN=</pin>
            <pin digest="SHA-256">BASE64_BACKUP_PIN=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

```kotlin
// GOOD: OkHttp CertificatePinner as defense-in-depth
val pinner = CertificatePinner.Builder()
    .add("api.example.com", "sha256/PRIMARY_PIN=")
    .add("api.example.com", "sha256/BACKUP_PIN=")
    .build()
val client = OkHttpClient.Builder().certificatePinner(pinner).build()
```

## Checklist

- [ ] `cleartextTrafficPermitted="false"` in network security config
- [ ] Certificate pinning with backup pins; no custom `TrustManager` bypasses
- [ ] No permissive `HostnameVerifier`; TLS 1.2+ enforced
- [ ] No sensitive data in URL query parameters; API keys in headers

| Anti-Pattern | Risk | Fix |
|---|---|---|
| `TrustManager` accepting all certs | MITM | System trust store + pinning |
| `HostnameVerifier { _, _ -> true }` | Hostname spoofing | Remove custom verifier |
| Tokens in URL query strings | Logged by proxies | `Authorization` header |
| Single pin without backup | Cert rotation breaks app | Always include backup pin |
