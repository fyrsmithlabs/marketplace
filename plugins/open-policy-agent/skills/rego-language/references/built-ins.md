# Rego Built-in Functions Reference

Complete reference for commonly used OPA/Rego built-in functions with examples.

## String Functions

### `concat(delimiter, array)`
Join array elements with a delimiter.
```rego
concat("/", ["api", "v1", "users"])  # "api/v1/users"
```

### `contains(string, search)`
Check if string contains substring.
```rego
contains("hello world", "world")  # true
```

### `startswith(string, prefix)` / `endswith(string, suffix)`
```rego
startswith("https://example.com", "https://")  # true
endswith("image:latest", ":latest")  # true
```

### `sprintf(format, values)`
Format string with values.
```rego
sprintf("container '%s' on port %d", ["nginx", 80])  # "container 'nginx' on port 80"
```

### `split(string, delimiter)`
```rego
split("a.b.c", ".")  # ["a", "b", "c"]
```

### `trim(string, cutset)` / `trim_prefix` / `trim_suffix` / `trim_space`
```rego
trim_space("  hello  ")  # "hello"
trim_prefix("Bearer token123", "Bearer ")  # "token123"
```

### `lower(string)` / `upper(string)`
```rego
lower("Hello")  # "hello"
upper("hello")  # "HELLO"
```

### `replace(string, old, new)`
```rego
replace("foo-bar-baz", "-", "_")  # "foo_bar_baz"
```

### `substring(string, start, length)`
```rego
substring("hello world", 6, 5)  # "world"
substring("Bearer token", 7, -1)  # "token" (-1 = rest of string)
```

---

## Regex Functions

### `regex.match(pattern, value)`
```rego
regex.match("^v[0-9]+\\.[0-9]+", "v1.23")  # true
```

### `regex.find_all_string_submatch_n(pattern, string, n)`
```rego
regex.find_all_string_submatch_n("([a-z]+):([0-9]+)", "port:80", -1)
# [["port:80", "port", "80"]]
```

### `regex.split(pattern, string)`
```rego
regex.split("\\s+", "hello   world")  # ["hello", "world"]
```

---

## Aggregate Functions

### `count(collection)`
Works on strings, arrays, objects, and sets.
```rego
count([1, 2, 3])  # 3
count({"a": 1, "b": 2})  # 2
count("hello")  # 5
```

### `sum(array)` / `product(array)`
```rego
sum([1, 2, 3])  # 6
product([2, 3, 4])  # 24
```

### `min(collection)` / `max(collection)`
```rego
min([3, 1, 2])  # 1
max({10, 20, 5})  # 20
```

### `sort(array)`
```rego
sort([3, 1, 2])  # [1, 2, 3]
```

---

## Object Functions

### `object.get(object, key, default)`
Safe access with default for missing keys.
```rego
object.get(input, "metadata", {})
object.get(input.spec, "securityContext", {"runAsNonRoot": false})
```

### `object.keys(object)`
```rego
object.keys({"a": 1, "b": 2})  # {"a", "b"} (returns a set)
```

### `object.remove(object, keys)`
```rego
object.remove({"a": 1, "b": 2, "c": 3}, {"b"})  # {"a": 1, "c": 3}
```

### `object.union(a, b)`
Merge objects (b overrides a on conflict).
```rego
object.union({"a": 1}, {"b": 2})  # {"a": 1, "b": 2}
```

### `object.filter(object, keys)`
Keep only specified keys.
```rego
object.filter({"a": 1, "b": 2, "c": 3}, {"a", "c"})  # {"a": 1, "c": 3}
```

---

## Set Operations

### `intersection(set_a, set_b)`
```rego
intersection({1, 2, 3}, {2, 3, 4})  # {2, 3}
```

### `union(set_a, set_b)`
```rego
union({1, 2}, {3, 4})  # {1, 2, 3, 4}
```

### `A - B` (set difference)
```rego
{1, 2, 3} - {2}  # {1, 3}
```

---

## Type Checking

### `is_string(x)`, `is_number(x)`, `is_boolean(x)`, `is_null(x)`, `is_array(x)`, `is_object(x)`, `is_set(x)`
```rego
is_string("hello")  # true
is_array([1, 2])  # true
```

### `type_name(x)`
```rego
type_name("hello")  # "string"
type_name([1])  # "array"
type_name({"a": 1})  # "object"
```

---

## Encoding Functions

### `json.marshal(x)` / `json.unmarshal(string)`
```rego
json.marshal({"key": "value"})  # "{\"key\":\"value\"}"
json.unmarshal("{\"key\":\"value\"}")  # {"key": "value"}
```

### `yaml.marshal(x)` / `yaml.unmarshal(string)`
```rego
yaml.unmarshal("key: value")  # {"key": "value"}
```

### `base64.encode(string)` / `base64.decode(string)`
```rego
base64.encode("hello")  # "aGVsbG8="
base64.decode("aGVsbG8=")  # "hello"
```

---

## JWT Functions

### `io.jwt.decode(token)`
Returns `[header, payload, signature]`.
```rego
[header, payload, _] := io.jwt.decode(input.token)
payload.sub  # "user123"
```

### `io.jwt.verify_rs256(token, certificate)`
```rego
io.jwt.verify_rs256(input.token, data.keys.public_key)  # true/false
```

### `io.jwt.decode_verify(token, constraints)`
Decode and verify in one step.
```rego
[valid, header, payload] := io.jwt.decode_verify(token, {
    "cert": data.keys.public_key,
    "iss": "https://auth.example.com",
    "aud": "my-api"
})
```

---

## HTTP Function

### `http.send(request)`
```rego
response := http.send({
    "method": "GET",
    "url": "https://api.example.com/data",
    "headers": {"Authorization": sprintf("Bearer %s", [input.token])},
    "timeout": "5s",
    "cache": true,
    "force_cache": true,
    "force_cache_duration_seconds": 300
})
response.status_code == 200
data := response.body
```

**Warning:** Avoid `http.send` in admission control hot paths. Prefer data bundles for external data.

---

## Time Functions

### `time.now_ns()`
Current time in nanoseconds.

### `time.parse_rfc3339_ns(string)`
```rego
ts := time.parse_rfc3339_ns("2024-01-15T10:30:00Z")
```

### `time.date(ns)`
Returns `[year, month, day]`.
```rego
[year, month, day] := time.date(time.now_ns())
```

---

## Crypto Functions

### `crypto.sha256(string)`
```rego
crypto.sha256("hello")  # hex-encoded hash
```

### `crypto.hmac.sha256(message, key)`
```rego
crypto.hmac.sha256("message", "secret-key")
```

---

## Glob Function

### `glob.match(pattern, delimiters, match)`
```rego
glob.match("/api/v1/*", ["/"], "/api/v1/users")  # true
glob.match("/api/*/users", ["/"], "/api/v2/users")  # true
```

---

## Conversion Functions

### `to_number(x)`
```rego
to_number("42")  # 42
to_number("3.14")  # 3.14
```

### `numbers.range(a, b)`
Generate array from a to b inclusive.
```rego
numbers.range(1, 5)  # [1, 2, 3, 4, 5]
```
