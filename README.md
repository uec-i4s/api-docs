# api-docs

UEC I4S プロジェクトの API ドキュメント配信サーバーです。
OpenAPI 仕様書 (Specs)、Swagger UI、およびマニュアル (mdBook) を統合して配信します。

## 構成

このプロジェクトは Nix を使用してビルド・管理されています。
以下の3つのコンポーネントから構成されています。

- specs: OpenAPI 仕様書などのドキュメントソース。
  - 注意: specs/src は [uec-i4s/api-servers](https://github.com/uec-i4s/api-servers) から GitHub Actions で自動同期されます。ここでの直接編集は避けてください。
- swagger-ui: OpenAPI 仕様書を閲覧するための Swagger UI (Vite + React)。
- manual: プロジェクトのドキュメントやマニュアル (mdBook)。

これらは [static-web-server](https://static-web-server.net) によって静的ファイルとして配信されます。

## 開発

Nix がインストールされている環境であれば、以下のコマンドで開発環境に入ることができます。

```bash
nix develop
```

direnv (nix-direnv) を使用している場合は、ディレクトリに入って `direnv allow` を実行するだけで環境が整います。

### ローカルでの実行確認

以下のコマンドでローカルサーバーを起動できます。ポートを指定する場合は引数を渡します。

```bash
nix run . -- -p 8080
```

## デプロイ

将来的には Docker Swarm への移行を計画していますが、現状は SSH サーバーに入って docker-up スクリプトを実行することでデプロイを行います。

### 手順

1. Teleport を使用して api-docs サーバーにログインします。
2. リポジトリのルートにある docker-up スクリプトを実行します。

```bash
./docker-up
```

docker-up スクリプトは、前段のリバースプロキシ構成に合わせた設定パッチの適用、Docker イメージのビルド、およびコンテナの再起動を自動的に行います。
