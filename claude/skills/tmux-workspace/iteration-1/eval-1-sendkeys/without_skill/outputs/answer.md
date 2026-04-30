# Eval 1: send-keys to bc REPL

## Command sent

```
tmux send-keys -t claude-test-repl-without '21*2' Enter
```

## Captured pane output

```
bc -q
~/.claude  ✔ bc -q
zsh: command not found: bc
~/.claude  ✔ 21*2
zsh: no matches found: 21*2
~/.claude  ✔
```

## Result reported by bc

bc did not print a result. `bc` is not installed on this system (`which bc` -> `bc not found`; `pacman -Q bc` -> package not found). The session was launched with `bc -q`, which exited immediately with `zsh: command not found: bc`, leaving the zsh prompt active. The `21*2` keys were therefore delivered to zsh, which responded with `zsh: no matches found: 21*2` (zsh glob expansion of `*`).

Expected answer had bc been available: `42`.
