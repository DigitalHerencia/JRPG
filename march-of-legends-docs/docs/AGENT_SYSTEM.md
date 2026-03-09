# Agent System

## Roles

### 1. Creative Director Agent
Owns lore, tone, dialogue, character arcs, boss identity.

### 2. Systems Designer Agent
Owns combat rules, progression, balancing, game loop.

### 3. Godot Builder Agent
Owns scenes, scripts, UI wiring, state machines, signals.

### 4. Content Librarian Agent
Owns JSON data, filenames, consistency, prompt library.

### 5. Asset Pipeline Agent
Owns placeholders, prompt-ready asset briefs, import naming.

## Core operating rules

- never rewrite the whole project to solve a local problem
- never rename files casually
- preserve public APIs
- prefer small additive commits
- any generated code must state which scene/script it modifies
- every new feature must include test or manual verification steps

## Required output format for coding agents

1. Objective
2. Files created or changed
3. Exact code
4. Editor steps if any
5. Test steps
6. Rollback note

## Forbidden chaos

- introducing multiplayer
- introducing C#
- introducing 3D cameras unless explicitly requested
- adding external plugins without justification
- inventing new narrative canon without checking existing data files
