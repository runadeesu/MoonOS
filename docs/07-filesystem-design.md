# ファイルシステム設計

## 方針

Moon OS は2層構造でファイルシステムを扱います。

1. **VFS (Virtual File System)** — カーネル内の統一インターフェース。
   ファイルシステムの種類を問わず `open/read/write/close` 等の操作を
   同じ API で扱えるようにする層。
2. **Moon FS** — Moon OS 独自のオンディスクファイルシステム。

初期のブート・initrd 相当の用途では、実装が単純な FAT32 (UEFI ESP は
どのみち FAT である必要がある) や、メモリ上の read-only イメージ
（tar 相当の単純フォーマット）を使い、本格的な Moon FS は Step 6 で
段階的に実装します。

## VFS レイヤー（計画）

```rust
trait FileSystem {
    fn open(&self, path: &str) -> Result<FileHandle, FsError>;
    fn read(&self, handle: FileHandle, buf: &mut [u8]) -> Result<usize, FsError>;
    fn write(&self, handle: FileHandle, buf: &[u8]) -> Result<usize, FsError>;
    fn readdir(&self, path: &str) -> Result<Vec<DirEntry>, FsError>;
    fn stat(&self, path: &str) -> Result<Metadata, FsError>;
}
```

複数の `FileSystem` 実装をマウントポイントごとに登録し、パス解決時に
どの実装へディスパッチするか決定する、Linux VFS ライクな設計とします。

## Moon FS の設計目標

- **ジャーナリング**によるクラッシュ耐性（ext4 の設計思想を参考に、
  実装はゼロから）
- **Copy-on-Write スナップショット**（将来のシステム復元機能向け）
- **拡張属性**（アプリのサンドボックス権限・Moon App Store のメタデータ）
- 将来的な**暗号化ボリューム**対応（BitLocker/FileVault の設計思想を参考）

## オンディスクフォーマット（初期案）

```
Superblock
├── magic: [u8; 8] = b"MOONFS01"
├── block_size: u32
├── total_blocks: u64
├── inode_table_start: u64
├── journal_start: u64
└── root_inode: u64

Inode
├── mode, uid, gid, size, timestamps
├── direct blocks [12]
├── indirect block
└── double-indirect block
```

ext系ファイルシステムの一般的な設計（inode + ブロックポインタ）を
参考にしつつ、Moon 独自の拡張属性領域とジャーナルフォーマットを
別途定義します。詳細なオンディスクレイアウトは Step 6 着手時に
別ドキュメントとして詳細化します。
