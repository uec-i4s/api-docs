## 課題

Caddy から static-web-server に乗り換える

## 現状

- specs/
  - API仕様書（YAMLファイル）が格納されている
  - 別リポジトリ CI から specディレクトリごと生成され、それが push されている (= 人がいじる場所ではない)
- manual/
  - mdBook を使用して記述されたドキュメント（APIの利用ガイドなど）
  - 内容は今後追加していく予定
- swagger-ui/
  - Vite + Swagger UI で構築されたシングルページアプリケーション
  - main.ts 内で specs 以下のYAMLファイルや外部のOpenAPI JSONを参照するように設定

### ビルド・配信構成 (Nix & Caddy)

Nix: flake.nix と *.nix ファイルにより、依存関係（mdbook, nodejs, pnpm, caddyなど）とビルドプロセスが管理。

- Caddy: api-docs.nix で生成される Caddyfile に基づき、以下のパスでコンテンツを配信します。
- manual: マニュアル
- swagger-ui: Swagger UI
- specs: 生のYAMLファイル
- /: manual へリダイレクト

## やること

manual/ と swagger-ui/ の構成は基本そのままで、specs 部分と Caddy に関連した部分に変更を入れていく。

### /specs エンドポイント

/specsエンドポイントでは YAML ファイル自体を配布する。
ただし、/specs/index.html では配布している YAML ファイルの一覧を表示するようにする。

- `specs/*.yaml` を `specs/src/*.yaml` に移動する。
  - 別リポジトリの CI は specs/src/ を生成するように修正済み
- `specs/index.html` と `specs/default.nix` を作る。
  - /specs/aia-v1.yaml のようにアクセスできるようにファイルを derivation では配置すること

### api-docs.nix

static-web-server のラッパーコマンドとして、api-docs コマンドを作る。

Caddy の設定ファイルを生成しているように、static-web-server のTOMLの設定ファイル作る。
ポートに関しては TOML では設定せず、引数で設定するように。
引数で設定というか、api-docs コマンドの引数は全て static-web-server の引数に流す感じ。

MCPツールとして、static-web-server のドキュメントを参照・検索できるものを追加しているので、適宜使うこと (fetchツールではない)。

### flake.nix (packages)

- swagger-ui-dist
- manual-dist
- specs-dist
- api-docs
- dockerImage

### flake.nix (apps)

不要。nix run ではデフォルトで、packages.default が実行されるはずなので、適切に packages.default を作ってあれば nix run でサーバが起動できるはず。
