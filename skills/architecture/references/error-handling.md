# Error Handling

## Standard Pattern

```kotlin
// Domain layer: Result type
suspend fun getUser(id: String): Result<User>

// ViewModel: handle Result
viewModelScope.launch {
    getUserUseCase(userId)
        .onSuccess { user -> _uiState.update { it.copy(user = user) } }
        .onFailure { error ->
            val message = when (error) {
                is NetworkException -> "Network error. Check connection."
                is AuthException -> "Session expired. Please login."
                is ValidationException -> error.message
                else -> "Unexpected error occurred."
            }
            _uiState.update { it.copy(error = message) }
        }
}
```

## Custom Exception Hierarchy

```kotlin
sealed class AppException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    class Network(message: String, cause: Throwable? = null) : AppException(message, cause)
    class Auth(message: String) : AppException(message)
    class Validation(message: String) : AppException(message)
    class NotFound(message: String) : AppException(message)
    class Server(message: String, val code: Int) : AppException(message)
}
```

## Rules

1. Use `Result<T>` for all fallible operations in domain/data layers.
2. Map network exceptions to domain exceptions in Repository.
3. Present user-friendly messages in ViewModel (NEVER raw exception messages).
4. NEVER silently swallow exceptions — always log or report.
5. Use sealed class hierarchy for typed error handling.

## Checklist

- [ ] Result type used for fallible operations
- [ ] Exceptions mapped to domain types in Repository
- [ ] User-friendly error messages in ViewModel
- [ ] No raw exception messages shown to user
- [ ] Global error handler for uncaught exceptions
