//! Turns the built moon-kernel ELF into bootable BIOS and UEFI disk images.
//!
//! Usage: moon-image-builder <kernel-elf-path> <output-dir>

use std::env;
use std::path::PathBuf;

use bootloader::{BiosBoot, UefiBoot};

fn main() {
    let mut args = env::args().skip(1);
    let kernel_path = PathBuf::from(
        args.next()
            .expect("usage: moon-image-builder <kernel-elf-path> <output-dir>"),
    );
    let out_dir = PathBuf::from(args.next().expect("missing output-dir argument"));

    std::fs::create_dir_all(&out_dir).expect("failed to create output directory");

    let bios_path = out_dir.join("moon-os-bios.img");
    BiosBoot::new(&kernel_path)
        .create_disk_image(&bios_path)
        .expect("failed to create BIOS disk image");
    println!("BIOS image:  {}", bios_path.display());

    let uefi_path = out_dir.join("moon-os-uefi.img");
    UefiBoot::new(&kernel_path)
        .create_disk_image(&uefi_path)
        .expect("failed to create UEFI disk image");
    println!("UEFI image:  {}", uefi_path.display());
}
