# 🌙 Moon OS

Windows・macOS・Linux の優れた設計思想を参考にしながら、ゼロから作る
オリジナルの次世代 OS です。既存 OS のコードやアセットのコピーは一切
行わず、UEFI / GPT などの公開された標準規格にのみ準拠します。

現在のステータス: **Phase 0 / Step 1 完了** — UEFI・BIOS 両対応の
フリースタンディング Rust カーネルが QEMU 上で実際に起動し、
Moon Light テーマの画面描画とシリアルログ出力を確認済みです。

## ドキュメント

設計思想・アーキテクチャ・ロードマップの全体像は [`docs/`](docs/) を
参照してください。

- [概要](docs/00-overview.md)
- [全体アーキテクチャ](docs/01-architecture.md)
- [開発ロードマップ](docs/02-roadmap.md)
- [ディレクトリ構成](docs/03-directory-structure.md)
- [ブートシーケンス](docs/04-boot-sequence.md)
- [カーネル構造](docs/05-kernel-design.md)
- [GUI構造](docs/06-gui-design.md)
- [ファイルシステム設計](docs/07-filesystem-design.md)
- [メモリ管理設計](docs/08-memory-management.md)
- [プロセス管理設計](docs/09-process-management.md)
- [ネットワーク設計](docs/10-network-design.md)

## ビルド方法

### 必要な環境

- Rust stable（`rustup target add x86_64-unknown-none`）
- Rust nightly + `rust-src` + `llvm-tools-preview`
  （`bootloader` クレートがブートステージのビルドに内部的に必要とします）
  ```sh
  rustup toolchain install nightly --profile minimal
  rustup component add rust-src llvm-tools-preview --toolchain nightly
  ```
- QEMU（`qemu-system-x86` パッケージ）+ OVMF（UEFI ファームウェア、任意）

### ビルド

```sh
./build.sh
```

`build/images/moon-os-bios.img`（BIOS用）と `build/images/moon-os-uefi.img`
（UEFI用）の2つのブート可能ディスクイメージが生成されます。

## 実行方法（QEMU）

```sh
./run-qemu.sh bios   # BIOS (SeaBIOS) で起動
./run-qemu.sh uefi   # UEFI (OVMF) で起動
```

実機の USB メモリ等に書き込んで起動することも可能です（`dd` 等で
`moon-os-bios.img` / `moon-os-uefi.img` を書き込んでください）。

起動すると、シリアルコンソールに以下のようなログが出力され、画面には
Moon Light テーマ（夜空色の背景 + 月光色のテキスト）で "Moon OS" の
起動メッセージが描画されます。

```
Moon OS kernel: entered kernel_main
Moon OS kernel: framebuffer initialized, entering idle loop
```

## テスト方法

CI（`.github/workflows/ci.yml`）が push / PR ごとに以下を自動実行します。

1. `kernel/` を `x86_64-unknown-none` ターゲットでビルド
2. `tools/image-builder` でブートイメージを生成
3. QEMU 上で BIOS / UEFI 両方の起動テストを実行し、シリアルログに
   `entering idle loop` が出力されることを確認（CIでの自動起動確認）

ローカルでも同様に、`./build.sh && ./run-qemu.sh bios` で目視確認できます。

## 改善案 / 次のステップ

`docs/02-roadmap.md` の Step 2（割り込み処理・GDT/IDT構築）が次の
マイルストーンです。その他の改善候補:

- パニックハンドラでのシリアル/画面へのエラー情報出力の追加
- QEMU の `isa-debug-exit` デバイスを使った CI の終了コード判定
  （現状は起動ログの grep のみで正常終了を判定している簡易版）
- フレームバッファ描画の二重バッファ化（現状は毎回全画面を描き直す
  ナイーブな実装）

## ライセンス / 開発方針

本プロジェクトは独自実装のみで構成し、既存 OS のソースコード・
著作物を含みません。標準規格（UEFI仕様、GPT仕様、RFC等）にのみ
準拠して実装します。
