# ディレクトリ構成

現時点（Step 1 完了時点）の実際のリポジトリ構成です。将来のステップで
追加される予定のディレクトリも「(予定)」として記載しています。

```
MoonOS/
├── docs/                        設計ドキュメント
│   ├── 00-overview.md
│   ├── 01-architecture.md
│   ├── 02-roadmap.md
│   ├── 03-directory-structure.md
│   ├── 04-boot-sequence.md
│   ├── 05-kernel-design.md
│   ├── 06-gui-design.md
│   ├── 07-filesystem-design.md
│   ├── 08-memory-management.md
│   ├── 09-process-management.md
│   └── 10-network-design.md
│
├── kernel/                      Moon Kernel 本体 (Rust, no_std)
│   ├── Cargo.toml
│   └── src/
│       ├── main.rs               エントリポイント
│       ├── framebuffer.rs        フレームバッファ描画
│       ├── serial.rs             シリアルデバッグ出力
│       └── panic.rs              パニックハンドラ
│
├── tools/
│   └── image-builder/           カーネルELFからブート可能イメージを作るツール
│       ├── Cargo.toml
│       └── src/main.rs
│
├── (予定) drivers/               ステップ9以降: デバイスドライバ群
├── (予定) userland/              ステップ7以降: ユーザー空間プログラム
│   ├── (予定) libmoon/           システムコールラッパー / 標準ライブラリ
│   ├── (予定) moond/             init / サービスマネージャ
│   └── (予定) shell/             Moon Shell (GUI)
├── (予定) fs/                    ステップ6以降: Moon FS 実装
├── (予定) net/                   ステップ10以降: ネットワークスタック
│
├── build.sh                      ローカルビルド用スクリプト
├── run-qemu.sh                    QEMU起動スクリプト（BIOS/UEFI）
├── .github/workflows/ci.yml       CI: ビルド + QEMU起動確認
└── README.md
```

## 設計方針

- `kernel/` と `tools/image-builder/` は意図的に**別々の Cargo プロジェクト**
  にしています。`kernel` は `x86_64-unknown-none` ターゲット向けの
  フリースタンディングバイナリ、`image-builder` はホスト上で動く通常の
  Rust プログラムであり、ビルドターゲットも依存クレートも全く異なるため、
  1 つの Cargo ワークスペースに無理に統合しません。
- 将来 `userland/` 配下にユーザー空間プログラムが増えても、カーネルの
  ビルド設定に影響しないよう、それぞれ独立した Cargo プロジェクト /
  ワークスペースとして追加していきます。
