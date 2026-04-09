### React Server Components

- **RSC** are components that run exclusively on the server, rendering to an RSC payload (not HTML), never shipping JavaScript to the client
- **Use Server Components** for: data fetching (direct DB access), server-only resources (env vars, secrets), heavy dependencies (markdown parsers), static/SEO content, layouts
- **Use Client Components** (`'use client'`) for: React hooks (useState, useEffect), event handlers, browser APIs, animations, client-only libraries
- **Mental model**: Server Components = HTML generators that fetch data. Client Components = JavaScript widgets that handle interactivity
- **Performance**: Pages with 70% static content ship zero JS for that 70%. Typical result: ~500KB bundles down to ~150KB with faster TTFB

**Common Gotchas**
- Don't make everything a client component by default
- Don't place `'use client'` too high in the tree (bloats bundle)
- Can't pass functions as props from server to client (not serializable)
- A server component can render a client component, but never the reverse

**Best Practices**: Default to Server Components. Push client boundaries deep. Use Suspense for streaming. Keep Client Components small.

**Sources**
- [React Server Components in 2026: The Complete Mental Model](https://www.therobin.dev/blog/react-server-components-deep-dive-2026)
- [React Server Components 2026 | Complete Mastery Guide](https://vic-e.com/blog/react-server-components-mastery)
- [Server Components - React](https://beta.reactjs.org/reference/rsc/server-components)
- [Server and Client Components | Next.js](https://nextjs.org/learn/react-foundations/server-and-client-components)
