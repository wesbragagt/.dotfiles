# React Server Components: A Comprehensive Guide

## What Are React Server Components?

React Server Components (RSC) are a new component model introduced by the React team that allows components to render exclusively on the server. Unlike traditional Server-Side Rendering (SSR), RSC is not just about rendering HTML on the server — it introduces a fundamentally different execution model where certain components never ship their code to the browser at all.

RSC was introduced experimentally in 2020 and became stable with React 19 (released in late 2024), with Next.js 13+ (App Router) being the primary framework adopter.

---

## How React Server Components Work

### The Two-World Model

RSC introduces a clear split between two types of components:

- **Server Components**: Rendered on the server, never hydrated on the client. Their code is never sent to the browser.
- **Client Components**: Traditional React components that run in the browser (and optionally SSR'd). Marked with `"use client"` directive.

### The RSC Protocol and Render Pipeline

When a request comes in, here is what happens:

1. **Server renders the component tree**: Starting from the root, React traverses the component tree on the server. Server Components execute — they can fetch data, read files, access databases, etc.

2. **RSC Payload generation**: Instead of outputting raw HTML, the server serializes the rendered output into a special wire format called the **RSC Payload** (a compact JSON-like stream). This payload describes the virtual DOM tree produced by server components, with placeholders for Client Component boundaries.

3. **Client Components are bundled separately**: When React encounters a `"use client"` boundary, it stops server rendering at that point and includes a reference to the Client Component bundle. The Client Component itself is not rendered server-side at this point in the RSC model (though frameworks can SSR them separately).

4. **Streaming**: The RSC payload can be streamed to the client progressively using React's `Suspense` integration. The browser can start rendering immediately without waiting for the entire payload.

5. **Hydration**: On the client, React reconstructs the tree using the RSC payload. Client Components are hydrated with interactivity. Server Component output is treated as static — React does not re-render them on the client.

6. **Subsequent navigation**: On client-side navigation, Next.js fetches a new RSC payload from the server (not a full page reload), merges it into the existing client tree, and only re-renders what changed.

### The RSC Wire Format

The RSC payload is a newline-delimited JSON stream. Each line represents a piece of the component tree. It looks roughly like:

```
0:["$","div",null,{"children":["$","h1",null,{"children":"Hello"}]}]
1:["$","p",null,{"children":"World"}]
```

This format is not HTML — it is React's internal virtual DOM representation, which allows the client to reconstruct the tree and apply updates surgically.

### Boundaries and the "use client" Directive

- **`"use client"`**: Marks a file as a Client Component boundary. Everything exported from that file (and its subtree) runs on the client. This directive must be at the top of the file.
- **`"use server"`**: Marks Server Actions — functions that run on the server but can be called from the client (used in forms and mutations).
- There is no `"use server"` directive for components — server rendering is the default in RSC-enabled frameworks.

### What Server Components Can Do

- Access server-side resources directly: databases, file system, environment variables, secrets
- Import large dependencies without increasing client bundle size
- Perform async data fetching with `async/await` directly in the component body
- Use Node.js APIs
- Read cookies, headers (via framework APIs)

### What Server Components Cannot Do

- Use React hooks (`useState`, `useEffect`, `useRef`, etc.)
- Use browser APIs (`window`, `document`, `localStorage`, etc.)
- Attach event handlers (`onClick`, `onChange`, etc.)
- Use Context (as providers — they can read some contexts set up by framework layers)
- Be interactive in any way post-render

---

## Server Components vs Client Components: When to Use Each

### Use Server Components When

1. **Fetching data**: Data fetching directly in the component eliminates prop drilling and waterfall issues. The component renders with the data already available.
   ```tsx
   // Server Component — no useEffect, no loading state needed
   async function ProductList() {
     const products = await db.query('SELECT * FROM products');
     return <ul>{products.map(p => <li key={p.id}>{p.name}</li>)}</ul>;
   }
   ```

2. **Accessing backend resources securely**: Database credentials, API keys, and internal services never leave the server.

3. **Reducing client bundle size**: Heavy dependencies like markdown parsers, date libraries, syntax highlighters, or data transformation utilities stay on the server.
   ```tsx
   // 'marked' library (~50KB) never ships to browser
   import { marked } from 'marked';
   async function BlogPost({ slug }) {
     const post = await getPost(slug);
     return <div dangerouslySetInnerHTML={{ __html: marked(post.content) }} />;
   }
   ```

4. **Static or non-interactive UI**: Navigation bars, footers, article content, product descriptions, layout components that never change after render.

5. **Layout and structural components**: App shells, sidebars, headers — components that compose the page structure but have no interactivity.

6. **SEO-sensitive content**: Server-rendered content is immediately available to crawlers without JavaScript execution.

### Use Client Components When

1. **Interactivity**: Anything with `onClick`, `onChange`, `onSubmit`, or other event handlers.

2. **React state**: Components using `useState`, `useReducer`, or any stateful logic.

3. **Side effects**: `useEffect`, `useLayoutEffect`, `useInsertionEffect`.

4. **Browser APIs**: Accessing `window`, `navigator`, `localStorage`, `IntersectionObserver`, etc.

5. **Custom hooks** that use any of the above.

6. **Real-time features**: WebSockets, polling, live updates.

7. **Animations and transitions**: Libraries like Framer Motion, React Spring require client execution.

8. **Third-party components**: Most existing React component libraries (`react-select`, `recharts`, chart.js wrappers, etc.) are Client Components by default.

### The Composition Pattern

A powerful pattern is composing Server and Client Components together:

```tsx
// page.tsx — Server Component
import InteractiveWidget from './InteractiveWidget'; // Client Component

async function Page() {
  const data = await fetchData(); // server-side fetch
  return (
    <div>
      <StaticContent data={data} /> {/* Server Component */}
      <InteractiveWidget initialData={data} /> {/* Client Component */}
    </div>
  );
}
```

You can also pass Server Component output as `children` into Client Components:

```tsx
// ClientShell.tsx — "use client"
export function ClientShell({ children }) {
  const [open, setOpen] = useState(false);
  return <div onClick={() => setOpen(!open)}>{children}</div>;
}

// page.tsx — Server Component
import { ClientShell } from './ClientShell';
async function Page() {
  const data = await fetchData();
  return (
    <ClientShell>
      <ServerRenderedContent data={data} /> {/* stays as server component! */}
    </ClientShell>
  );
}
```

This is a critical pattern: passing server-rendered JSX as `children` to a Client Component keeps that JSX server-rendered. The Client Component does not re-render the children on the client — it only manages its own state.

---

## Framework Support

### Next.js (App Router) — Primary Production Implementation

Next.js 13+ with the App Router is the most mature RSC implementation:

- All components in the `app/` directory are Server Components by default
- Client Components require `"use client"` at the top of the file
- Supports streaming with `Suspense`
- `loading.tsx` maps to automatic Suspense boundaries
- `error.tsx` for error boundaries
- Server Actions via `"use server"` directive for mutations
- Route Handlers for API endpoints

The Pages Router (`pages/`) does NOT support RSC — it uses the traditional `getServerSideProps`/`getStaticProps` model.

### Remix

Remix does not use the RSC model. It uses a loader/action pattern (`loader` and `action` functions) for server-side data. All components are Client Components by default with optional SSR. Remix's model is conceptually similar but architecturally distinct from RSC.

### Expo / React Native

React Native support for RSC is experimental (as of 2024-2025). The Expo team has been working on RSC support, but it is not production-ready for most use cases.

### Standalone React (without Next.js)

Using RSC without a framework is technically possible but extremely complex:
- Requires a custom server with the `react-server-dom-webpack` or `react-server-dom-vite` packages
- You must implement the RSC router, bundler integration, and streaming yourself
- The React team has indicated RSC is intended to be adopted through frameworks

### Vite-based frameworks

Tools like **Waku** (by the Zustand/Jotai creator) implement RSC with Vite. TanStack Start has experimental RSC support. Astro uses a similar "island" model but with its own architecture distinct from RSC.

---

## Performance Implications

### Bundle Size Reduction

Server Components can dramatically reduce JavaScript sent to the browser. A component tree that previously included heavy dependencies now only sends the rendered output, not the code to produce it.

Example: A blog with syntax highlighting using `prism.js` (~100KB) — in RSC, `prism.js` runs only on the server, never shipped to the browser.

### Waterfall Elimination

Traditional client-side data fetching creates request waterfalls:
```
Client renders → useEffect fires → fetch A → fetch B (depends on A) → render
```

With RSC:
```
Server renders → fetches A and B in parallel → sends complete HTML/RSC payload
```

React's `cache()` function allows deduplicating server-side fetches within a render.

### Streaming and Time to First Byte

RSC with Suspense allows the server to stream the response. Critical content renders immediately, slower data-dependent sections stream in as they resolve. This improves perceived performance without blocking the full page.

### Hydration Cost

Traditional SSR hydrates the entire page (React re-processes all the HTML to attach event listeners). With RSC, only Client Components hydrate. Large sections of server-rendered content have zero hydration cost, reducing Time to Interactive.

---

## Gotchas and Common Pitfalls

### 1. Serialization Constraints

Props passed from Server Components to Client Components must be serializable. You cannot pass:
- Functions (except Server Actions)
- Class instances
- Dates (use ISO strings instead)
- `Map`, `Set` (use arrays/objects)
- `undefined` (use `null`)
- React elements that reference server-only values

```tsx
// WRONG — functions are not serializable
<ClientButton onClick={() => serverOnlyFunction()} />

// RIGHT — use Server Actions for server-side mutations
<ClientButton action={serverAction} />
```

### 2. "use client" Propagates Down, Not Up

Once you mark a file `"use client"`, all imports within that file also become client-side. This means if a Server Component file imports a Client Component that imports a server-only library, it breaks.

The solution: keep server-only code in separate files and use the `server-only` package to enforce this.

```tsx
import 'server-only'; // throws if imported in a client context
```

### 3. Context Does Not Cross Server/Client Boundary

React Context cannot be created in a Server Component and consumed in a Client Component. Context is a client-side concept. For server-to-client data passing, use props or URL state.

### 4. Third-Party Library Compatibility

Many popular React libraries were built before RSC and assume a browser environment. They use `window`, `document`, or hooks at module level. Solutions:
- Wrap them in a Client Component boundary
- Use `dynamic(() => import('./Component'), { ssr: false })` in Next.js for browser-only components
- Check if the library has been updated for RSC compatibility

### 5. Cookies and Headers Timing

In Next.js App Router, `cookies()` and `headers()` are dynamic functions that opt the route out of static generation. Calling them makes the route fully dynamic (server-rendered per request), which has performance implications.

### 6. No Shared State Between Server and Client (Without Passing Props)

Server Components cannot read client state (e.g., Redux store, Zustand store). If you need server components to respond to client state, you typically encode that state in the URL and trigger a navigation/revalidation.

### 7. async/await in Components Requires React 19

The ability to use `async/await` directly in Server Components (not just in route handlers) became stable with React 19. Older React 18 setups had this as experimental. Make sure your React version supports it.

### 8. Stale Closures and Server Actions

Server Actions (`"use server"`) capture variables from their enclosing scope at render time. Be careful about what data is captured — it is serialized and sent as part of the action payload, which has security implications (avoid capturing sensitive data in closures that become Server Actions).

### 9. Dev vs Production Differences

RSC behavior can differ between development and production builds. In development, Next.js may skip certain optimizations. Always test production builds for performance-sensitive RSC scenarios.

### 10. Over-segmentation Anti-pattern

A common mistake is adding `"use client"` too broadly, negating RSC benefits. The goal is to push `"use client"` as far down the component tree as possible — wrapping only the interactive leaf nodes, not entire pages or layouts.

---

## Mental Model Summary

Think of RSC as splitting your React application into two layers:

| Concern | Server Component | Client Component |
|---|---|---|
| Data fetching | Direct (async/await) | Hooks (useEffect, SWR, React Query) |
| Secrets/credentials | Safe to use | Never use |
| Bundle contribution | Zero JS to browser | Included in JS bundle |
| Interactivity | None | Full (hooks, events) |
| Re-renders | Server-triggered only | Client-triggered + server-triggered |
| Dependencies | Stay on server | Shipped to browser |

The default should be: **start with Server Components, add `"use client"` only when you need interactivity or browser APIs**. This is the opposite of the old mental model where everything was a component that happened to also SSR.

---

## Quick Decision Guide

```
Does this component need:
  - onClick / onChange / event handlers?       → Client Component
  - useState / useReducer?                     → Client Component
  - useEffect / useLayoutEffect?               → Client Component
  - browser APIs (window, localStorage)?       → Client Component
  - real-time / WebSocket updates?             → Client Component
  - animation libraries (Framer Motion)?       → Client Component

  - database / file system access?             → Server Component
  - environment secrets / API keys?            → Server Component
  - heavy dependencies (reduce bundle)?        → Server Component
  - static/non-interactive display?            → Server Component
  - async data fetching at render time?        → Server Component
  - SEO-critical content?                      → Server Component
```

---

## Further Reading

- [React Docs: Server Components](https://react.dev/reference/rsc/server-components)
- [Next.js App Router Docs](https://nextjs.org/docs/app)
- [React RFC: Server Components](https://github.com/reactjs/rfcs/blob/main/text/0188-server-components.md)
- [Dan Abramov's RSC explanation](https://github.com/reactwg/server-components/discussions/5)
