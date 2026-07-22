use bootloader_api::info::{FrameBuffer, PixelFormat};
use noto_sans_mono_bitmap::{get_raster, get_raster_width, FontWeight, RasterHeight};

const FONT_HEIGHT: RasterHeight = RasterHeight::Size16;
const LINE_SPACING: usize = 2;
const MARGIN: usize = 16;

// Moon Light theme: deep night-sky background, soft moonlit foreground.
const BG: (u8, u8, u8) = (10, 12, 24);
const FG: (u8, u8, u8) = (214, 224, 255);

pub struct FramebufferWriter<'a> {
    buffer: &'a mut [u8],
    width: usize,
    height: usize,
    stride: usize,
    bytes_per_pixel: usize,
    pixel_format: PixelFormat,
    cursor_x: usize,
    cursor_y: usize,
}

impl<'a> FramebufferWriter<'a> {
    pub fn new(framebuffer: &'a mut FrameBuffer) -> Self {
        let info = framebuffer.info();
        Self {
            buffer: framebuffer.buffer_mut(),
            width: info.width,
            height: info.height,
            stride: info.stride,
            bytes_per_pixel: info.bytes_per_pixel,
            pixel_format: info.pixel_format,
            cursor_x: MARGIN,
            cursor_y: MARGIN,
        }
    }

    pub fn clear(&mut self) {
        for y in 0..self.height {
            for x in 0..self.width {
                self.set_pixel(x, y, BG);
            }
        }
        self.cursor_x = MARGIN;
        self.cursor_y = MARGIN;
    }

    pub fn write_line(&mut self, text: &str) {
        for ch in text.chars() {
            self.write_char(ch);
        }
        self.newline();
    }

    fn write_char(&mut self, ch: char) {
        let width = get_raster_width(FontWeight::Regular, FONT_HEIGHT);
        if self.cursor_x + width > self.width {
            self.newline();
        }
        let raster =
            get_raster(ch, FontWeight::Regular, FONT_HEIGHT).unwrap_or_else(|| {
                get_raster(' ', FontWeight::Regular, FONT_HEIGHT).expect("space glyph missing")
            });

        for (row, line) in raster.raster().iter().enumerate() {
            for (col, intensity) in line.iter().enumerate() {
                let color = blend(BG, FG, *intensity);
                self.set_pixel(self.cursor_x + col, self.cursor_y + row, color);
            }
        }
        self.cursor_x += width;
    }

    fn newline(&mut self) {
        self.cursor_x = MARGIN;
        self.cursor_y += usize::from(FONT_HEIGHT.val()) + LINE_SPACING;
    }

    fn set_pixel(&mut self, x: usize, y: usize, color: (u8, u8, u8)) {
        if x >= self.width || y >= self.height {
            return;
        }
        let offset = y * self.stride + x;
        let byte_offset = offset * self.bytes_per_pixel;
        if byte_offset + self.bytes_per_pixel > self.buffer.len() {
            return;
        }

        let (r, g, b) = color;
        match self.pixel_format {
            PixelFormat::Rgb => {
                self.buffer[byte_offset] = r;
                self.buffer[byte_offset + 1] = g;
                self.buffer[byte_offset + 2] = b;
            }
            PixelFormat::Bgr => {
                self.buffer[byte_offset] = b;
                self.buffer[byte_offset + 1] = g;
                self.buffer[byte_offset + 2] = r;
            }
            PixelFormat::U8 => {
                let gray = ((r as u16 + g as u16 + b as u16) / 3) as u8;
                self.buffer[byte_offset] = gray;
            }
            _ => {
                self.buffer[byte_offset] = b;
                self.buffer[byte_offset + 1] = g;
                self.buffer[byte_offset + 2] = r;
            }
        }
    }
}

fn blend(bg: (u8, u8, u8), fg: (u8, u8, u8), intensity: u8) -> (u8, u8, u8) {
    let t = intensity as u16;
    let lerp = |a: u8, b: u8| -> u8 { ((a as u16 * (255 - t) + b as u16 * t) / 255) as u8 };
    (lerp(bg.0, fg.0), lerp(bg.1, fg.1), lerp(bg.2, fg.2))
}
