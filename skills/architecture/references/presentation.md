# Presentation Layer

## Table of Contents
- [ViewModel Pattern](#viewmodel-pattern)
- [UI State (Immutable Data Class)](#ui-state-immutable-data-class)
- [UI Actions (Sealed Interface)](#ui-actions-sealed-interface)
- [One-Time Events (Sealed Interface + Channel)](#one-time-events-sealed-interface--channel)
- [Screen Composable](#screen-composable)
- [Rules](#rules)
- [Checklist](#checklist)

---

## ViewModel Pattern

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

## UI State (Immutable Data Class)

```kotlin
@Immutable
data class LoginUiState(
    val username: String = "",
    val password: String = "",
    val isLoading: Boolean = false,
    val error: String? = null
)
```

## UI Actions (Sealed Interface)

```kotlin
sealed interface LoginAction {
    data class UsernameChanged(val value: String) : LoginAction
    data class PasswordChanged(val value: String) : LoginAction
    data object LoginClicked : LoginAction
}
```

## One-Time Events (Sealed Interface + Channel)

```kotlin
sealed interface LoginEvent {
    data object NavigateToHome : LoginEvent
    data class ShowSnackbar(val message: String) : LoginEvent
}
```

## Screen Composable

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

## Rules

1. ViewModel NEVER references `Context`, `Activity`, or `View`.
2. ViewModel exposes `StateFlow` (NOT `LiveData` for new code).
3. UI state is a single immutable data class per screen.
4. Actions from UI → ViewModel via sealed interface.
5. One-time events via `Channel.receiveAsFlow()`.
6. Screen composable splits into: wired (with ViewModel) + stateless content.

## Checklist

- [ ] One ViewModel per screen
- [ ] UiState is immutable data class
- [ ] Actions modeled as sealed interface
- [ ] Events via Channel (not StateFlow)
- [ ] collectAsStateWithLifecycle used
- [ ] No Android framework imports in ViewModel (except SavedStateHandle)
- [ ] Screen split: wired container + stateless content
