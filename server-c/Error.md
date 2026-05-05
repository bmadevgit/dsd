# Server-C Error Timeline

## 2026-05-05

| Time (UTC+7) | Error | Root Cause | Resolution |
|---|---|---|---|
| ~12:56 | `:8000: command not found` during report generation | Markdown line used escaped backticks in heredoc causing shell interpretation issue. | Updated vLLM health table row to plain text (`GET /v1/models or port :8000`). |
| ~12:56 | `cd: /home/ubuntu/dsd: No such file or directory` | Repo path in script did not match this server. | Changed repo path to `/home/administrator/dsd` and added auto-clone logic. |
| ~12:58 | `Host key verification failed` on git clone/push | `github.com` not in SSH `known_hosts`. | Added GitHub host key via `ssh-keyscan`. |
| ~12:58 | `Permission denied (publickey)` on git clone/push | No SSH key configured for this host in GitHub account. | Generated `ed25519` key and added public key to GitHub SSH keys. |
| ~13:02 | `awk ... backslash not last character on line` | Escaped quotes inside `awk` command were malformed. | Replaced with clean `awk '{print $2 "|" $3 "|" $4}'` expression. |

## Notes

| Item | Detail |
|---|---|
| Error tracking scope | This file tracks setup/automation errors for `server-c` operations. |
| Update practice | Add new issues in chronological order with cause and fix. |
