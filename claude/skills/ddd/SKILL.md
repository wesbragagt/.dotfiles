---
name: ddd
description: Domain-Driven Design + Ports & Adapters (Hexagonal Architecture) implementation guide. Use this skill whenever the user invokes /ddd, asks to build a feature using DDD, wants to model a domain, design bounded contexts, implement hexagonal architecture, or review code for DDD compliance. Also trigger when the user mentions entities, value objects, aggregates, repositories, domain events, use cases, ports, adapters, or composition root in an architectural context.
---

# Domain-Driven Design + Ports & Adapters

## Step 1: Enter Plan Mode — Clarify the Domain

Before writing any code, enter plan mode and ask the following questions. Do not skip this. The answers shape every decision downstream.

**Ask the user:**

1. **Ubiquitous language** — What terms does the business use? List the key nouns (e.g. "Order", "Shipment", "Customer") and verbs ("place", "fulfill", "cancel"). These become class and method names verbatim.
2. **Bounded context** — What is the scope of this feature? Is it a new context or extending an existing one?
3. **Subdomain type** — Is this core (competitive differentiator), supporting (necessary but not differentiating), or generic (standard problem like auth/billing)?
4. **Entities vs value objects** — For each key noun: does it need a unique identity that persists over time, or is it defined entirely by its attributes?
5. **Invariants** — What business rules must never be violated? (e.g. "an order cannot be confirmed without items", "balance cannot go negative")
6. **External dependencies** — What does this feature need from the outside world? (DBs, APIs, email, message queues)

Do not proceed until you have answers to at least 1, 4, and 5. When in doubt, ask — bad naming at this stage poisons the entire codebase.

---

## Step 2: TDD-First Implementation Order

Follow red-green-refactor. One behavior at a time, vertical slices only.

```
For each behavior:
  RED:   Write test using public interface → fails
  GREEN: Minimal code to pass → passes
  (repeat before refactoring)

After all behaviors pass:
  REFACTOR: extract duplication, deepen modules, clean up
```

**Implementation sequence** (always in this order):

1. Domain models (entities, value objects, aggregates) — pure, no infra
2. Domain events
3. Outbound ports (repository interfaces, external service interfaces)
4. Inbound ports (use case interfaces)
5. Application service implementing inbound ports
6. Adapters (in-memory first for tests, then real infra)
7. Composition root

Write tests for steps 1–5 before implementing adapters. Real infra adapters get integration tests separately.

---

## Architecture Rules

### Directory structure

```
src/
├── domain/          ← pure business logic, zero infra imports
│   ├── models/      ← entities, value objects, aggregates
│   ├── events/      ← domain events (past tense names)
│   └── services/    ← stateless domain services
├── ports/
│   ├── input/       ← use case interfaces (inbound)
│   └── output/      ← repo/external service interfaces (outbound)
├── adapters/
│   ├── input/       ← REST, CLI, consumers — thin glue only
│   └── output/      ← DB, external APIs, email
└── config/          ← composition root, DI wiring only
```

### Dependency rule

**Dependencies point inward only.**

```
adapters → ports → domain
```

Domain never imports from adapters, ports, frameworks, ORMs, or HTTP libs. If you find yourself writing `import FastAPI` or `import SQLAlchemy` inside `domain/`, stop — that code belongs in an adapter.

---

## Tactical Patterns

### Value Object

No identity. Defined entirely by attributes. Immutable. Self-validating. Compared by value.

- Python: `@dataclass(frozen=True)`, validate in `__post_init__`
- TypeScript: private constructor + static factory method, validate in constructor
- Operations return **new instances**, never mutate
- Reject invalid state at construction — an invalid value object must never exist

Use for: Money, Email, Address, PhoneNumber, DateRange, Quantity, any typed ID.

**Decision**: if two instances with identical attributes are interchangeable to the business → Value Object. If the business cares *which specific one* it is → Entity.

### Entity

Distinct UUID identity. Mutable attributes. Enforces its own invariants. Equality by ID.

- Guard state transitions behind methods (not public setters)
- Methods should throw/raise on invalid transitions with domain language errors

### Aggregate

Consistency boundary. One aggregate root. All external access goes through the root.

- Cross-aggregate references: by ID only, never by object reference
- One transaction modifies one aggregate
- Aggregates raise domain events; they do not dispatch them

### Domain Event

Something that happened. Named in past tense (`OrderPlaced`, `PaymentFailed`). Carries the data consumers need. Aggregates raise events; handlers consume them. The aggregate is unaware of handlers.

### Repository (Outbound Port)

Interface lives in `ports/output/`. Named by domain concept: `OrderRepository`, not `PostgresOrderRepository`.

Methods reflect domain intent: `save`, `find_by_id`, `find_by_customer`. Never expose query builders or ORM sessions.

Implementation lives in `adapters/output/`. Test with in-memory fake first.

### Application Service (Inbound Port Implementation)

Orchestrates only. No business logic.

```
load aggregate from repo
→ call domain method
→ save aggregate
→ dispatch events
```

If you find an `if` statement encoding a business rule here, move it to the domain.

### Adapter (Input/Output)

Input adapters: parse HTTP/CLI/message input → call inbound port → format response. No business logic. Return DTOs, not domain objects.

Output adapters: implement outbound ports. Own all serialization, wire formats, tech-specific concerns. Translate domain model ↔ persistence model.

### Composition Root

Single place where adapters are wired to ports. Domain never constructs its own dependencies.

---

## Type Safety

- Use distinct types for domain IDs — never raw `str`/`int` where a typed ID is expected
- Use enums or union types for status/state fields — never raw strings
- Structured types (dataclasses, typed dicts, interfaces) cross layer boundaries — never raw dicts/maps
- Explicit failure paths in return types where failure is expected — exceptions for truly exceptional cases

---

## Testing Strategy

| Layer | Test type | Infrastructure |
|---|---|---|
| Domain models | Unit | None — pure Python/TS |
| Application services | Unit | Mock outbound ports only |
| Adapters | Integration | Real infra (DB, API) |
| Entrypoints | Smoke | Thin wiring check |

Mock only at port boundaries. Never mock inside the domain. Domain tests need zero infrastructure — if a domain test requires a database, the boundary is wrong.

**Fitness function** (add to CI): assert that no file under `domain/` imports from `adapters/` or any framework package.

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Framework import in domain | Move to adapter |
| Business logic in controller | Move to domain method or application service |
| Cross-aggregate object reference | Reference by ID only |
| Raw string for Email/Money/status | Wrap in value object or enum |
| One model for the whole system | Decompose into bounded contexts |
| Domain object returned from API | Return a DTO |
| Port named `DataService` or `GenericRepo` | Name by business intent: `OrderRepository` |
| Aggregate calling external service directly | Inject outbound port; call via port |

---

## When to Apply (and When Not To)

**Apply when**: complex business rules, multiple invariants, need to swap infra, long-lived system, parallel teams.

**Skip or simplify when**: simple CRUD, short-lived prototype, thin wrapper over a DB, team is small and domain is trivial.
