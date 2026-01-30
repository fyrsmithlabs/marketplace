---
name: effective-go
description: Use when writing Go code, reviewing Go PRs, or asking "is this idiomatic Go?", "how should I structure this in Go?", "what's the Go way to do X?". Provides Effective Go principles for development guidance and code review reference. Covers Go 1.18+ generics, Go 1.22+ iterators, modern testing, and tooling.
---

# Effective Go

Idiomatic Go development guidance based on Effective Go principles. Use for writing new Go code, reviewing PRs, or as reference material for go-reviewer agents.

**Go Version Coverage:** Go 1.18+ (generics), Go 1.22+ (iterators), Go 1.23+ (range-over-func)

## Modes of Operation

| Mode | Trigger | Action |
|------|---------|--------|
| **Development** | Writing new Go code | Apply patterns proactively |
| **Review** | Reviewing Go PRs/code | Check against anti-patterns |
| **Reference** | "How do I X in Go?" | Provide idiomatic solution |

---

## Formatting

**Mandatory:** Run `gofmt` on all Go code. No exceptions.

| Rule | Correct | Wrong |
|------|---------|-------|
| Indentation | Tabs | Spaces |
| Opening brace | Same line as declaration | New line |
| Line length | No hard limit (gofmt handles) | Arbitrary wrapping |

```go
// Correct: brace on same line
func process(data []byte) error {
    if len(data) == 0 {
        return errors.New("empty data")
    }
    return nil
}

// Wrong: brace on new line (not Go style)
func process(data []byte) error
{
    // ...
}
```

---

## Naming Conventions

### Package Names

| Rule | Good | Bad |
|------|------|-----|
| Lowercase, single word | `http`, `json`, `template` | `httpUtil`, `json_parser` |
| Short, descriptive | `bytes`, `io` | `utilities`, `helpers` |
| No stuttering with types | `time.Duration` | `time.TimeDuration` |

```go
// Good: package name doesn't repeat in type name
package user
type Service struct{} // usage: user.Service

// Bad: stuttering
package user
type UserService struct{} // usage: user.UserService
```

### Getters and Setters

| Pattern | Correct | Wrong |
|---------|---------|-------|
| Getter | `obj.Name()` | `obj.GetName()` |
| Setter | `obj.SetName(n)` | `obj.Name(n)` |

```go
type User struct {
    name string
}

// Correct: getter without "Get" prefix
func (u *User) Name() string { return u.name }

// Correct: setter with "Set" prefix
func (u *User) SetName(n string) { u.name = n }
```

### Interface Names

| Method Count | Naming Pattern | Examples |
|--------------|----------------|----------|
| Single method | Method + "-er" | `Reader`, `Writer`, `Stringer` |
| Multiple methods | Descriptive noun | `ReadWriter`, `FileInfo` |

```go
// Single method: -er suffix
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Combination: compose the names
type ReadWriter interface {
    Reader
    Writer
}
```

### Export Rules

| Visibility | Case | Example |
|------------|------|---------|
| Exported (public) | Uppercase first letter | `Config`, `Parse`, `DefaultTimeout` |
| Unexported (private) | Lowercase first letter | `config`, `parse`, `defaultTimeout` |

### MixedCaps

Use `MixedCaps` or `mixedCaps`, never underscores.

```go
// Correct
var userID int
var httpClient *http.Client
const maxRetryCount = 3

// Wrong
var user_id int
var http_client *http.Client
const max_retry_count = 3
```

### Acronyms

Keep acronyms consistently cased.

```go
// Correct
var userID string    // ID is acronym
var httpURL string   // HTTP and URL are acronyms
type XMLParser struct{}

// Wrong
var UserId string
var httpUrl string
type XmlParser struct{}
```

---

## Error Handling

### Always Check Errors

```go
// Correct: check the error
f, err := os.Open(filename)
if err != nil {
    return fmt.Errorf("opening file: %w", err)
}
defer f.Close()

// Wrong: ignoring error
f, _ := os.Open(filename) // silent failure
```

### Error Wrapping

Use `%w` for wrapping errors to maintain the chain.

```go
// Correct: wrap with context
if err := db.Query(sql); err != nil {
    return fmt.Errorf("querying users: %w", err)
}

// Use errors.Is and errors.As for checking
if errors.Is(err, sql.ErrNoRows) {
    return nil, ErrNotFound
}

var pathErr *os.PathError
if errors.As(err, &pathErr) {
    log.Printf("path error on %s", pathErr.Path)
}
```

### Custom Error Types

```go
// Structured error with context
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

// Usage
return &ValidationError{Field: "email", Message: "invalid format"}
```

### Multiple Errors with errors.Join (Go 1.20+)

```go
// Combine multiple errors
func validateUser(u User) error {
    var errs []error

    if u.Name == "" {
        errs = append(errs, errors.New("name is required"))
    }
    if !strings.Contains(u.Email, "@") {
        errs = append(errs, errors.New("invalid email format"))
    }
    if u.Age < 0 {
        errs = append(errs, errors.New("age cannot be negative"))
    }

    return errors.Join(errs...) // Returns nil if errs is empty
}

// Check for specific error in joined errors
err := validateUser(user)
if errors.Is(err, ErrInvalidEmail) {
    // Handle invalid email
}

// Cleanup with multiple errors
func cleanup(resources ...io.Closer) error {
    var errs []error
    for _, r := range resources {
        if err := r.Close(); err != nil {
            errs = append(errs, err)
        }
    }
    return errors.Join(errs...)
}
```

### Sentinel Errors vs. Error Types

```go
// Sentinel errors: for well-known conditions
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrConflict     = errors.New("conflict")
)

// When to use: simple conditions, no extra context needed
func Get(id string) (*Item, error) {
    item, ok := store[id]
    if !ok {
        return nil, ErrNotFound // Caller uses errors.Is
    }
    return item, nil
}

// Error types: when you need structured data
type NotFoundError struct {
    Resource string
    ID       string
}

func (e *NotFoundError) Error() string {
    return fmt.Sprintf("%s %s not found", e.Resource, e.ID)
}

// When to use: need context, multiple fields, or methods
func GetUser(id string) (*User, error) {
    user, ok := users[id]
    if !ok {
        return nil, &NotFoundError{Resource: "user", ID: id}
    }
    return user, nil
}

// Caller extracts info
var nfe *NotFoundError
if errors.As(err, &nfe) {
    log.Printf("Missing %s: %s", nfe.Resource, nfe.ID)
}
```

### Error Handling Patterns

| Pattern | When to Use |
|---------|-------------|
| Return early | Most cases |
| Wrap with context | Crossing package boundaries |
| Sentinel errors | Well-known conditions (`io.EOF`) |
| Custom types | Need structured data |
| errors.Join | Multiple independent errors |

---

## Control Flow

### No Unnecessary Else

```go
// Correct: return early, no else needed
func validate(x int) error {
    if x < 0 {
        return errors.New("negative value")
    }
    // happy path continues
    return nil
}

// Wrong: unnecessary else
func validate(x int) error {
    if x < 0 {
        return errors.New("negative value")
    } else {
        return nil
    }
}
```

### Happy Path Flows Down

Keep the main logic at the lowest indentation level.

```go
// Correct: errors handled, happy path flows down
func process(data []byte) (*Result, error) {
    if len(data) == 0 {
        return nil, errors.New("empty data")
    }

    parsed, err := parse(data)
    if err != nil {
        return nil, fmt.Errorf("parsing: %w", err)
    }

    validated, err := validate(parsed)
    if err != nil {
        return nil, fmt.Errorf("validating: %w", err)
    }

    return transform(validated), nil
}
```

### Switch Over Long If-Else

```go
// Correct: switch for multiple conditions
switch ext := filepath.Ext(filename); ext {
case ".json":
    return parseJSON(data)
case ".yaml", ".yml":
    return parseYAML(data)
case ".toml":
    return parseTOML(data)
default:
    return nil, fmt.Errorf("unsupported format: %s", ext)
}

// Wrong: long if-else chain
if ext == ".json" {
    return parseJSON(data)
} else if ext == ".yaml" || ext == ".yml" {
    return parseYAML(data)
} else if ext == ".toml" {
    return parseTOML(data)
} else {
    return nil, fmt.Errorf("unsupported format: %s", ext)
}
```

### Labeled Breaks

```go
// Correct: labeled break for nested loops
outer:
for _, user := range users {
    for _, role := range user.Roles {
        if role == "admin" {
            found = user
            break outer
        }
    }
}
```

---

## Functions

### Named Return Parameters

Use sparingly for documentation; avoid in long functions.

```go
// Good: short function, named returns document purpose
func split(sum int) (x, y int) {
    x = sum * 4 / 9
    y = sum - x
    return
}

// Avoid: long function with naked return
func complexOperation() (result string, err error) {
    // 50+ lines...
    return // What is being returned? Unclear.
}
```

### Defer for Cleanup

Place defer immediately after resource acquisition.

```go
// Correct: defer immediately after Open
func readFile(path string) ([]byte, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer f.Close() // Immediately after successful open

    return io.ReadAll(f)
}

// Wrong: defer far from acquisition
func readFile(path string) ([]byte, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    // ... many lines ...
    defer f.Close() // Easy to forget or miss
    // ... more code ...
}
```

### Multiple Return Values

Use for error handling and optional values.

```go
// Standard pattern: (result, error)
func Parse(s string) (Value, error) {
    // ...
}

// Comma-ok idiom for optionals
value, ok := cache[key]
if !ok {
    value = computeDefault()
}
```

---

## Generics (Go 1.18+)

### When to Use Generics vs. Interfaces

| Use Case | Prefer | Example |
|----------|--------|---------|
| Behavior abstraction | Interface | `io.Reader`, `fmt.Stringer` |
| Type-safe collections | Generics | `Stack[T]`, `Set[T]` |
| Algorithm over types | Generics | `slices.Sort`, `maps.Keys` |
| Runtime polymorphism | Interface | Plugins, handlers |
| Compile-time safety | Generics | Containers, utilities |

```go
// Interface: when you care about behavior
type Handler interface {
    Handle(ctx context.Context, req Request) Response
}

// Generics: when you care about type safety across types
type Stack[T any] struct {
    items []T
}

func (s *Stack[T]) Push(item T) { s.items = append(s.items, item) }
func (s *Stack[T]) Pop() (T, bool) {
    if len(s.items) == 0 {
        var zero T
        return zero, false
    }
    item := s.items[len(s.items)-1]
    s.items = s.items[:len(s.items)-1]
    return item, true
}
```

### Type Constraints

```go
// Built-in constraints from constraints package
import "golang.org/x/exp/constraints"

func Min[T constraints.Ordered](a, b T) T {
    if a < b {
        return a
    }
    return b
}

// Custom constraints
type Number interface {
    ~int | ~int32 | ~int64 | ~float32 | ~float64
}

func Sum[T Number](values []T) T {
    var total T
    for _, v := range values {
        total += v
    }
    return total
}

// Comparable constraint for maps
func Keys[K comparable, V any](m map[K]V) []K {
    keys := make([]K, 0, len(m))
    for k := range m {
        keys = append(keys, k)
    }
    return keys
}
```

### Generic Data Structures

```go
// Thread-safe generic cache
type Cache[K comparable, V any] struct {
    mu    sync.RWMutex
    items map[K]V
}

func NewCache[K comparable, V any]() *Cache[K, V] {
    return &Cache[K, V]{items: make(map[K]V)}
}

func (c *Cache[K, V]) Get(key K) (V, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    v, ok := c.items[key]
    return v, ok
}

func (c *Cache[K, V]) Set(key K, value V) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.items[key] = value
}

// Generic result type (like Rust's Result)
type Result[T any] struct {
    Value T
    Err   error
}

func Ok[T any](v T) Result[T]    { return Result[T]{Value: v} }
func Err[T any](e error) Result[T] { return Result[T]{Err: e} }
```

### Generics Anti-Patterns

| Anti-Pattern | Issue | Fix |
|--------------|-------|-----|
| `any` everywhere | Loses type safety | Use specific constraints |
| Generic when interface works | Over-engineering | Interface for behavior |
| Complex constraint unions | Hard to read | Simplify or use interface |

```go
// Wrong: any loses type safety
func Process[T any](items []T) []T { /* ... */ }

// Better: constrain when operations are needed
func SortAndDedup[T constraints.Ordered](items []T) []T { /* ... */ }
```

---

## Iterators (Go 1.22+)

### iter Package Patterns

```go
import "iter"

// Basic iterator function signature
// iter.Seq[V] = func(yield func(V) bool)
// iter.Seq2[K, V] = func(yield func(K, V) bool)

// Creating an iterator
func Countdown(n int) iter.Seq[int] {
    return func(yield func(int) bool) {
        for i := n; i > 0; i-- {
            if !yield(i) {
                return
            }
        }
    }
}

// Usage
for v := range Countdown(5) {
    fmt.Println(v) // 5, 4, 3, 2, 1
}
```

### Range-Over-Func Syntax (Go 1.23+)

```go
// Iterate over custom sequences
type Tree[T any] struct {
    Left, Right *Tree[T]
    Value       T
}

func (t *Tree[T]) All() iter.Seq[T] {
    return func(yield func(T) bool) {
        if t == nil {
            return
        }
        for v := range t.Left.All() {
            if !yield(v) {
                return
            }
        }
        if !yield(t.Value) {
            return
        }
        for v := range t.Right.All() {
            if !yield(v) {
                return
            }
        }
    }
}

// Iterate over map in sorted key order
func SortedKeys[K cmp.Ordered, V any](m map[K]V) iter.Seq2[K, V] {
    return func(yield func(K, V) bool) {
        keys := slices.Sorted(maps.Keys(m))
        for _, k := range keys {
            if !yield(k, m[k]) {
                return
            }
        }
    }
}
```

### Iterator Composition

```go
// Filter iterator
func Filter[T any](seq iter.Seq[T], predicate func(T) bool) iter.Seq[T] {
    return func(yield func(T) bool) {
        for v := range seq {
            if predicate(v) {
                if !yield(v) {
                    return
                }
            }
        }
    }
}

// Map iterator
func Map[T, U any](seq iter.Seq[T], transform func(T) U) iter.Seq[U] {
    return func(yield func(U) bool) {
        for v := range seq {
            if !yield(transform(v)) {
                return
            }
        }
    }
}

// Take first n items
func Take[T any](seq iter.Seq[T], n int) iter.Seq[T] {
    return func(yield func(T) bool) {
        count := 0
        for v := range seq {
            if count >= n {
                return
            }
            if !yield(v) {
                return
            }
            count++
        }
    }
}

// Compose: filter, map, and take
for user := range Take(
    Map(
        Filter(users.All(), func(u User) bool { return u.Active }),
        func(u User) string { return u.Email },
    ),
    10,
) {
    fmt.Println(user)
}
```

### Standard Library Iterator Functions

```go
import (
    "maps"
    "slices"
)

// maps package (Go 1.23+)
for k, v := range maps.All(m) { /* ... */ }
keys := slices.Collect(maps.Keys(m))
values := slices.Collect(maps.Values(m))

// slices package (Go 1.23+)
for i, v := range slices.All(s) { /* ... */ }
for v := range slices.Values(s) { /* ... */ }
for v := range slices.Backward(s) { /* ... */ }

// Collect iterator to slice
slice := slices.Collect(iterator)

// Chain iterators
combined := slices.Collect(iter.Chain(seq1, seq2))
```

---

## Data Structures

### new() vs make()

| Function | Use For | Returns |
|----------|---------|---------|
| `new(T)` | Allocate zero-value | `*T` (pointer) |
| `make(T, ...)` | Slices, maps, channels | `T` (initialized) |

```go
// new: allocates zeroed memory, returns pointer
p := new(User) // *User with zero values

// make: initializes slices, maps, channels
slice := make([]int, 0, 10)   // len=0, cap=10
m := make(map[string]int)      // initialized map
ch := make(chan int, 5)        // buffered channel
```

### Prefer Slices Over Arrays

```go
// Correct: slice for flexibility
func process(data []byte) error {
    // ...
}

// Avoid: fixed array limits flexibility
func process(data [1024]byte) error {
    // ...
}
```

### Composite Literals

```go
// Struct literal with field names
user := User{
    Name:  "Alice",
    Email: "alice@example.com",
    Age:   30,
}

// Slice literal
primes := []int{2, 3, 5, 7, 11}

// Map literal
lookup := map[string]int{
    "one":   1,
    "two":   2,
    "three": 3,
}
```

### Comma-Ok Idiom

```go
// Map access
value, ok := m[key]
if !ok {
    // key not present
}

// Type assertion
str, ok := v.(string)
if !ok {
    // v is not a string
}

// Channel receive
value, ok := <-ch
if !ok {
    // channel closed
}
```

---

## Interfaces

### Small Interfaces

Prefer interfaces with 1-2 methods.

```go
// Good: small, focused interfaces
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Closer interface {
    Close() error
}

// Compose when needed
type ReadCloser interface {
    Reader
    Closer
}

// Avoid: large interfaces
type Repository interface {
    Create(ctx context.Context, item Item) error
    Read(ctx context.Context, id string) (Item, error)
    Update(ctx context.Context, item Item) error
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, filter Filter) ([]Item, error)
    Count(ctx context.Context, filter Filter) (int, error)
    // ... too many methods
}
```

### Accept Interfaces, Return Concrete

```go
// Correct: accept interface, return concrete
func NewProcessor(r io.Reader) *Processor {
    return &Processor{reader: r}
}

// Wrong: return interface (hides implementation)
func NewProcessor(r io.Reader) Processor {
    return &processor{reader: r}
}
```

### Implicit Satisfaction

Interfaces are satisfied implicitly; no `implements` keyword needed.

```go
// Type implicitly satisfies io.Reader by having Read method
type MyReader struct {
    data []byte
    pos  int
}

func (r *MyReader) Read(p []byte) (n int, err error) {
    if r.pos >= len(r.data) {
        return 0, io.EOF
    }
    n = copy(p, r.data[r.pos:])
    r.pos += n
    return n, nil
}

// No need to declare: var _ io.Reader = (*MyReader)(nil)
// (though compile-time checks like this are acceptable)
```

---

## Concurrency

### Share by Communicating

```go
// Correct: communicate via channels
func worker(jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        results <- process(job)
    }
}

// Instead of sharing memory with locks
type SharedState struct {
    mu    sync.Mutex
    count int
}
```

### Channel Patterns

```go
// Fan-out: multiple workers reading from one channel
jobs := make(chan Job, 100)
for i := 0; i < numWorkers; i++ {
    go worker(jobs, results)
}

// Fan-in: merge multiple channels into one
func merge(cs ...<-chan int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup
    for _, c := range cs {
        wg.Add(1)
        go func(c <-chan int) {
            defer wg.Done()
            for v := range c {
                out <- v
            }
        }(c)
    }
    go func() {
        wg.Wait()
        close(out)
    }()
    return out
}
```

### Context for Cancellation

```go
func fetch(ctx context.Context, url string) ([]byte, error) {
    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}

// Usage with timeout
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

data, err := fetch(ctx, "https://api.example.com/data")
```

### Goroutine Lifecycle Management

Always ensure goroutines can exit.

```go
// Correct: goroutine respects cancellation
func startWorker(ctx context.Context) {
    go func() {
        ticker := time.NewTicker(time.Second)
        defer ticker.Stop()

        for {
            select {
            case <-ctx.Done():
                return // Clean exit
            case <-ticker.C:
                doWork()
            }
        }
    }()
}

// Wrong: goroutine runs forever
func startWorker() {
    go func() {
        for {
            time.Sleep(time.Second)
            doWork() // Never stops
        }
    }()
}
```

### sync.WaitGroup for Coordination

```go
func processAll(items []Item) {
    var wg sync.WaitGroup

    for _, item := range items {
        wg.Add(1)
        go func(it Item) {
            defer wg.Done()
            process(it)
        }(item) // Pass item to avoid closure capture bug
    }

    wg.Wait()
}
```

---

## Modern Testing

### Table-Driven Tests with Subtests

```go
func TestParse(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    Result
        wantErr bool
    }{
        {
            name:  "valid input",
            input: "42",
            want:  Result{Value: 42},
        },
        {
            name:    "empty input",
            input:   "",
            wantErr: true,
        },
        {
            name:    "invalid format",
            input:   "not-a-number",
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("Parse() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if !tt.wantErr && got != tt.want {
                t.Errorf("Parse() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

### Parallel Tests

```go
func TestConcurrent(t *testing.T) {
    tests := []struct {
        name  string
        input string
    }{
        {"case1", "input1"},
        {"case2", "input2"},
    }

    for _, tt := range tests {
        tt := tt // Capture range variable (not needed in Go 1.22+)
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel() // Run subtests in parallel
            result := Process(tt.input)
            // assertions...
            _ = result
        })
    }
}
```

### Fuzzing (go test -fuzz)

```go
// Fuzz test discovers edge cases automatically
func FuzzParse(f *testing.F) {
    // Add seed corpus
    f.Add("42")
    f.Add("-1")
    f.Add("0")
    f.Add("")

    f.Fuzz(func(t *testing.T, input string) {
        result, err := Parse(input)
        if err != nil {
            return // Invalid input is ok
        }
        // Verify invariants on valid input
        if result.Value < 0 && !result.Negative {
            t.Errorf("negative value but Negative flag not set")
        }
        // Round-trip test
        if Format(result) != input {
            t.Errorf("round trip failed: %q -> %v -> %q", input, result, Format(result))
        }
    })
}

// Run: go test -fuzz=FuzzParse -fuzztime=30s
```

### Testcontainers for Integration Tests

```go
import (
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/modules/postgres"
)

func TestWithDatabase(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test")
    }

    ctx := context.Background()

    // Start PostgreSQL container
    pgContainer, err := postgres.Run(ctx,
        "postgres:16-alpine",
        postgres.WithDatabase("testdb"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
    )
    if err != nil {
        t.Fatal(err)
    }
    defer pgContainer.Terminate(ctx)

    // Get connection string
    connStr, err := pgContainer.ConnectionString(ctx, "sslmode=disable")
    if err != nil {
        t.Fatal(err)
    }

    // Run tests against real database
    db, err := sql.Open("postgres", connStr)
    if err != nil {
        t.Fatal(err)
    }
    defer db.Close()

    // Test your repository
    repo := NewUserRepository(db)
    // assertions...
    _ = repo
}
```

### Test Helpers and Assertions

```go
// t.Helper marks function as test helper
func assertNil(t testing.TB, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("expected nil error, got: %v", err)
    }
}

func assertEqual[T comparable](t testing.TB, got, want T) {
    t.Helper()
    if got != want {
        t.Errorf("got %v, want %v", got, want)
    }
}

// t.Cleanup for resource cleanup
func setupTestServer(t *testing.T) *httptest.Server {
    srv := httptest.NewServer(http.HandlerFunc(handler))
    t.Cleanup(srv.Close) // Automatic cleanup
    return srv
}

// Golden file testing
func TestOutput(t *testing.T) {
    got := Generate()
    golden := filepath.Join("testdata", t.Name()+".golden")

    if *update {
        os.WriteFile(golden, []byte(got), 0644)
    }

    want, _ := os.ReadFile(golden)
    if got != string(want) {
        t.Errorf("output mismatch, run with -update to refresh golden files")
    }
}
```

---

## Module Management

### Workspace Mode (go.work)

```go
// go.work - multi-module development
go 1.22

use (
    ./api
    ./sdk
    ./internal/shared
)

// Commands
// go work init ./api ./sdk     - create workspace
// go work use ./new-module     - add module to workspace
// go work sync                 - sync dependencies
```

### Private Module Authentication

```bash
# .netrc for private modules
machine github.com
    login USERNAME
    password TOKEN

# Or use GOPRIVATE
export GOPRIVATE=github.com/myorg/*,gitlab.com/mycompany/*

# Git config for SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

### go.mod Best Practices

```go
// go.mod
module github.com/myorg/myproject

go 1.22

require (
    github.com/lib/pq v1.10.9
    golang.org/x/sync v0.6.0
)

// Tooling dependencies (not imported)
tool (
    golang.org/x/tools/cmd/stringer
    github.com/golangci/golangci-lint/cmd/golangci-lint
)
```

### Vulnerability Scanning

```bash
# Install govulncheck
go install golang.org/x/vuln/cmd/govulncheck@latest

# Scan project
govulncheck ./...

# Scan specific binary
govulncheck -mode=binary ./cmd/server

# Common workflow in CI
govulncheck -format json ./... > vuln-report.json
```

### Version Selection

```bash
# Get specific version
go get github.com/pkg/errors@v0.9.1

# Get latest minor version
go get github.com/pkg/errors@v0.9

# Get latest version
go get github.com/pkg/errors@latest

# Upgrade all dependencies
go get -u ./...

# Upgrade only patch versions
go get -u=patch ./...

# Show why a dependency is needed
go mod why github.com/pkg/errors

# Show available versions
go list -m -versions github.com/pkg/errors
```

---

## Tooling

### golangci-lint Configuration

```yaml
# .golangci.yml
run:
  timeout: 5m
  tests: true

linters:
  enable:
    - errcheck
    - govet
    - staticcheck
    - unused
    - gosimple
    - ineffassign
    - typecheck
    - gocritic
    - revive
    - gofmt
    - goimports
    - misspell
    - unconvert
    - unparam
    - nilerr
    - errorlint      # error wrapping checks
    - exhaustive     # enum switch exhaustiveness
    - nilnil         # nil return with nil error
    - noctx          # HTTP requests without context

linters-settings:
  errcheck:
    check-type-assertions: true
    check-blank: true

  gocritic:
    enabled-tags:
      - diagnostic
      - style
      - performance

  revive:
    rules:
      - name: exported
        arguments: [checkPrivateReceivers]
      - name: blank-imports
      - name: context-as-argument
      - name: error-return
      - name: error-strings

  errorlint:
    errorf: true
    asserts: true
    comparison: true

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - errcheck
        - gocritic
```

### Makefile Integration

```makefile
.PHONY: lint test build

lint:
	golangci-lint run ./...

test:
	go test -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

fuzz:
	go test -fuzz=. -fuzztime=60s ./...

vuln:
	govulncheck ./...

build:
	go build -o bin/server ./cmd/server

all: lint test vuln build
```

### gopls Integration (Editor Setup)

```json
// VSCode settings.json
{
  "go.useLanguageServer": true,
  "gopls": {
    "analyses": {
      "unusedparams": true,
      "shadow": true,
      "nilness": true
    },
    "staticcheck": true,
    "gofumpt": true,
    "hints": {
      "assignVariableTypes": true,
      "compositeLiteralFields": true,
      "compositeLiteralTypes": true,
      "constantValues": true,
      "functionTypeParameters": true,
      "parameterNames": true,
      "rangeVariableTypes": true
    }
  }
}
```

---

## Performance

### Profile-Guided Optimization (PGO)

```bash
# Step 1: Build and run with profiling
go build -o server ./cmd/server
./server &
# Generate load...
curl http://localhost:8080/api/heavy-endpoint
# Collect CPU profile
go tool pprof -proto -output=default.pgo http://localhost:8080/debug/pprof/profile?seconds=30

# Step 2: Rebuild with PGO
go build -pgo=default.pgo -o server ./cmd/server

# Or place profile in source directory (auto-detected)
mv default.pgo ./cmd/server/default.pgo
go build -pgo=auto -o server ./cmd/server
```

### Memory Profiling Patterns

```go
import (
    "net/http"
    _ "net/http/pprof"
    "runtime"
)

func main() {
    // Enable pprof endpoint
    go func() {
        http.ListenAndServe("localhost:6060", nil)
    }()

    // Your application...
}

// Analyze with:
// go tool pprof http://localhost:6060/debug/pprof/heap
// go tool pprof http://localhost:6060/debug/pprof/allocs
```

```go
// Reduce allocations
// Wrong: creates new slice each call
func process(items []Item) []Result {
    results := []Result{} // Allocates with default capacity
    for _, item := range items {
        results = append(results, transform(item))
    }
    return results
}

// Correct: pre-allocate
func process(items []Item) []Result {
    results := make([]Result, 0, len(items)) // Pre-allocate
    for _, item := range items {
        results = append(results, transform(item))
    }
    return results
}

// Use sync.Pool for frequently allocated objects
var bufPool = sync.Pool{
    New: func() any { return new(bytes.Buffer) },
}

func processRequest(data []byte) string {
    buf := bufPool.Get().(*bytes.Buffer)
    defer func() {
        buf.Reset()
        bufPool.Put(buf)
    }()

    buf.Write(data)
    // process...
    return buf.String()
}
```

### Benchmarking Best Practices

```go
func BenchmarkParse(b *testing.B) {
    input := []byte(`{"name": "test", "value": 42}`)

    b.ResetTimer() // Reset after setup
    b.ReportAllocs() // Report allocations

    for i := 0; i < b.N; i++ {
        _, err := Parse(input)
        if err != nil {
            b.Fatal(err)
        }
    }
}

// Sub-benchmarks for comparison
func BenchmarkEncode(b *testing.B) {
    data := generateTestData()

    b.Run("JSON", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            json.Marshal(data)
        }
    })

    b.Run("Gob", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            var buf bytes.Buffer
            gob.NewEncoder(&buf).Encode(data)
        }
    })
}

// Prevent compiler optimization
var result Result

func BenchmarkCompute(b *testing.B) {
    var r Result
    for i := 0; i < b.N; i++ {
        r = Compute(input) // Use result
    }
    result = r // Assign to package var to prevent optimization
}
```

```bash
# Run benchmarks
go test -bench=. -benchmem ./...

# Compare benchmarks
go test -bench=. -count=10 > old.txt
# Make changes...
go test -bench=. -count=10 > new.txt
benchstat old.txt new.txt
```

---

## Anti-Patterns to Flag

Use this checklist during code review.

### Critical (Request Changes)

| Anti-Pattern | Issue | Fix |
|--------------|-------|-----|
| Ignored errors | `f, _ := os.Open(file)` | Check and handle error |
| Goroutine leak | No exit condition | Add context cancellation |
| Data race | Shared mutable state without sync | Use channels or mutex |
| Naked return in long function | Unclear what's returned | Explicit return values |
| `%v` instead of `%w` for wrapping | Breaks error chain | Use `fmt.Errorf("...: %w", err)` |
| Known vulnerabilities | Outdated dependencies | Run `govulncheck ./...` |

### High (Request Changes)

| Anti-Pattern | Issue | Fix |
|--------------|-------|-----|
| Stuttering names | `user.UserService` | `user.Service` |
| Get prefix on getters | `GetName()` | `Name()` |
| Large interface | 5+ methods | Split into small interfaces |
| Unnecessary else | `if x { return } else { ... }` | Remove else |
| Generic with `any` constraint | Loses type safety | Use specific constraint |
| Missing context parameter | Can't cancel/timeout | Accept `context.Context` first |

### Medium (Comment)

| Anti-Pattern | Issue | Fix |
|--------------|-------|-----|
| Underscores in names | `max_count` | `maxCount` |
| Long if-else chains | 3+ conditions | Use switch |
| Defer far from resource | Hard to track cleanup | Defer immediately after acquisition |
| Fixed-size array params | `[N]byte` | Use slice `[]byte` |
| Not using `errors.Join` | Multiple errors discarded | Collect and join errors |
| No test subtests | Hard to identify failures | Use `t.Run(name, func...)` |

### Low (Suggestion)

| Anti-Pattern | Issue | Fix |
|--------------|-------|-----|
| Inconsistent acronym casing | `userId`, `Url` | `userID`, `URL` |
| Missing doc comment on exported | No documentation | Add `// Name does X` |
| Complex boolean expression | Hard to read | Extract to named variable |
| Not using iterators | Verbose collection code | Use `iter.Seq` patterns |
| No benchmark tests | Unknown performance | Add `BenchmarkX` functions |

---

## Review Checklist

When reviewing Go code, verify:

**Fundamentals**
- [ ] `gofmt` has been run (no formatting issues)
- [ ] All errors are checked (no `_` for error values)
- [ ] Naming follows conventions (no stuttering, correct casing)
- [ ] Interfaces are small (1-2 methods preferred)
- [ ] Goroutines have exit conditions (context, done channel)
- [ ] Resources are cleaned up with defer (immediately after acquisition)
- [ ] Happy path flows down (errors handled and returned early)
- [ ] No unnecessary else after return
- [ ] Context passed through for cancellation
- [ ] Composite literals use field names

**Modern Go (1.18+)**
- [ ] Generics used appropriately (not overused, proper constraints)
- [ ] Error wrapping uses `%w` (not `%v`)
- [ ] Multiple errors combined with `errors.Join`
- [ ] Dependencies scanned with `govulncheck`
- [ ] Tests use subtests (`t.Run`) for clarity
- [ ] Benchmarks exist for performance-critical code
- [ ] golangci-lint passes with project config

---

## Quick Reference

### Naming

```
Package:    lowercase, single word
Exported:   UpperCamelCase
Unexported: lowerCamelCase
Acronyms:   consistent case (ID, URL, HTTP)
Getter:     Name() not GetName()
Setter:     SetName()
Interface:  Reader, Writer (method + er)
```

### Error Handling

```go
// Check
if err != nil { return err }

// Wrap (use %w, not %v)
return fmt.Errorf("context: %w", err)

// Check type
errors.Is(err, ErrNotFound)
errors.As(err, &target)

// Multiple errors (Go 1.20+)
return errors.Join(err1, err2)
```

### Generics (Go 1.18+)

```go
// Type constraint
func Min[T constraints.Ordered](a, b T) T

// Generic type
type Cache[K comparable, V any] struct{}

// Custom constraint
type Number interface { ~int | ~float64 }
```

### Iterators (Go 1.22+)

```go
// Define iterator
func All() iter.Seq[T] {
    return func(yield func(T) bool) { /* ... */ }
}

// Use iterator
for v := range collection.All() { }

// Collect to slice
slice := slices.Collect(iterator)
```

### Concurrency

```go
// Channel: unbuffered
ch := make(chan T)

// Channel: buffered
ch := make(chan T, size)

// Context: with timeout
ctx, cancel := context.WithTimeout(parent, duration)
defer cancel()

// Wait group
var wg sync.WaitGroup
wg.Add(n)
go func() { defer wg.Done(); /* work */ }()
wg.Wait()
```

### Testing

```bash
# Table tests with subtests
t.Run("name", func(t *testing.T) { ... })

# Fuzzing
go test -fuzz=FuzzParse -fuzztime=30s

# Benchmarking
go test -bench=. -benchmem ./...
```

### Tooling

```bash
# Lint
golangci-lint run ./...

# Vulnerability scan
govulncheck ./...

# Profile-guided optimization
go build -pgo=default.pgo ./...
```

---

## Integration with Reviewers

This skill provides reference material for:

| Agent | Usage |
|-------|-------|
| `code-quality-reviewer` | Anti-pattern detection, complexity |
| `security-reviewer` | Goroutine leaks, race conditions, vulnerabilities |
| `go-reviewer` (if created) | Language-specific idiom enforcement |

When reviewing Go code, agents should cross-reference this skill for language-specific guidance.

---

## Version History

| Go Version | Key Features in This Guide |
|------------|---------------------------|
| 1.18 | Generics, type constraints |
| 1.20 | `errors.Join`, arena package |
| 1.21 | `log/slog`, `maps`, `slices` packages |
| 1.22 | Range over integers, `iter` package |
| 1.23 | Range-over-func, iterator standard library |
