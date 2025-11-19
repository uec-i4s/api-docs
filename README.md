# api-docs

このリポジトリは、UEC I4S プロジェクトの API ドキュメントを集約し、配信するためのサーバー構成を管理しています。

## 概要

以下のコンテンツを統合して Web サーバーとして提供します。

- **Manual**: `mdBook` で記述された利用ガイドやドキュメント (`/manual`)
- **Swagger UI**: API 仕様書を閲覧・テストするための UI (`/swagger-ui`)
- **Specs**: OpenAPI/Swagger 仕様書 (YAML) の生ファイル (`/specs`)

## 構成

- `specs/`: 外部リポジトリから同期される API 仕様書 (YAML)
- `manual/`: mdBook ドキュメントのソース
- `swagger-ui/`: Vite + React で構築された Swagger UI アプリケーション
- `*.nix`: Nix によるビルド・依存関係定義

## ビルドと実行

このプロジェクトは Nix Flakes を使用しています。

### 開発環境

```bash
nix develop
```

### ビルド

```bash
nix build
```

### Docker イメージのビルド

```bash
nix build .#dockerImage
```
