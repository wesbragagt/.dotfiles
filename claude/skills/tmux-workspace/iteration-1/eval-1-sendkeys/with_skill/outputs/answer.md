# tmux send-keys eval — answer

## Command sent

```
tmux send-keys -t claude-test-repl-with '21*2' Enter
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

bc did not print a result. The session `claude-test-repl-with` is not running `bc` — `bc` is not installed on this system (`zsh: command not found: bc`), so the pane fell back to the zsh prompt. When `21*2` was sent, zsh interpreted it as a glob and returned `zsh: no matches found: 21*2`.

No `42` (the expected bc output) was produced.
