#![no_std]
#![no_main]

mod framebuffer;
mod panic;
mod serial;

use bootloader_api::{entry_point, BootInfo};
use framebuffer::FramebufferWriter;

entry_point!(kernel_main);

fn kernel_main(boot_info: &'static mut BootInfo) -> ! {
    serial::write_line("Moon OS kernel: entered kernel_main");

    let framebuffer = boot_info
        .framebuffer
        .as_mut()
        .expect("bootloader did not provide a framebuffer");

    let mut writer = FramebufferWriter::new(framebuffer);
    writer.clear();
    writer.write_line("Moon OS");
    writer.write_line("");
    writer.write_line("Kernel booted. Framebuffer online.");
    writer.write_line("This is Step 1 of the Moon OS roadmap:");
    writer.write_line("a minimal freestanding kernel with graphics output.");

    serial::write_line("Moon OS kernel: framebuffer initialized, entering idle loop");

    loop {
        x86_64_hlt();
    }
}

fn x86_64_hlt() {
    unsafe {
        core::arch::asm!("hlt");
    }
}
