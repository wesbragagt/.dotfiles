# Browser Login

Setup authenticated browser session for agent use.

## Arguments
- `{url}` - Login page URL

## Steps

1. Run: `agent-browser --headed open "{url}"`
2. Ask user: "Browser open. Login now, reply 'done' when ready."
3. On confirmation, run:
   - `agent-browser state save auth.json`
   - `agent-browser screenshot --output login-verified.png`
4. Report: "Session saved to auth.json. Agents can load with `agent-browser state load auth.json`"
