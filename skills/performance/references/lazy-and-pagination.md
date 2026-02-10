# Lazy Loading & Pagination

## 1. Paging 3 for Large Data Sets

```kotlin
val pager = Pager(
    config = PagingConfig(
        pageSize = 20,
        prefetchDistance = 5,
        enablePlaceholders = false
    ),
    pagingSourceFactory = { MyPagingSource(api) }
)
val flow: Flow<PagingData<Item>> = pager.flow.cachedIn(viewModelScope)
```

## 2. LazyColumn/LazyRow (Not Column + forEach)

```kotlin
// BAD: composes ALL items
Column {
    items.forEach { item -> ItemRow(item) }
}

// GOOD: only composes visible items
LazyColumn {
    items(items, key = { it.id }) { item -> ItemRow(item) }
}
```

## 3. Image Loading with Coil

```kotlin
AsyncImage(
    model = ImageRequest.Builder(LocalContext.current)
        .data(url)
        .crossfade(true)
        .size(Size.ORIGINAL)  // or specific size
        .build(),
    contentDescription = null
)
```
