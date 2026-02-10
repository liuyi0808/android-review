# Navigation

## 1. Type-Safe Navigation (Navigation Compose 2.8+)

```kotlin
@Serializable data object Login
@Serializable data object Home
@Serializable data class Profile(val userId: String)

NavHost(navController = navController, startDestination = Login) {
    composable<Login> { LoginScreen(onLogin = { navController.navigate(Home) }) }
    composable<Home> { HomeScreen() }
    composable<Profile> { backStackEntry ->
        val profile: Profile = backStackEntry.toRoute<Profile>()
        ProfileScreen(userId = profile.userId)
    }
}
```

## 2. Back Stack Management

```kotlin
navController.navigate(Home) {
    popUpTo(Login) { inclusive = true }  // remove login from back stack
}
```

## 3. Navigation Arguments

NEVER pass complex objects as navigation arguments. Pass IDs, fetch in destination.

## 4. One-Time Navigation Events

Use Channel/SharedFlow (NOT LiveData/StateFlow). See architecture skill for event channel pattern.

```kotlin
// ViewModel
private val _navigationEvent: Channel<NavigationEvent> = Channel()
val navigationEvent: Flow<NavigationEvent> = _navigationEvent.receiveAsFlow()

// Composable
LaunchedEffect(Unit) {
    viewModel.navigationEvent.collect { event ->
        when (event) {
            is NavigationEvent.GoToProfile -> navController.navigate(Profile(event.userId))
        }
    }
}
```
