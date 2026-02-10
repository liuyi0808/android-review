# MASVS-PLATFORM: Platform Interaction

Validate Intents, restrict exported components, secure Content Providers, harden WebViews.

## Bad: Exported Activity Without Validation

```kotlin
// BAD: Trusts incoming Intent blindly, loads arbitrary URLs
class DeepLinkActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        webView.loadUrl(intent.getStringExtra("url")!!) // Untrusted input
    }
}
```

## Good: Intent Validation

```kotlin
// GOOD: Allowlist-based URI validation
class DeepLinkActivity : AppCompatActivity() {
    private val allowedHosts = setOf("example.com", "www.example.com")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val uri = intent.data ?: run { finish(); return }
        if (uri.scheme != "https" || uri.host !in allowedHosts) { finish(); return }
        handleValidDeepLink(uri)
    }
}
```

## Good: Hardened WebView

```kotlin
// GOOD: Minimal permissions, domain-restricted navigation
webView.settings.apply {
    javaScriptEnabled = true // Only if required
    allowFileAccess = false
    allowContentAccess = false
    allowFileAccessFromFileURLs = false
    allowUniversalAccessFromFileURLs = false
    mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
}
webView.webViewClient = object : WebViewClient() {
    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        return request.url.host?.endsWith("example.com") != true // Block untrusted
    }
}
```

## Checklist

- [ ] Exported components have intent filters or permission checks
- [ ] Incoming Intent extras validated (type, range, allowlist)
- [ ] `PendingIntent` uses `FLAG_IMMUTABLE` (API 31+)
- [ ] Content Providers `exported="false"` unless sharing required; parameterized queries
- [ ] WebView file access disabled; navigation restricted to trusted domains
- [ ] `@JavascriptInterface` methods validate all input; no implicit broadcasts with sensitive data
