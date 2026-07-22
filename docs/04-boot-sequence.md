# ブートシーケンス

Moon OS は UEFI を第一級のブート方式とし、レガシー BIOS も互換性のために
サポートします。両方とも `bootloader` クレートが提供する第2段階ブート
ローダーが、最終的に同じ Rust カーネルエントリポイントへジャンプします。

## UEFI ブートフロー（メイン経路）

```
1. マザーボード Firmware (UEFI) が起動
2. GPT パーティションテーブルから EFI System Partition を検出
3. /EFI/BOOT/BOOTX64.EFI (Moon UEFI ブートローダー) をロード
4. UEFI Boot Services を使い、フレームバッファ (GOP) を取得
5. メモリマップを取得し、UEFI Boot Services を ExitBootServices() で終了
6. カーネル ELF を読み込み、ページテーブルを構築
7. BootInfo 構造体 (メモリマップ, フレームバッファ情報等) を構築
8. カーネルエントリポイントへ long mode でジャンプ
```

## BIOS ブートフロー（互換経路）

```
1. マザーボードが MBR のブートセクタ (Stage 1, 512 バイト) を実行
2. Stage 1 が Stage 2/3/4 をディスクから読み込む
3. Stage 4 で real mode → protected mode → long mode へ遷移
4. VESA/VBE 経由でフレームバッファを設定
5. カーネル ELF をロードし、UEFI 経路と同じ BootInfo 形式を構築
6. カーネルエントリポイントへジャンプ
```

## 実装

`tools/image-builder` が `kernel/target/x86_64-unknown-none/release/moon-kernel`
（フリースタンディング ELF）を入力に取り、`bootloader` crate の
`BiosBoot` / `UefiBoot` ビルダーを使って:

- `build/images/moon-os-bios.img` — MBR + 全ステージを含む生ディスクイメージ
- `build/images/moon-os-uefi.img` — FAT フォーマットの EFI System Partition を含む GPT イメージ

を生成します。カーネル側は `bootloader_api::entry_point!` マクロで
`fn kernel_main(boot_info: &'static mut BootInfo) -> !` を登録するだけで、
上記のどちらの経路から呼ばれても同一の `BootInfo` 構造体
（フレームバッファ情報、物理メモリマップ、RSDP アドレス等）を受け取れます。

## 現在の起動確認結果

```
$ qemu-system-x86_64 -drive format=raw,file=build/images/moon-os-bios.img \
    -display none -serial stdio -no-reboot -m 256M
...
Jumping to kernel entry point at VirtAddr(0x1000000c0b0)
Moon OS kernel: entered kernel_main
Moon OS kernel: framebuffer initialized, entering idle loop
```

BIOS (SeaBIOS) と UEFI (OVMF) の両方でここまで確認済みです。
