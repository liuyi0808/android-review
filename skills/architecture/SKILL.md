---
name: architecture
description: >
  Android application architecture standards using Clean Architecture, MVVM/MVI patterns,
  Hilt dependency injection, and modularization. Triggers when designing app structure,
  creating ViewModels, implementing repository pattern, setting up dependency injection,
  planning module boundaries, or discussing data/domain/presentation layers. Also triggers
  on keywords like "架构", "ViewModel", "Repository", "UseCase", "Hilt", "模块化",
  "MVVM", "MVI", "Clean Architecture", "数据层", "领域层".
model: sonnet
---

# Android Architecture Standards

Enforce Clean Architecture patterns with MVVM/MVI for Android Kotlin applications.

## When to Use

- Starting a new project or feature module
- Reviewing architecture decisions
- Creating ViewModel, Repository, or UseCase classes
- Setting up dependency injection (Hilt)
- Planning modularization strategy
- Designing data flow and state management

## Architecture Review Process

Evaluate code against ALL layers. Output findings as:

```
[ARCH-XXXXX] severity: CRITICAL | HIGH | MEDIUM | LOW
  Finding: <architecture violation or improvement>
  Location: <file:line>
  Fix: <concrete refactoring guidance>
```

---

## 1. Layer Architecture

### Three Layers (Mandatory)

```
┌─────────────────────────────────┐
│        Presentation Layer       │  UI, ViewModel, UiState
│         (app / feature)         │
├─────────────────────────────────┤
│          Domain Layer           │  UseCase, Domain Model, Repository Interface
│           (optional)            │
├─────────────────────────────────┤
│           Data Layer            │  Repository Impl, DataSource, DTO, API, DB
│       (data / network)          │
└─────────────────────────────────┘
```

### Dependency Rule

Dependencies flow INWARD only:
- Presentation → Domain → Data (allowed)
- Data → Domain (NEVER)
- Presentation → Data directly (AVOID, use Domain)

### Package Structure

```
com.ai.project1/
├── di/                          # Hilt modules
│   ├── AppModule.kt
│   ├── NetworkModule.kt
│   └── DatabaseModule.kt
├── data/
│   ├── local/
│   │   ├── dao/                 # Room DAOs
│   │   ├── entity/              # Room entities
│   │   └── AppDatabase.kt
│   ├── remote/
│   │   ├── api/                 # Retrofit interfaces
│   │   ├── dto/                 # Data Transfer Objects
│   │   └── interceptor/
│   ├── mapper/                  # DTO ↔ Domain mappers
│   └── repository/              # Repository implementations
├── domain/
│   ├── model/                   # Domain models (pure Kotlin)
│   ├── repository/              # Repository interfaces
│   └── usecase/                 # Use cases
└── ui/                          # Presentation
    ├── navigation/
    ├── theme/
    ├── component/               # Reusable composables
    └── screen/
        ├── login/
        │   ├── LoginScreen.kt
        │   ├── LoginViewModel.kt
        │   └── LoginUiState.kt
        └── home/
            ├── HomeScreen.kt
            ├── HomeViewModel.kt
            └── HomeUiState.kt
```

---

## 2. Presentation Layer

### ViewModel Pattern

```kotlin
@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase,
    private val savedStateHandle: SavedStateHandle
) : ViewModel() {
    private val _uiState: MutableStateFlow<LoginUiState> =
        MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    private val _events: Channel<LoginEvent> = Channel()
    val events: Flow<LoginEvent> = _events.receiveAsFlow()

    fun onAction(action: LoginAction) {
        when (action) {
            is LoginAction.UsernameChanged -> handleUsernameChanged(action.value)
            is LoginAction.PasswordChanged -> handlePasswordChanged(action.value)
            is LoginAction.LoginClicked -> handleLogin()
        }
    }

    private fun handleLogin() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            loginUseCase(
                username = _uiState.value.username,
                password = _uiState.value.password
            )
                .onSuccess { _events.send(LoginEvent.NavigateToHome) }
                .onFailure { error ->
                    _uiState.update { it.copy(isLoading = false, error = error.message) }
                }
        }
    }

    private fun handleUsernameChanged(value: String) {
        _uiState.update { it.copy(username = value, error = null) }
    }

    private fun handlePasswordChanged(value: String) {
        _uiState.update { it.copy(password = value, error = null) }
    }
}
```

### UI State (Immutable Data Class)

```kotlin
@Immutable
data class LoginUiState(
    val username: String = "",
    val password: String = "",
    val isLoading: Boolean = false,
    val error: String? = null
)
```

### UI Actions (Sealed Interface)

```kotlin
sealed interface LoginAction {
    data class UsernameChanged(val value: String) : LoginAction
    data class PasswordChanged(val value: String) : LoginAction
    data object LoginClicked : LoginAction
}
```

### One-Time Events (Sealed Interface + Channel)

```kotlin
sealed interface LoginEvent {
    data object NavigateToHome : LoginEvent
    data class ShowSnackbar(val message: String) : LoginEvent
}
```

### Screen Composable

```kotlin
@Composable
fun LoginScreen(
    viewModel: LoginViewModel = hiltViewModel(),
    onNavigateToHome: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(Unit) {
        viewModel.events.collect { event ->
            when (event) {
                is LoginEvent.NavigateToHome -> onNavigateToHome()
                is LoginEvent.ShowSnackbar -> { /* show snackbar */ }
            }
        }
    }

    LoginContent(
        uiState = uiState,
        onAction = viewModel::onAction
    )
}

// Stateless content (testable, previewable)
@Composable
private fun LoginContent(
    uiState: LoginUiState,
    onAction: (LoginAction) -> Unit,
    modifier: Modifier = Modifier
) {
    // Pure UI, no ViewModel reference
}
```

### Rules

1. ViewModel NEVER references `Context`, `Activity`, or `View`.
2. ViewModel exposes `StateFlow` (NOT `LiveData` for new code).
3. UI state is a single immutable data class per screen.
4. Actions from UI → ViewModel via sealed interface.
5. One-time events via `Channel.receiveAsFlow()`.
6. Screen composable splits into: wired (with ViewModel) + stateless content.

### Checklist
- [ ] One ViewModel per screen
- [ ] UiState is immutable data class
- [ ] Actions modeled as sealed interface
- [ ] Events via Channel (not StateFlow)
- [ ] collectAsStateWithLifecycle used
- [ ] No Android framework imports in ViewModel (except SavedStateHandle)
- [ ] Screen split: wired container + stateless content

---

## 3. Domain Layer

### UseCase Pattern

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

### Domain Model (Pure Kotlin, No Android Dependencies)

```kotlin
// No Room annotations, no Gson/Moshi annotations
data class User(
    val id: String,
    val username: String,
    val email: String,
    val displayName: String
)
```

### Repository Interface (Defined in Domain)

```kotlin
interface UserRepository {
    suspend fun login(username: String, password: String): Result<User>
    suspend fun getUser(userId: String): Result<User>
    fun observeUser(userId: String): Flow<User>
    suspend fun logout()
}
```

### Rules

1. Domain layer has ZERO Android dependencies (pure Kotlin).
2. UseCase has single `invoke` operator (one operation per UseCase).
3. Repository interfaces defined in domain, implemented in data.
4. Domain models are independent of DTO/Entity (separate mapping).
5. Use `Result<T>` for operations that can fail.

### Checklist
- [ ] Domain models have no framework annotations
- [ ] UseCase is single-purpose with invoke operator
- [ ] Repository interface in domain package
- [ ] No Android imports in domain layer
- [ ] Result type for fallible operations

---

## 4. Data Layer

### Repository Implementation

```kotlin
class UserRepositoryImpl @Inject constructor(
    private val api: UserApi,
    private val userDao: UserDao,
    private val mapper: UserMapper
) : UserRepository {
    override suspend fun login(
        username: String,
        password: String
    ): Result<User> = runCatching {
        val response: LoginResponseDto = api.login(LoginRequestDto(username, password))
        val entity: UserEntity = mapper.dtoToEntity(response.user)
        userDao.insertUser(entity)
        mapper.entityToDomain(entity)
    }

    override fun observeUser(userId: String): Flow<User> {
        return userDao.observeUser(userId).map { mapper.entityToDomain(it) }
    }
}
```

### Data Mapper (Separate from Domain)

```kotlin
class UserMapper @Inject constructor() {
    fun dtoToDomain(dto: UserDto): User = User(
        id = dto.id,
        username = dto.username,
        email = dto.email,
        displayName = dto.displayName
    )

    fun entityToDomain(entity: UserEntity): User = User(
        id = entity.id,
        username = entity.username,
        email = entity.email,
        displayName = entity.displayName
    )

    fun dtoToEntity(dto: UserDto): UserEntity = UserEntity(
        id = dto.id,
        username = dto.username,
        email = dto.email,
        displayName = dto.displayName
    )
}
```

### Offline-First Pattern

```kotlin
override fun observeUsers(): Flow<List<User>> {
    return userDao.observeAll()
        .map { entities -> entities.map(mapper::entityToDomain) }
        .onStart {
            // Refresh from network in background
            runCatching {
                val remote = api.getUsers()
                userDao.insertAll(remote.map(mapper::dtoToEntity))
            }
        }
}
```

### Rules

1. Repository is the single source of truth.
2. DTO (API response) ≠ Entity (Room) ≠ Domain Model. Map between them.
3. Offline-first: Room as source of truth, network refreshes in background.
4. API calls wrapped in `runCatching` — NEVER throw unhandled exceptions.
5. DataSource abstraction: `LocalDataSource` + `RemoteDataSource` → `Repository`.

### Checklist
- [ ] DTO, Entity, Domain Model are separate classes
- [ ] Mappers exist between all data types
- [ ] Repository wraps API calls in runCatching
- [ ] Room as single source of truth (offline-first)
- [ ] No API/Room types leak to domain/presentation

---

## 5. Dependency Injection (Hilt)

### Module Structure

```kotlin
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds
    @Singleton
    abstract fun bindUserRepository(impl: UserRepositoryImpl): UserRepository
}

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit = Retrofit.Builder()
        .baseUrl(BuildConfig.BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(MoshiConverterFactory.create())
        .build()

    @Provides
    @Singleton
    fun provideUserApi(retrofit: Retrofit): UserApi =
        retrofit.create(UserApi::class.java)
}

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): AppDatabase =
        Room.databaseBuilder(context, AppDatabase::class.java, "app.db")
            .fallbackToDestructiveMigration()
            .build()

    @Provides
    fun provideUserDao(database: AppDatabase): UserDao = database.userDao()
}
```

### Rules

1. Use `@Binds` for interface→implementation bindings (more efficient than `@Provides`).
2. Use correct `@InstallIn` scope:
   - `SingletonComponent` — app lifetime (database, network)
   - `ViewModelComponent` — ViewModel lifetime
   - `ActivityComponent` — Activity lifetime (rarely needed)
3. NEVER inject `Activity` or `Fragment` into non-UI classes.
4. Use `@ApplicationContext` when Context is needed in singletons.

### Checklist
- [ ] @HiltAndroidApp on Application class
- [ ] @AndroidEntryPoint on Activities/Fragments
- [ ] @HiltViewModel on ViewModels
- [ ] Interfaces bound with @Binds (not @Provides)
- [ ] Correct scope for each dependency
- [ ] No manual dependency creation outside DI

---

## 6. Modularization Strategy

### Module Types

```
:app                    → Application module (wiring, navigation)
:feature:login          → Feature module (UI + ViewModel)
:feature:home           → Feature module
:core:data              → Data layer (repositories, data sources)
:core:domain            → Domain layer (models, use cases, interfaces)
:core:network           → Network (Retrofit, OkHttp)
:core:database          → Database (Room)
:core:ui                → Shared UI components, theme
:core:common            → Shared utilities, extensions
```

### Dependency Graph

```
:app → :feature:* → :core:domain
                  → :core:ui
:core:data → :core:domain
           → :core:network
           → :core:database
```

### Rules

1. Feature modules NEVER depend on other feature modules.
2. Feature modules depend on `:core:domain` and `:core:ui` only.
3. `:core:domain` has ZERO Android dependencies.
4. `:app` module is thin — only navigation and DI wiring.

### When to Modularize

- When build times exceed 2 minutes
- When team size exceeds 3 developers
- When features can be developed independently
- For small projects: single module is fine. Don't modularize prematurely.

### Checklist
- [ ] No circular dependencies between modules
- [ ] Feature modules don't depend on each other
- [ ] Domain module has no Android dependencies
- [ ] Build times acceptable (<2 min for incremental)
- [ ] API boundaries defined between modules

---

## 7. Error Handling

### Standard Pattern

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

### Custom Exception Hierarchy

```kotlin
sealed class AppException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    class Network(message: String, cause: Throwable? = null) : AppException(message, cause)
    class Auth(message: String) : AppException(message)
    class Validation(message: String) : AppException(message)
    class NotFound(message: String) : AppException(message)
    class Server(message: String, val code: Int) : AppException(message)
}
```

### Rules

1. Use `Result<T>` for all fallible operations in domain/data layers.
2. Map network exceptions to domain exceptions in Repository.
3. Present user-friendly messages in ViewModel (NEVER raw exception messages).
4. NEVER silently swallow exceptions — always log or report.
5. Use sealed class hierarchy for typed error handling.

### Checklist
- [ ] Result type used for fallible operations
- [ ] Exceptions mapped to domain types in Repository
- [ ] User-friendly error messages in ViewModel
- [ ] No raw exception messages shown to user
- [ ] Global error handler for uncaught exceptions
