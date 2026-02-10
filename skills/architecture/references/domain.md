# Domain Layer

## UseCase Pattern

```kotlin
class LoginUseCase @Inject constructor(
    private val userRepository: UserRepository,
    private val tokenRepository: TokenRepository
) {
    suspend operator fun invoke(
        username: String,
        password: String
    ): Result<User> {
        if (username.isBlank()) return Result.failure(ValidationError("Username required"))
        if (password.length < 8) return Result.failure(ValidationError("Password too short"))

        return userRepository.login(username, password)
            .onSuccess { user -> tokenRepository.saveToken(user.token) }
    }
}
```

## Domain Model (Pure Kotlin, No Android Dependencies)

```kotlin
// No Room annotations, no Gson/Moshi annotations
data class User(
    val id: String,
    val username: String,
    val email: String,
    val displayName: String
)
```

## Repository Interface (Defined in Domain)

```kotlin
interface UserRepository {
    suspend fun login(username: String, password: String): Result<User>
    suspend fun getUser(userId: String): Result<User>
    fun observeUser(userId: String): Flow<User>
    suspend fun logout()
}
```

## Rules

1. Domain layer has ZERO Android dependencies (pure Kotlin).
2. UseCase has single `invoke` operator (one operation per UseCase).
3. Repository interfaces defined in domain, implemented in data.
4. Domain models are independent of DTO/Entity (separate mapping).
5. Use `Result<T>` for operations that can fail.

## Checklist

- [ ] Domain models have no framework annotations
- [ ] UseCase is single-purpose with invoke operator
- [ ] Repository interface in domain package
- [ ] No Android imports in domain layer
- [ ] Result type for fallible operations
