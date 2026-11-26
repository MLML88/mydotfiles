use amane::{
    Color, Palette, Service,
};

pub struct Theme {
    pub background: Color,
    pub foreground: Color,
    pub accent: Color,
}

pub fn current() -> Theme {
    let palette = Palette::read();

    Theme {
        background: palette.background(),
        foreground: palette.foreground(),
        accent: palette.accent(),
    }
}
