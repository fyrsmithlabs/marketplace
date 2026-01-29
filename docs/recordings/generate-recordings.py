#!/usr/bin/env python3
"""
Generate synthetic asciinema recordings for marketplace commands.

asciicast v2 format:
- Line 1: Header JSON {"version": 2, "width": 120, "height": 30, ...}
- Subsequent lines: [timestamp, "o", "text"] for output

Usage:
    python generate-recordings.py           # Generate all recordings
    python generate-recordings.py fs-dev    # Generate fs-dev only
    python generate-recordings.py --list    # List available commands
"""

import json
import os
import sys
import time
from pathlib import Path
from typing import List, Tuple

RECORDINGS_DIR = Path(__file__).parent


def create_cast_file(
    filename: str,
    events: List[Tuple[float, str]],
    title: str = "",
    width: int = 120,
    height: int = 30,
):
    """Create an asciicast v2 file."""
    header = {
        "version": 2,
        "width": width,
        "height": height,
        "timestamp": int(time.time()),
        "title": title,
        "env": {"TERM": "xterm-256color", "SHELL": "/bin/zsh"},
    }

    filepath = RECORDINGS_DIR / filename
    filepath.parent.mkdir(parents=True, exist_ok=True)

    with open(filepath, "w") as f:
        f.write(json.dumps(header) + "\n")
        for timestamp, text in events:
            f.write(json.dumps([timestamp, "o", text]) + "\n")

    print(f"  Created: {filename}")


def type_text(text: str, start: float, char_delay: float = 0.05) -> List[Tuple[float, str]]:
    """Simulate typing text character by character."""
    events = []
    t = start
    for char in text:
        events.append((round(t, 3), char))
        t += char_delay
    return events


def output_lines(lines: List[str], start: float, line_delay: float = 0.1) -> List[Tuple[float, str]]:
    """Output multiple lines with delays."""
    events = []
    t = start
    for line in lines:
        events.append((round(t, 3), line + "\r\n"))
        t += line_delay
    return events


# ============================================================================
# fs-dev Recordings
# ============================================================================


def generate_init():
    """Generate /init command recording."""
    events = []
    t = 0.0

    # Shell prompt
    events.append((t, "$ "))
    t += 0.3

    # Type claude command
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.5

    # Claude Code startup
    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.8

    # Prompt
    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3

    # Type /init
    events.extend(type_text("/init", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    # Init output
    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ Project Initialization ═══\x1b[0m",
                "",
                "\x1b[33m▸\x1b[0m Detecting project type...",
            ],
            t,
            0.2,
        )
    )
    t += 1.0

    events.extend(
        output_lines(
            [
                "  \x1b[32m✓\x1b[0m Detected: Go project (go.mod found)",
                "  \x1b[32m✓\x1b[0m Git repository initialized",
                "  \x1b[32m✓\x1b[0m GitHub remote: fyrsmithlabs/example",
                "",
                "\x1b[33m▸\x1b[0m Checking compliance...",
            ],
            t,
            0.15,
        )
    )
    t += 1.2

    events.extend(
        output_lines(
            [
                "",
                "  ┌──────────────────────┬────────┐",
                "  │ Requirement          │ Status │",
                "  ├──────────────────────┼────────┤",
                "  │ README.md            │ \x1b[32m✓\x1b[0m      │",
                "  │ CHANGELOG.md         │ \x1b[33m○\x1b[0m      │",
                "  │ LICENSE              │ \x1b[32m✓\x1b[0m      │",
                "  │ .gitignore           │ \x1b[32m✓\x1b[0m      │",
                "  │ .gitleaks.toml       │ \x1b[33m○\x1b[0m      │",
                "  │ CLAUDE.md            │ \x1b[31m✗\x1b[0m      │",
                "  └──────────────────────┴────────┘",
                "",
            ],
            t,
            0.08,
        )
    )
    t += 1.5

    events.extend(
        output_lines(
            [
                "\x1b[33m▸\x1b[0m Creating missing files...",
                "  \x1b[32m✓\x1b[0m Created CHANGELOG.md",
                "  \x1b[32m✓\x1b[0m Created .gitleaks.toml",
                "  \x1b[32m✓\x1b[0m Created CLAUDE.md",
                "",
                "\x1b[1m\x1b[32m✓ Project initialized successfully!\x1b[0m",
                "",
            ],
            t,
            0.2,
        )
    )
    t += 1.0

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5

    # Exit
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.3
    events.append((t, "Goodbye!\r\n"))
    t += 0.2
    events.append((t, "$ "))

    create_cast_file("fs-dev/init.cast", events, title="Demo: /init")


def generate_yagni():
    """Generate /yagni command recording."""
    events = []
    t = 0.0

    events.append((t, "$ "))
    t += 0.3
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.8

    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3
    events.extend(type_text("/yagni", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ YAGNI Status ═══\x1b[0m",
                "",
                "  \x1b[1mStatus:\x1b[0m \x1b[32mEnabled\x1b[0m",
                "  \x1b[1mSensitivity:\x1b[0m Medium (3/5)",
                "  \x1b[1mWhitelist:\x1b[0m 2 patterns",
                "",
                "  ┌────────────────────────────────────────┐",
                "  │ Recent Nudges (last 7 days)            │",
                "  ├────────────────────────────────────────┤",
                "  │ • Premature abstraction (3)            │",
                "  │ • Unnecessary feature flag (1)         │",
                "  │ • Over-engineered error handling (1)   │",
                "  └────────────────────────────────────────┘",
                "",
                "  \x1b[2mCommands: /yagni config, /yagni why, /yagni whitelist\x1b[0m",
                "",
            ],
            t,
            0.1,
        )
    )
    t += 1.0

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    events.append((t + 0.2, "$ "))

    create_cast_file("fs-dev/yagni.cast", events, title="Demo: /yagni")


def generate_consensus_review():
    """Generate /consensus-review command recording."""
    events = []
    t = 0.0

    events.append((t, "$ "))
    t += 0.3
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.8

    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3
    events.extend(type_text("/consensus-review src/auth/", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ Consensus Review: src/auth/ ═══\x1b[0m",
                "",
                "\x1b[33m▸\x1b[0m Initializing parallel review...",
                "  Scope: 8 files (12,450 tokens)",
                "  Mode: Shared context",
                "  Budget scale: 1.76x",
                "",
            ],
            t,
            0.15,
        )
    )
    t += 1.0

    events.extend(
        output_lines(
            [
                "\x1b[33m▸\x1b[0m Dispatching agents...",
                "  ⟳ security-reviewer (budget: 14,418)",
                "  ⟳ vulnerability-reviewer (budget: 14,418)",
                "  ⟳ code-quality-reviewer (budget: 10,813)",
                "  ⟳ documentation-reviewer (budget: 7,209)",
                "  ⟳ user-persona-reviewer (budget: 7,209)",
                "  ⟳ go-reviewer (budget: 14,418)",
                "",
            ],
            t,
            0.1,
        )
    )
    t += 2.0

    # Progress indicators
    for i, agent in enumerate(["security", "vulnerability", "code-quality", "documentation", "user-persona", "go"]):
        events.append((t + i * 0.4, f"  \x1b[32m✓\x1b[0m {agent}-reviewer complete\r\n"))
    t += 3.0

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1mVerdict: APPROVED\x1b[0m",
                "",
                "┌────────────────┬─────────┬────┬────┬────┬────┬──────────┐",
                "│ Agent          │ Verdict │ C  │ H  │ M  │ L  │ Coverage │",
                "├────────────────┼─────────┼────┼────┼────┼────┼──────────┤",
                "│ Security       │ OK      │ 0  │ 0  │ 1  │ 2  │ 100%     │",
                "│ Vulnerability  │ OK      │ 0  │ 0  │ 0  │ 1  │ 100%     │",
                "│ Code Quality   │ OK      │ 0  │ 0  │ 2  │ 3  │ 100%     │",
                "│ Documentation  │ OK      │ 0  │ 0  │ 1  │ 2  │ 100%     │",
                "│ User Persona   │ OK      │ 0  │ 0  │ 0  │ 1  │ 100%     │",
                "│ Go             │ OK      │ 0  │ 0  │ 1  │ 2  │ 100%     │",
                "├────────────────┼─────────┼────┼────┼────┼────┼──────────┤",
                "│ Total          │         │ 0  │ 0  │ 5  │ 11 │          │",
                "└────────────────┴─────────┴────┴────┴────┴────┴──────────┘",
                "",
                "\x1b[33mMedium (5):\x1b[0m",
                "  • [SEC] Input validation could be stricter on email field",
                "  • [QUAL] Cyclomatic complexity of 12 in validate.go:45",
                "  • [QUAL] Consider extracting auth logic to separate package",
                "  • [DOC] Missing godoc for exported function Authenticate",
                "  • [GO] Error wrapping could provide more context",
                "",
                "\x1b[2m→ Full report: .claude/consensus-reviews/review-src-auth.md\x1b[0m",
                "",
            ],
            t,
            0.06,
        )
    )
    t += 2.0

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    events.append((t + 0.2, "$ "))

    create_cast_file("fs-dev/consensus-review.cast", events, title="Demo: /consensus-review")


def generate_standup():
    """Generate /standup command recording."""
    events = []
    t = 0.0

    events.append((t, "$ "))
    t += 0.3
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.8

    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3
    events.extend(type_text("/standup", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ Daily Standup: marketplace ═══\x1b[0m",
                "\x1b[2m2026-01-29\x1b[0m",
                "",
                "\x1b[1m📋 Yesterday\x1b[0m",
                "  • Merged PR #31: Plugin documentation overhaul",
                "  • Closed issues #16-21: Documentation epic complete",
                "  • Implemented adaptive budgets for consensus review",
                "",
                "\x1b[1m🎯 Today\x1b[0m",
                "  \x1b[33m▸\x1b[0m #28: Phase 5 Testing (enhancement)",
                "  \x1b[33m▸\x1b[0m #20: Create ASCII recordings (docs)",
                "  \x1b[33m▸\x1b[0m #1: Security hardening (enhancement)",
                "",
                "\x1b[1m🚧 Blockers\x1b[0m",
                "  None identified",
                "",
                "\x1b[1m📊 Stats\x1b[0m",
                "  PRs merged this week: 4",
                "  Issues closed: 12",
                "  Open issues: 3",
                "",
            ],
            t,
            0.1,
        )
    )
    t += 1.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    events.append((t + 0.2, "$ "))

    create_cast_file("fs-dev/standup.cast", events, title="Demo: /standup")


def generate_discover():
    """Generate /discover command recording."""
    events = []
    t = 0.0

    events.append((t, "$ "))
    t += 0.3
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.8

    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3
    events.extend(type_text("/discover --lens security", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ Codebase Discovery: Security Lens ═══\x1b[0m",
                "",
                "\x1b[33m▸\x1b[0m Scanning 135 files...",
            ],
            t,
            0.2,
        )
    )
    t += 1.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1mAuthentication\x1b[0m",
                "  • JWT validation in internal/auth/jwt.go",
                "  • Session management in internal/auth/session.go",
                "  • No hardcoded secrets detected",
                "",
                "\x1b[1mInput Validation\x1b[0m",
                "  • 12 API endpoints analyzed",
                "  • \x1b[33m⚠\x1b[0m  3 endpoints missing input sanitization",
                "  • SQL parameterization: \x1b[32m✓\x1b[0m All queries use prepared statements",
                "",
                "\x1b[1mDependencies\x1b[0m",
                "  • 24 direct dependencies",
                "  • \x1b[32m✓\x1b[0m No known CVEs in current versions",
                "  • Last audit: 2026-01-28",
                "",
                "\x1b[1mSecrets Management\x1b[0m",
                "  • .gitleaks.toml configured",
                "  • Environment variables for sensitive config",
                "  • \x1b[32m✓\x1b[0m No secrets in git history",
                "",
                "\x1b[2m→ Full report: .claude/discoveries/security-2026-01-29.md\x1b[0m",
                "",
            ],
            t,
            0.08,
        )
    )
    t += 2.0

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    events.append((t + 0.2, "$ "))

    create_cast_file("fs-dev/discover.cast", events, title="Demo: /discover --lens security")


# ============================================================================
# contextd Recordings
# ============================================================================


def generate_contextd_status():
    """Generate /contextd:status command recording."""
    events = []
    t = 0.0

    events.append((t, "$ "))
    t += 0.3
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.8

    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3
    events.extend(type_text("/contextd:status", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ contextd Status ═══\x1b[0m",
                "",
                "\x1b[1mConnection\x1b[0m",
                "  Server: \x1b[32m●\x1b[0m Running (localhost:9090)",
                "  Mode: MCP stdio",
                "  Uptime: 4h 23m",
                "",
                "\x1b[1mProject\x1b[0m",
                "  Tenant: fyrsmithlabs",
                "  Project: marketplace",
                "  Indexed: 135 files (48,230 tokens)",
                "",
                "\x1b[1mMemories\x1b[0m",
                "  Total: 47",
                "  This session: 3",
                "  High confidence: 31",
                "",
                "\x1b[1mCheckpoints\x1b[0m",
                "  Available: 5",
                "  Latest: 2026-01-29 10:15 (Documentation overhaul)",
                "",
                "\x1b[1mRemediations\x1b[0m",
                "  Total: 12",
                "  Used this session: 2",
                "",
            ],
            t,
            0.08,
        )
    )
    t += 1.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    events.append((t + 0.2, "$ "))

    create_cast_file("contextd/status.cast", events, title="Demo: /contextd:status")


def generate_contextd_search():
    """Generate /contextd:search command recording."""
    events = []
    t = 0.0

    events.append((t, "$ "))
    t += 0.3
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.8

    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3
    events.extend(type_text("/contextd:search consensus review patterns", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ Search Results ═══\x1b[0m",
                "",
                "\x1b[1mMemories (3 matches)\x1b[0m",
                "",
                "  \x1b[36m[0.92]\x1b[0m Consensus review adaptive budgets",
                "  \x1b[2m2026-01-29 | type:learning\x1b[0m",
                "  Scale factor formula: min(4.0, 1.0 + tokens/16384)",
                "",
                "  \x1b[36m[0.87]\x1b[0m Progressive summarization protocol",
                "  \x1b[2m2026-01-29 | type:pattern\x1b[0m",
                "  Budget thresholds: 80% full, 95% high-severity, 95%+ force",
                "",
                "  \x1b[36m[0.81]\x1b[0m Context isolation for large scopes",
                "  \x1b[2m2026-01-28 | type:decision\x1b[0m",
                "  Use branch_create when scope > 16K tokens",
                "",
                "\x1b[1mCode (2 matches)\x1b[0m",
                "",
                "  \x1b[33mskills/consensus-review/skill.md:45\x1b[0m",
                "  Budget calculation formula and isolation modes",
                "",
                "  \x1b[33mincludes/consensus-review/progressive.md:12\x1b[0m",
                "  Progressive summarization thresholds",
                "",
            ],
            t,
            0.08,
        )
    )
    t += 1.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    events.append((t + 0.2, "$ "))

    create_cast_file("contextd/search.cast", events, title="Demo: /contextd:search")


def generate_contextd_checkpoint():
    """Generate /contextd:checkpoint command recording."""
    events = []
    t = 0.0

    events.append((t, "$ "))
    t += 0.3
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.8

    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3
    events.extend(type_text("/contextd:checkpoint", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ Saving Checkpoint ═══\x1b[0m",
                "",
                "\x1b[33m▸\x1b[0m Analyzing session state...",
            ],
            t,
            0.2,
        )
    )
    t += 1.0

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1mAccomplishments\x1b[0m",
                "  • Merged PR #31: Plugin documentation",
                "  • Closed 6 documentation issues",
                "  • Updated consensus review with adaptive budgets",
                "",
                "\x1b[1mIn Progress\x1b[0m",
                "  • Issue #20: ASCII terminal recordings",
                "",
                "\x1b[1mNext Steps\x1b[0m",
                "  • Generate recordings for all commands",
                "  • Complete Phase 5 testing (#28)",
                "",
                "\x1b[32m✓\x1b[0m Checkpoint saved: \x1b[36mdocs-complete-2026-01-29\x1b[0m",
                "",
            ],
            t,
            0.1,
        )
    )
    t += 1.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    events.append((t + 0.2, "$ "))

    create_cast_file("contextd/checkpoint.cast", events, title="Demo: /contextd:checkpoint")


def generate_contextd_help():
    """Generate /contextd:help command recording."""
    events = []
    t = 0.0

    events.append((t, "$ "))
    t += 0.3
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.8

    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3
    events.extend(type_text("/contextd:help", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ contextd Commands ═══\x1b[0m",
                "",
                "\x1b[1mMemory & Search\x1b[0m",
                "  /contextd:search <query>     Search memories, remediations, code",
                "  /contextd:remember           Record a learning from this session",
                "",
                "\x1b[1mSession Management\x1b[0m",
                "  /contextd:status             Show contextd status",
                "  /contextd:checkpoint         Save session state for later",
                "  /contextd:init               Initialize contextd for project",
                "",
                "\x1b[1mDiagnostics\x1b[0m",
                "  /contextd:diagnose <error>   AI-powered error diagnosis",
                "  /contextd:reflect            Analyze behavior patterns",
                "",
                "\x1b[1mWorkflows\x1b[0m",
                "  /contextd:consensus-review   Multi-agent code review",
                "  /contextd:orchestrate        Multi-task orchestration",
                "",
                "\x1b[2mSee docs/plugins/contextd.md for full documentation\x1b[0m",
                "",
            ],
            t,
            0.06,
        )
    )
    t += 1.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    events.append((t + 0.2, "$ "))

    create_cast_file("contextd/help.cast", events, title="Demo: /contextd:help")


# ============================================================================
# fs-design Recordings
# ============================================================================


def generate_design_check():
    """Generate /fs-design:check command recording."""
    events = []
    t = 0.0

    events.append((t, "$ "))
    t += 0.3
    events.extend(type_text("claude", t))
    t += 0.4
    events.append((t, "\r\n"))
    t += 0.8

    events.extend(
        output_lines(
            [
                "\x1b[1m╭─────────────────────────────────────────╮\x1b[0m",
                "\x1b[1m│\x1b[0m  \x1b[36mClaude Code\x1b[0m v1.0.46                   \x1b[1m│\x1b[0m",
                "\x1b[1m╰─────────────────────────────────────────╯\x1b[0m",
                "",
            ],
            t,
        )
    )
    t += 0.5

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.3
    events.extend(type_text("/fs-design:check static/css/", t))
    t += 0.3
    events.append((t, "\r\n"))
    t += 0.5

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1m═══ Design System Compliance Report ═══\x1b[0m",
                "\x1b[2mTerminal Elegance v2.0.0\x1b[0m",
                "",
                "\x1b[33m▸\x1b[0m Scanning static/css/...",
            ],
            t,
            0.2,
        )
    )
    t += 1.0

    events.extend(
        output_lines(
            [
                "",
                "\x1b[1mSummary\x1b[0m",
                "  Files Scanned: 3",
                "  Violations: 7",
                "    \x1b[31m• Critical: 1\x1b[0m",
                "    \x1b[33m• Error: 3\x1b[0m",
                "    \x1b[34m• Warning: 2\x1b[0m",
                "    \x1b[2m• Info: 1\x1b[0m",
                "",
                "\x1b[1mViolations\x1b[0m",
                "",
                "\x1b[31m[CRITICAL]\x1b[0m static/css/main.css:45",
                "  Hardcoded color: background: #ea580c",
                "  \x1b[2mUse: var(--color-primary)\x1b[0m",
                "",
                "\x1b[33m[ERROR]\x1b[0m static/css/main.css:72",
                "  Hardcoded spacing: padding: 24px",
                "  \x1b[2mUse: var(--space-6)\x1b[0m",
                "",
                "\x1b[33m[ERROR]\x1b[0m static/css/components.css:15",
                "  Hardcoded font-size: font-size: 18px",
                "  \x1b[2mUse: var(--text-lg)\x1b[0m",
                "",
                "\x1b[34m[WARNING]\x1b[0m static/css/main.css:103",
                "  Non-standard z-index: z-index: 999",
                "  \x1b[2mUse: var(--z-modal) or similar\x1b[0m",
                "",
                "\x1b[1mCI Status: \x1b[31mFAIL\x1b[0m (Critical > 0)\x1b[0m",
                "",
            ],
            t,
            0.06,
        )
    )
    t += 2.0

    events.append((t, "\x1b[36m>\x1b[0m "))
    t += 0.5
    events.extend(type_text("/exit", t))
    t += 0.3
    events.append((t, "\r\n"))
    events.append((t + 0.2, "$ "))

    create_cast_file("fs-design/check.cast", events, title="Demo: /fs-design:check")


# ============================================================================
# Main
# ============================================================================

GENERATORS = {
    "fs-dev": {
        "init": generate_init,
        "yagni": generate_yagni,
        "consensus-review": generate_consensus_review,
        "standup": generate_standup,
        "discover": generate_discover,
    },
    "contextd": {
        "status": generate_contextd_status,
        "search": generate_contextd_search,
        "checkpoint": generate_contextd_checkpoint,
        "help": generate_contextd_help,
    },
    "fs-design": {
        "check": generate_design_check,
    },
}


def main():
    args = sys.argv[1:]

    if "--list" in args:
        print("\nAvailable recordings:\n")
        for plugin, commands in GENERATORS.items():
            print(f"  {plugin}:")
            for cmd in commands:
                print(f"    - {cmd}")
        print()
        return

    if len(args) == 0 or args[0] == "all":
        plugins = GENERATORS.keys()
    else:
        plugins = [args[0]]

    print("\nGenerating recordings...")
    print()

    for plugin in plugins:
        if plugin not in GENERATORS:
            print(f"Unknown plugin: {plugin}")
            continue

        print(f"{plugin}:")
        for name, generator in GENERATORS[plugin].items():
            generator()
        print()

    print("Done!")
    print("\nTo play a recording:")
    print("  asciinema play docs/recordings/<plugin>/<command>.cast")
    print()


if __name__ == "__main__":
    main()
