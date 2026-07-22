use core::fmt::Write;
use uart_16550::SerialPort;

const COM1_PORT: u16 = 0x3F8;

pub fn write_line(text: &str) {
    // Safety: 0x3F8 is the standard COM1 I/O port on x86, and this is the
    // only place a SerialPort is constructed, so there is no aliasing.
    let mut serial = unsafe { SerialPort::new(COM1_PORT) };
    serial.init();
    let _ = writeln!(serial, "{text}");
}
