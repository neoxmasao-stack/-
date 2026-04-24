# 24 Codex MCP セットアップガイド

## 目的
Codex から外部ツール/ドキュメントへ接続する MCP サーバーを、CLI または `config.toml` で再現可能に設定する。

## 1) CLI で STDIO MCP を追加
```bash
codex mcp add <server-name> --env VAR1=VALUE1 --env VAR2=VALUE2 -- <stdio server-command>
```

例（Context7）:
```bash
codex mcp add context7 -- npx -y @upstash/context7-mcp
```

## 2) PowerShell 例
```powershell
codex mcp add context7 -- npx -y @upstash/context7-mcp
codex mcp list
```

環境変数付き:
```powershell
codex mcp add my-docs --env DOCS_TOKEN=$env:DOCS_TOKEN -- npx -y @acme/docs-mcp
```

## 3) HTTP MCP 例（config.toml）
```toml
[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
bearer_token_env_var = "FIGMA_OAUTH_TOKEN"
```

## 4) トラブルシューティング
- `codex mcp --help` で利用可能なサブコマンドを確認。
- `codex` TUI の `/mcp` で有効サーバー確認。
- OAuth が必要なサーバーは `codex mcp login <server-name>` を実行。
- 設定ファイルは `~/.codex/config.toml`（またはプロジェクト `.codex/config.toml`）。
