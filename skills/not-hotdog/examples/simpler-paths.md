# Simpler Paths — Before/After Examples

Reference examples for middle-out nudges. Each pattern includes a common over-engineered solution and its simpler alternative.

---

## Abstraction Creep

### UserServiceFactoryProvider → Direct Call

**Before** (4 layers):
```typescript
// UserController.ts
const user = await this.userServiceFactory.create().getUser(id);

// UserServiceFactory.ts
class UserServiceFactory {
  create(): UserService {
    return new UserService(this.repositoryFactory.create());
  }
}

// UserService.ts
class UserService {
  async getUser(id: string): Promise<User> {
    return this.repository.findById(id);
  }
}

// UserRepository.ts
class UserRepository {
  async findById(id: string): Promise<User> {
    return this.db.users.find(id);
  }
}
```

**After** (1 layer):
```typescript
// UserController.ts
const user = await db.users.find(id);
```

**When abstraction is warranted**: Multiple databases, complex caching, or genuinely different implementations that swap at runtime.

---

## Config-Driven Everything

### Feature Flag for One Button

**Before**:
```typescript
// config.ts
export const config = {
  features: {
    buttons: {
      submitStyle: {
        v2: {
          enabled: process.env.FEATURE_SUBMIT_BUTTON_V2 === 'true'
        }
      }
    }
  }
};

// SubmitButton.tsx
const variant = config.features.buttons.submitStyle.v2.enabled
  ? 'primary'
  : 'secondary';
```

**After**:
```typescript
// SubmitButton.tsx
<Button variant="primary">Submit</Button>
```

**When config is warranted**: A/B testing with analytics, gradual rollout to percentage of users, kill switches for risky features.

---

## Speculative Generality

### Interface with One Implementation

**Before**:
```typescript
interface IUserRepository {
  findById(id: string): Promise<User>;
  save(user: User): Promise<void>;
}

class PostgresUserRepository implements IUserRepository {
  // ... only implementation
}

// Usage always looks like:
const repo: IUserRepository = new PostgresUserRepository();
```

**After**:
```typescript
class UserRepository {
  findById(id: string): Promise<User> { /* ... */ }
  save(user: User): Promise<void> { /* ... */ }
}
```

**When interfaces are warranted**: Testing with mocks (but consider whether you need the interface or just the mock), genuinely swappable implementations (rare).

---

## Swiss Army Knife Syndrome

### Plugin System for Todo App

**Before**:
```typescript
// PluginManager.ts
class PluginManager {
  private plugins: Map<string, Plugin> = new Map();

  register(name: string, plugin: Plugin): void {
    this.plugins.set(name, plugin);
  }

  execute(name: string, context: PluginContext): void {
    this.plugins.get(name)?.execute(context);
  }
}

// DeletePlugin.ts
class DeletePlugin implements Plugin {
  execute(context: PluginContext): void {
    context.todoService.delete(context.todoId);
  }
}

// Usage
pluginManager.register('delete', new DeletePlugin());
pluginManager.execute('delete', { todoId, todoService });
```

**After**:
```typescript
// TodoItem.tsx
<button onClick={() => deleteTodo(id)}>Delete</button>
```

**When plugins are warranted**: Third-party extensibility, user-defined automations, genuinely dynamic behavior.

---

## Premature Optimization

### Caching Before Profiling

**Before**:
```typescript
class UserService {
  private cache = new LRUCache<string, User>({ max: 1000 });

  async getUser(id: string): Promise<User> {
    const cached = this.cache.get(id);
    if (cached) return cached;

    const user = await this.db.users.find(id);
    this.cache.set(id, user);
    return user;
  }
}
```

**After** (until profiling shows it's slow):
```typescript
class UserService {
  async getUser(id: string): Promise<User> {
    return this.db.users.find(id);
  }
}
```

**When caching is warranted**: Profiling shows this query is a bottleneck, external API with rate limits, genuinely expensive computation.

---

## Scope Creep

### "Fix typo" → Refactor auth system

**Original task**: Fix typo in login error message

**Actual changes**:
- Fixed typo (1 line)
- "While I'm here" refactored error handling (50 lines)
- Added new ErrorBoundary component (80 lines)
- Created error logging service (120 lines)
- Updated 8 files to use new error system

**Simpler path**:
```diff
- return "Invalid username or pasword";
+ return "Invalid username or password";
```

Create a separate task for the error handling improvements if they're genuinely needed.

---

## Dead Code

### Commented "Just In Case"

**Before**:
```typescript
function processOrder(order: Order) {
  // Old implementation - keeping just in case
  // const legacy = await legacyOrderSystem.process(order);
  // if (legacy.status === 'failed') {
  //   await notifyAdmin(legacy.error);
  //   return { success: false };
  // }

  return await newOrderSystem.process(order);
}
```

**After**:
```typescript
function processOrder(order: Order) {
  return await newOrderSystem.process(order);
}
```

**The simpler path**: Git remembers. Delete the code. If you need it, `git log -p -- filename` will find it.

---

## File Explosion

### One Feature, Eight Files

**Before** (for a "show user profile" feature):
```
src/
  features/
    user-profile/
      components/
        UserProfile.tsx
        UserProfileContainer.tsx
        UserProfileView.tsx
      hooks/
        useUserProfile.ts
      services/
        userProfileService.ts
      types/
        userProfile.types.ts
      utils/
        userProfileUtils.ts
      index.ts
```

**After**:
```
src/
  components/
    UserProfile.tsx  # Contains component, hook, and types
```

**When splitting is warranted**: File exceeds ~300 lines, logic is reused elsewhere, team conventions require it.
