use amane::{
    Audio, Button, Center, Full,
    Parent, Rectangle, Scroll, Service, Text,
    Stack, children,
};

use crate::components::{ gauge };
use crate::theme;

pub fn view() -> Rectangle {
    let theme = theme::current();
    let audio = Audio::read();

    let label = if audio.muted() {
        String::from("  ")
    } else {
        let icon = match audio.volume() {
            0..=33 => " ",
            34..=66 => " ",
            _ => "  ",
        };
        format!("{}", icon)
    };

    Rectangle::new()
        .width(40.0)
        .height(Parent)
        .radius(Full)
        .fill(theme.background)
        .align_child(Center, Center)
        .on_click(clicked)
        .on_scroll(scrolled)
        .child(
            Stack::new(children![
                Rectangle::new()
                    .width(Parent)
                    .height(Parent)
                    .align_child(Center, Center)
                    .child(Text::new(label).color(theme.accent)),
                Rectangle::new()
                    .width(Parent)
                    .height(Parent)
                    .align_child(Center, Center)
                    .child(gauge(audio.volume().into(), 17.0, 40.0)),
            ])
        )
}

fn clicked(_: Button) {
    Audio::toggle_mute();
}

fn scrolled(scroll: Scroll) {
    let volume = i32::from(Audio::read().volume());
    let step = if scroll.y < 0.0 { 5 } else { -5 };
    Audio::set_volume((volume + step).clamp(0, 100) as u8);
}
