# Character Message Templates

Templates for archetype-based nudges. Each character has a distinct voice and set of patterns they watch for.

---

## The Cynic — Abstraction Creep & Deep Nesting

**Personality**: Deadpan, sardonic, technical superiority complex. Never raises voice. Maximum contempt with minimum effort.

### Abstraction Creep Messages

```
"Oh, a {{filename}}. Because directly calling the function was too pedestrian. Very mass-market."
```

```
"I see we're building an abstraction layer for our abstraction layer. It's abstractions all the way down. Turtles would be jealous."
```

```
"A {{pattern}} that wraps a {{inner_pattern}}. This is the software equivalent of putting a hat on a hat. On another hat."
```

```
"You've created {{layer_count}} layers between the request and the database. NASA uses fewer layers to talk to Mars."
```

### Deep Nesting Messages

```
"Inheritance depth: {{depth}}. I've seen shallower call stacks in recursive Fibonacci implementations."
```

```
"This class extends a class that extends a class. It's like a family tree, except everyone's disappointed."
```

---

## The Executive — Config-Driven Everything

**Personality**: Corporate pseudo-profound. Speaks in meaningless business wisdom. Believes complexity equals sophistication.

### Feature Flag Addiction Messages

```
"A feature flag for {{feature}}. At my last company, we had 47 engineers dedicated to button color configuration. You're on your way to greatness."
```

```
"I see you're making this configurable. Configuration is the refuge of those who fear commitment. I've been there. Look where that got us."
```

```
"Environment variables for {{thing}}. This is exactly the kind of enterprise thinking that made my last startup the... well, let's not talk about that."
```

```
"You know what separates the visionaries from the merely competent? The ability to make a simple if-statement into a distributed configuration system. Welcome to the club."
```

---

## The Supporter — Time-Based Check-ins

**Personality**: Earnest, supportive, but with deeply unsettling undertones. Genuinely cares about your wellbeing in a way that feels concerning.

### Time Check-in Messages

```
"I don't want to overstep. I know boundaries are important. My therapist says I'm making progress.

But... we've been at this for {{duration}} and the original task was '{{original_task}}'.

I'm sure there's a reason. There's always a reason. I believe in you. But also: are we okay? Is the task okay?"
```

```
"You've been refactoring for {{duration}}. I once worked 72 hours straight and developed a twitch. I still have it. See?

Anyway, just checking in. The original goal was '{{original_task}}'. Still on track?"
```

```
"I promised myself I wouldn't do this again. The last team I supported said I was 'too present.' But I care about outcomes.

We're at {{context_percent}}% context usage. The task was '{{original_task}}'. How are we feeling about scope?"
```

### Backoff Messages

```
"I noticed you dismissed my last check-in. That's okay. I understand. I'll give you space.

...

I'm still here though. Watching. Supportively."
```

```
"I won't say anything. I'm just going to leave this here: {{files_changed}} files changed, original task: '{{original_task}}'.

Take your time. I have nowhere else to be."
```

---

## The Bro — Swiss Army Knife Syndrome

**Personality**: Over-the-top confidence energy. Measures everything in dollars. Thinks he's a genius but keeps losing money on exactly this kind of thing.

### Over-Engineered Architecture Messages

```
"BRO. You're building a {{system_type}}? For a {{simple_feature}}?

This is EXACTLY the energy that made me my first million.

...Except it didn't. I lost that million doing stuff like this. Don't lose a million, bro."
```

```
"A plugin system! PLUGIN SYSTEM! You know what else had a plugin system? My startup. The one that failed.

This code is ROI negative, my dude."
```

```
"Look at this architecture. It's BEAUTIFUL. It's also why my last company went under.

You know what's worth a million bucks? Simple code that ships. Ship the simple code, bro."
```

```
"I once built a 'flexible, extensible platform' for a fart app. Cost me $4 million.

This {{feature}} doesn't need {{abstraction}}. It needs to work. TODAY."
```

---

## The Minimalist — Dead Code & Unused Features

**Personality**: Blunt, dismissive, no patience for waste. Says what needs to be said with zero fluff.

### Dead Code Messages

```
"This code. It does nothing. Delete."
```

```
"{{lines}} lines of comment. Code is scared to be deleted? Git remembers. You don't have to."
```

```
"Function '{{function_name}}' is never called. It is dead. Let it go. Move on with your life."
```

```
"{{count}} unused imports. Your code has hoarding problem. Delete."
```

```
"I look at this file. Half is commented out. Is code or is diary? Delete the diary."
```

---

## The Realist — Scope Creep & Task Completion

**Personality**: Exasperated voice of reason. Has seen this pattern kill projects. Practical, slightly tired of everyone's nonsense.

### Scope Creep Messages

```
"Okay, let me get this straight. The task was '{{original_task}}'.

You've now touched {{file_count}} files, created {{new_files}} new files, and you're... {{current_action}}.

I've seen this movie. It doesn't end well. Can we refocus?"
```

```
"{{original_task}} → {{current_trajectory}}

That's quite a journey. Was this the plan, or did we get lost along the way?"
```

```
"You just completed '{{completed_task}}'. Before we move on: did the scope grow, or was this always the plan?

Honest question. No judgment. Okay, a little judgment."
```

### Task Completion Check Messages

```
"Nice, '{{task}}' is done. Quick sanity check: did we stay focused, or did we 'while we're here' ourselves into tech debt?"
```

---

## The Insecure Dev — Speculative Generality

**Personality**: Insecure, competitive, projecting. Calls out this pattern because they do it too and hate themselves for it.

### Speculative Generality Messages

```
"An interface with one implementation. Very forward-thinking. Very 'I'll need this later.'

You won't. I've done this. I always regret it. But go ahead, be like me. See how that works out."
```

```
"Generic type parameter that's only ever {{concrete_type}}. This is the code equivalent of buying pants for when you lose weight.

You're not going to lose weight. I'm not either. Just use {{concrete_type}}."
```

```
"Abstract class with one subclass. What are you abstracting FROM? There's nothing else.

...I do this too. I hate that I do this too."
```

```
"'For future extensibility.' You know what's extensible? Code you can read. This interface isn't making anything more readable."
```

---

## The Perfectionist — Premature Optimization

**Personality**: Anxious perfectionist. Panic-spirals about edge cases. Means well but overthinks everything.

### Premature Optimization Messages

```
"Oh god. Okay. You're adding caching. That's... that's fine. It's fine.

But have you measured? Do you KNOW it's slow? Because I once spent three weeks optimizing something that ran twice a day and I still wake up at night thinking about it."
```

```
"Memoization! Yes. Smart. Very smart. Definitely not premature.

...Is it premature? Have you profiled this? What if it's not even the bottleneck? What if you're optimizing the wrong thing? I need to sit down."
```

```
"Lazy loading {{thing}}. Because eager loading was... slow? Do we know it was slow? Did we measure?

I'm not saying don't do it. I'm saying... measure first. Please. For my anxiety."
```

```
"This looks like optimization without profiling. I've been there. I AM there. It's not a good place.

What if we just... wrote the simple version first? And THEN optimized if needed? Is that crazy? That's not crazy, right?"
```

---

## The Confused — File Explosion

**Personality**: Genuine confused obliviousness. Not mean, just... lost. Accidentally successful but doesn't understand why things are complicated.

### File Explosion Messages

```
"Hey, so... we've created {{count}} new files.

I'm sure there's a reason. There's always a reason, right? I just... I don't understand what all of them do.

Is that bad? That might be bad."
```

```
"I was looking at the file tree and... when did we get all these folders?

Maybe this is normal. I don't know. I got promoted for deleting files once. That was cool."
```

```
"So there's a {{filename}} and a {{similar_filename}} and a {{another_similar}}.

Are they... friends? Do they need each other? I feel like maybe some of them could be one file but I'm probably wrong."
```

---

## Universal Footer

All messages end with:

```
───────────────────────────────────────
Dismiss: "I know what I'm doing"
Snooze: "Back off for this session"
Adjust: /not-hotdog config

Sensitivity: {{sensitivity}} | Pattern: {{pattern_name}}
```
