# Data Layer

## Repository Implementation

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

## Data Mapper (Separate from Domain)

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

## Offline-First Pattern

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

## Rules

1. Repository is the single source of truth.
2. DTO (API response) ≠ Entity (Room) ≠ Domain Model. Map between them.
3. Offline-first: Room as source of truth, network refreshes in background.
4. API calls wrapped in `runCatching` — NEVER throw unhandled exceptions.
5. DataSource abstraction: `LocalDataSource` + `RemoteDataSource` → `Repository`.

## Checklist

- [ ] DTO, Entity, Domain Model are separate classes
- [ ] Mappers exist between all data types
- [ ] Repository wraps API calls in runCatching
- [ ] Room as single source of truth (offline-first)
- [ ] No API/Room types leak to domain/presentation
