# Research: React Server Components — How They Work and When to Use Them

## How RSC Works Internally

React Server Components (RSC) are a rendering primitive introduced in React 19 that execute **once on the server**, before any JavaScript is sent to the browser. They are not the same as SSR — they are a distinct model.

### The Rendering Pipeline

1. The server runs your Server Component tree (async function components that can `await` directly).
2. React serializes the output into the **RSC Payload** — a streaming, line-based wire format called **React Flight**.
3. The payload is streamed to the client progressively (not as one big blob).
4. The client-side React runtime reads the payload and performs normal reconciliation against the existing DOM — without re-running the server components.

### The React Flight Wire Format

The RSC payload is a text-based stream that encodes:
- **Component trees** rendered from Server Components (encoded as `$` entries)
- **Module references** for Client Components (encoded as `I` entries — these are JS bundle references, not the actual components)
- **Hints** (`HL`) for preloading resources like CSS and fonts
- **Props** passed from Server Components down to Client Components (must be serializable)

This means the client never receives the Server Component's source code or implementation — only its rendered output plus pointers to any Client Components that need to be hydrated.

### Streaming and Suspense

Next.js (the primary framework) splits the RSC payload into chunks. Suspended subtrees stream in as their data resolves. The page shell renders immediately; deferred content replaces `<Suspense>` fallbacks progressively. This is fundamentally different from traditional SSR where the entire page waits for all data before sending HTML.

---

## The Server/Client Boundary

### "use client" is a Module Boundary, Not a Component Property

When you add `"use client"` to a file, you are drawing a line in the **module dependency graph**. Everything imported by that file — transitively — becomes part of the client bundle. The directive doesn't make a single component interactive; it marks a subtree boundary.

### You Cannot Import Server Components into Client Components

Server Components can only render during a server pass. If a Client Component imported a Server Component, React would have no way to re-execute it during client re-renders. This is a hard constraint.

### The Children/Slot Pattern Bypasses This Constraint

The standard workaround: pass Server Components **as props** (commonly `children`) to Client Components. The Server Component renders on the server; the Client Component receives already-rendered JSX — not a live component reference. This is the primary composition pattern for mixing the two.

```tsx
// Layout.tsx (Server Component)
import Modal from './Modal'        // Client Component
import Cart from './Cart'          // Server Component

export default function Layout() {
  return (
    <Modal>
      <Cart />   {/* Renders on server, passed as children to Modal */}
    </Modal>
  )
}
```

---

## Data Fetching Patterns

### Server Components Can Fetch Directly

Because Server Components are async functions, you can `await` database queries, `fetch()` calls, or any Node.js API directly in the component body — no `useEffect`, no loading state boilerplate:

```tsx
async function ProductList() {
  const products = await db.query('SELECT * FROM products')
  return <ul>{products.map(p => <li key={p.id}>{p.name}</li>)}</ul>
}
```

### The Waterfall Problem Still Exists

When Server Components are nested and each awaits its own data, they create **server-side fetch waterfalls**: child components cannot fetch until their parent finishes. This is the same problem that existed on the client, just moved to the server.

**Solutions:**

- **Parallel fetch at the top**: Use `Promise.all` to kick off multiple fetches simultaneously before rendering children.
- **React 19 `cache()`**: Wrap fetch functions in `cache()` so deeply nested components can call the same function — React deduplicates the actual network/DB call.
- **Suspense boundaries**: Wrap independent data-loading subtrees in `<Suspense>` so they can resolve in parallel and stream independently, rather than blocking the whole page.

### Recommended Pattern

Fetch data as close to where it's used as possible (co-location), but use `cache()` to prevent duplicate requests when multiple components need the same data. Avoid lifting all fetches to a root layout just to avoid waterfalls — that creates unnecessary coupling.

---

## When to Use Server Components

### Default: Use Server Components Unless You Need Client Features

The React team's recommended default: **start with Server Components, opt into Client Components only when needed**.

### Use Server Components When

- Fetching data from a database, CMS, or internal API (no client credentials exposed)
- Rendering content that doesn't need interactivity (articles, product pages, dashboards)
- Heavy dependencies (markdown parsers, data formatting libraries) that shouldn't ship to the browser
- SEO-critical content where full server-rendered HTML matters
- You want to reduce client bundle size — Server Components add zero JS to the bundle

### Use Client Components When

- Using React hooks: `useState`, `useReducer`, `useEffect`, `useRef`, `useContext`
- Responding to user events (clicks, input, form submission)
- Accessing browser APIs: `localStorage`, `sessionStorage`, `window`, `document`
- Using third-party libraries that depend on browser APIs or lifecycle hooks
- Animations and transitions driven by client-side state

### Hard Limitations of Server Components

| Feature | Available in RSC? |
|---|---|
| `useState` / `useReducer` | No |
| `useEffect` / `useLayoutEffect` | No |
| `useContext` (reading) | No (context not supported) |
| Browser APIs | No |
| Event handlers (`onClick`, etc.) | No |
| Direct DB / filesystem access | Yes |
| `async`/`await` in component body | Yes |
| Access to request headers/cookies | Yes (via framework APIs) |

---

## Real-World Usage and Ecosystem Status

### Framework Support (as of early 2026)

- **Next.js (App Router)**: Only production-ready RSC implementation. App Router defaults all components to Server Components.
- **React Router v7 / Remix**: RSC support arriving but not yet fully stable.
- **TanStack Start**: RSC adoption planned.
- **Vite / plain React**: Possible but requires significant manual setup (webpack plugin, custom server).

### Observed Production Benefits

- E-commerce teams have reported 40%+ improvements in page load times after migrating listing pages to RSC.
- Elimination of client-side data fetching waterfalls (moving them server-side where they're faster to resolve).
- Significant JS bundle reduction — large rendering-only libraries (e.g., syntax highlighters, date formatters) no longer ship to the browser.

### Common Gotchas

1. **Context doesn't work in Server Components** — you cannot use `React.createContext` / `useContext` in a Server Component. Wrap context providers in a Client Component and pass server-rendered children through.
2. **Props must be serializable** — you cannot pass functions, class instances, or non-serializable values from a Server Component to a Client Component as props.
3. **"use client" is viral** — marking one file as a client component pulls all its imports into the client bundle. Keep the boundary as deep/narrow as possible.
4. **Third-party libraries** — many libraries still assume a browser environment. You may need to wrap them in Client Components or lazy-load them.
5. **Mental model shift** — the component tree is now split across two environments. Debugging requires understanding which environment a component runs in.
6. **Adoption is still early** — only ~29% of developers have used Server Components as of 2025, despite broad positive sentiment.

---

## Key Takeaways

- RSC renders on the server, serializes output as the React Flight wire format, and streams it to the client — the client never runs Server Component code.
- The `"use client"` directive marks a **module graph boundary**, not just a single component — everything downstream becomes client JavaScript.
- Use the **children/slot pattern** to compose Server Components inside Client Components while keeping server rendering intact.
- **Default to Server Components**; reach for `"use client"` only when you need hooks, event handlers, or browser APIs.
- Server-side fetch waterfalls are a real risk — use `Promise.all`, React 19's `cache()`, and `<Suspense>` boundaries to keep data fetching parallel.
- **Next.js App Router** is the only mature, production-ready way to use RSC today; other frameworks are catching up.

---

## Sources and Further Reading

- [React official docs: Server Components](https://react.dev/reference/rsc/server-components)
- [React official docs: 'use client' directive](https://react.dev/reference/rsc/use-client)
- [RSC From Scratch — Dan Abramov (reactwg)](https://github.com/reactwg/server-components/discussions/5)
- [The Forensics of React Server Components — Smashing Magazine](https://www.smashingmagazine.com/2024/05/forensics-react-server-components/)
- [How React Server Components Work — Plasmic Blog](https://www.plasmic.app/blog/how-react-server-components-work)
- [Making Sense of React Server Components — Josh W. Comeau](https://www.joshwcomeau.com/react/server-components/)
- [5 Misconceptions about React Server Components — Builder.io](https://www.builder.io/blog/nextjs-react-server-components)
- [Next.js: Server and Client Composition Patterns](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns)
- [Next.js: Data Fetching Patterns and Best Practices](https://nextjs.org/docs/14/app/building-your-application/data-fetching/patterns)
- [Avoiding Server Component Waterfall Fetching with React 19 cache()](https://aurorascharff.no/posts/avoiding-server-component-waterfall-fetching-with-react-19-cache/)
- [React Server Components: the Good, the Bad, and the Ugly — mayank.co](https://mayank.co/blog/react-server-components/)
- [Understanding React Server Components — Vercel](https://vercel.com/blog/understanding-react-server-components)
- [React Server Components in Production — Growin](https://www.growin.com/blog/react-server-components/)
