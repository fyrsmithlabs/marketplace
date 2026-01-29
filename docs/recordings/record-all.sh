#!/bin/bash
# Recording script for marketplace commands
#
# This script provides template commands for recording each marketplace command.
# Recordings require human interaction with Claude Code - run each command
# manually in an interactive session.
#
# Usage:
#   ./docs/recordings/record-all.sh           # Show all recording commands
#   ./docs/recordings/record-all.sh fs-dev    # Show only fs-dev commands
#   ./docs/recordings/record-all.sh contextd  # Show only contextd commands
#   ./docs/recordings/record-all.sh fs-design # Show only fs-design commands

set -e

RECORDINGS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}$1${RESET}"
    echo -e "${DIM}$(printf '%.0s─' {1..60})${RESET}"
}

print_command() {
    local cmd=$1
    local desc=$2
    local file=$3
    echo -e "  ${GREEN}$cmd${RESET}"
    echo -e "  ${DIM}$desc${RESET}"
    echo -e "  ${YELLOW}asciinema rec -t \"Demo: $cmd\" --idle-time-limit 2 $file${RESET}"
    echo ""
}

show_fs_dev() {
    print_header "fs-dev Commands (11)"

    print_command "/init" \
        "Project setup wizard - creates CLAUDE.md, applies standards" \
        "$RECORDINGS_DIR/fs-dev/init.cast"

    print_command "/yagni" \
        "YAGNI settings management - enable/disable/status" \
        "$RECORDINGS_DIR/fs-dev/yagni.cast"

    print_command "/plan" \
        "Full planning workflow - complexity assessment, GitHub issues" \
        "$RECORDINGS_DIR/fs-dev/plan.cast"

    print_command "/standup" \
        "Daily standup - GitHub synthesis, priorities" \
        "$RECORDINGS_DIR/fs-dev/standup.cast"

    print_command "/test-skill" \
        "Skill pressure testing - run tests against skills" \
        "$RECORDINGS_DIR/fs-dev/test-skill.cast"

    print_command "/discover" \
        "Codebase analysis - architecture, patterns, dependencies" \
        "$RECORDINGS_DIR/fs-dev/discover.cast"

    print_command "/brainstorm" \
        "Feature design workflow - ideation, constraints, trade-offs" \
        "$RECORDINGS_DIR/fs-dev/brainstorm.cast"

    print_command "/consensus-review" \
        "Multi-agent code review - security, quality, docs reviewers" \
        "$RECORDINGS_DIR/fs-dev/consensus-review.cast"

    print_command "/app-interview" \
        "Application interview - gather requirements interactively" \
        "$RECORDINGS_DIR/fs-dev/app-interview.cast"

    print_command "/comp-analysis" \
        "Competitive analysis - analyze competing solutions" \
        "$RECORDINGS_DIR/fs-dev/comp-analysis.cast"

    print_command "/spec-refinement" \
        "Specification refinement - improve and clarify specs" \
        "$RECORDINGS_DIR/fs-dev/spec-refinement.cast"
}

show_contextd() {
    print_header "contextd Commands (10)"

    print_command "/contextd:search" \
        "Semantic memory search - find relevant past learnings" \
        "$RECORDINGS_DIR/contextd/search.cast"

    print_command "/contextd:remember" \
        "Record session learnings - capture insights to memory" \
        "$RECORDINGS_DIR/contextd/remember.cast"

    print_command "/contextd:checkpoint" \
        "Save session state - create restoration point" \
        "$RECORDINGS_DIR/contextd/checkpoint.cast"

    print_command "/contextd:diagnose" \
        "Error analysis with AI - troubleshoot issues" \
        "$RECORDINGS_DIR/contextd/diagnose.cast"

    print_command "/contextd:status" \
        "Show contextd status - connection, stats" \
        "$RECORDINGS_DIR/contextd/status.cast"

    print_command "/contextd:init" \
        "Initialize contextd - set up for project" \
        "$RECORDINGS_DIR/contextd/init.cast"

    print_command "/contextd:reflect" \
        "Pattern analysis - analyze behavior, improve" \
        "$RECORDINGS_DIR/contextd/reflect.cast"

    print_command "/contextd:consensus-review" \
        "Multi-agent review with memory - contextd-enhanced review" \
        "$RECORDINGS_DIR/contextd/consensus-review.cast"

    print_command "/contextd:orchestrate" \
        "Multi-task execution - parallel agent orchestration" \
        "$RECORDINGS_DIR/contextd/orchestrate.cast"

    print_command "/contextd:help" \
        "List commands - quick reference" \
        "$RECORDINGS_DIR/contextd/help.cast"
}

show_fs_design() {
    print_header "fs-design Commands (1)"

    print_command "/fs-design:check" \
        "Design system audit - check compliance, report violations" \
        "$RECORDINGS_DIR/fs-design/check.cast"
}

show_instructions() {
    echo ""
    echo -e "${BOLD}Recording Instructions${RESET}"
    echo ""
    echo "1. Install asciinema:"
    echo "   brew install asciinema    # macOS"
    echo "   pip install asciinema     # Linux/pip"
    echo ""
    echo "2. Copy a recording command from above"
    echo ""
    echo "3. Run the command to start recording"
    echo ""
    echo "4. In the recording session:"
    echo "   a. Run: claude"
    echo "   b. Execute the command (e.g., /init)"
    echo "   c. Demonstrate typical usage"
    echo "   d. Exit claude"
    echo "   e. Press Ctrl+D to stop recording"
    echo ""
    echo "5. Verify the recording:"
    echo "   asciinema play <recording-file>.cast"
    echo ""
    echo "6. Update CHECKLIST.md to mark as complete"
    echo ""
}

# Main
case "${1:-all}" in
    fs-dev)
        show_fs_dev
        ;;
    contextd)
        show_contextd
        ;;
    fs-design)
        show_fs_design
        ;;
    all|*)
        show_fs_dev
        show_contextd
        show_fs_design
        show_instructions
        ;;
esac
