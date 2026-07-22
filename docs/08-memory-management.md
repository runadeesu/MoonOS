# メモリ管理設計

## 3つの層

```
1. 物理フレームアロケータ  — どの4KiB物理ページが空いているかを管理
2. ページテーブル / 仮想メモリ  — 仮想アドレス空間を物理フレームへマッピング
3. ヒープアロケータ         — カーネル内の動的メモリ確保 (Box, Vec 等)
```

## 物理フレームアロケータ（Step 3 で実装予定）

ブートローダーが `BootInfo.memory_regions` として渡すメモリマップ
（UEFI Memory Map / BIOS E820 相当を `bootloader_api` が統一形式に変換
したもの）を元に、空き (`Usable`) 領域をフリーリストで管理します。

```rust
pub struct BootInfoFrameAllocator {
    memory_map: &'static MemoryRegions,
    next: usize,
}

impl FrameAllocator<Size4KiB> for BootInfoFrameAllocator {
    fn allocate_frame(&mut self) -> Option<PhysFrame> {
        // Usable領域をフレーム単位にイテレートし、next番目を返す
    }
}
```

初期実装は単純な bump allocator とし、Step 4 でフリーリスト式の
解放可能なアロケータへ発展させます。

## ページング

x86_64 の4段階ページテーブル (PML4 → PDPT → PD → PT) を使用します。
ブートローダーが最小限のマッピング（カーネル本体・スタック・
フレームバッファ）を構築済みなので、カーネル側では:

- 追加のページのマップ / アンマップ関数
- ヒープ用アドレス範囲の予約とマッピング

を実装します。

## ヒープアロケータ

```rust
#[global_allocator]
static ALLOCATOR: LockedHeap = LockedHeap::empty();

pub fn init_heap(mapper: &mut impl Mapper<Size4KiB>, frame_allocator: &mut impl FrameAllocator<Size4KiB>) {
    // ヒープ用の仮想アドレス範囲をページマップし、
    // ALLOCATOR に範囲を教える
}
```

初期実装はリンクトリストアロケータ、将来的にはスラブアロケータ
（頻出サイズのオブジェクトを高速に確保・解放する）へ最適化します。

## セキュリティ上の設計

- **W^X (Write XOR Execute)** をカーネル・ユーザー双方の全ページで強制
- **KASLR** 相当（カーネルの物理/仮想配置のランダム化）を将来追加
- ユーザー空間導入後は、プロセスごとに独立した仮想アドレス空間
  （プロセスごとの PML4）を持たせ、Copy-on-Write による fork 相当の
  効率化を行う
