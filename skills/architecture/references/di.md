# Dependency Injection (Hilt)

## Module Structure

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

## Rules

1. Use `@Binds` for interface→implementation bindings (more efficient than `@Provides`).
2. Use correct `@InstallIn` scope:
   - `SingletonComponent` — app lifetime (database, network)
   - `ViewModelComponent` — ViewModel lifetime
   - `ActivityComponent` — Activity lifetime (rarely needed)
3. NEVER inject `Activity` or `Fragment` into non-UI classes.
4. Use `@ApplicationContext` when Context is needed in singletons.

## Checklist

- [ ] @HiltAndroidApp on Application class
- [ ] @AndroidEntryPoint on Activities/Fragments
- [ ] @HiltViewModel on ViewModels
- [ ] Interfaces bound with @Binds (not @Provides)
- [ ] Correct scope for each dependency
- [ ] No manual dependency creation outside DI
