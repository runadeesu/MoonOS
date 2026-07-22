# カーネル構造

## モジュール構成（現状 + 計画）

```
kernel/src/
├── main.rs            エントリポイント、初期化シーケンスの統括
├── framebuffer.rs      フレームバッファ描画（実装済み）
├── serial.rs           シリアルデバッグ出力（実装済み）
├── panic.rs             パニックハンドラ（実装済み）
├── (予定) gdt.rs         グローバルディスクリプタテーブル
├── (予定) idt.rs / interrupts.rs   割り込みディスクリプタテーブル、例外ハンドラ
├── (予定) memory/
│   ├── frame_allocator.rs   物理フレームアロケータ
│   ├── paging.rs             ページテーブル操作
│   └── heap.rs                ヒープアロケータ (GlobalAlloc)
├── (予定) task/
│   ├── process.rs
│   ├── scheduler.rs
│   └── context_switch.s
├── (予定) fs/            VFS 層
├── (予定) drivers/       キーボード・ストレージ・NIC ドライバ
└── (予定) syscall.rs      システムコールディスパッチ
```

## 初期化シーケンス（現状）

```rust
entry_point!(kernel_main);

fn kernel_main(boot_info: &'static mut BootInfo) -> ! {
    serial::write_line("Moon OS kernel: entered kernel_main");
    let framebuffer = boot_info.framebuffer.as_mut().expect("no framebuffer");
    let mut writer = FramebufferWriter::new(framebuffer);
    writer.clear();
    writer.write_line("Moon OS");
    // ...
    loop { hlt(); }
}
```

Step 2 以降で、この初期化シーケンスに GDT/IDT 構築 → メモリ管理初期化 →
スケジューラ起動、という順序で処理を追加していきます。

## カーネル/ユーザー境界の設計方針

- Step 1〜6 まではカーネル空間のみで動作するモノリシックな構成とし、
  「動くものを小さく積み上げる」ことを優先します。
- Step 7 でユーザー空間 (Ring 3) への遷移を導入し、以降のシステム
  サービス（`moond` など）はユーザー空間プロセスとして実装します。
- ドライバは初期段階ではカーネル内蔵としますが、`drivers/` 以下の各
  ドライバは「デバイスとの通信ロジック」と「カーネル統合コード」を
  分離した内部構造にしておき、将来ユーザー空間ドライバへ移行しやすい
  形にしておきます。

## パニック処理

現状の `panic.rs` は最小限（`hlt` ループ）です。Step 2 でシリアル/画面への
パニック情報出力、Step 3 以降でスタックトレースの表示を追加します。
