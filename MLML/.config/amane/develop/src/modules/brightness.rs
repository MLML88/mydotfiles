use amane::{
    Rectangle, Brightness, Parent, Stack, children,
    Center, Text, Service, Full, Scroll,
};

use crate::components::{ gauge };
use crate::theme;

pub fn view() -> Rectangle {
    let theme = theme::current();
    let brightness = Brightness::read();
    let icon = "󰃠 ";

    Rectangle::new()
        .width(40.0)
        .height(Parent)
        .radius(Full)
        .fill(theme.background)
        .align_child(Center, Center)
        .on_scroll(change_brightness)
        .child(
            Stack::new(children![
                Rectangle::new()
                    .width(Parent)
                    .height(Parent)
                    .align_child(Center, Center)
                    .child(Text::new(icon).color(theme.accent)),
                Rectangle::new()
                    .width(Parent)
                    .height(Parent)
                    .align_child(Center, Center)
                    .child(gauge(brightness.percent().into(), 17.0, 40.0)),
            ])
        )
}

fn change_brightness(scroll: Scroll) {
    let current = i32::from(Brightness::read().percent());
    let step = if scroll.y < 0.0 { 5 } else { -5 };
    let changed = (current + step).clamp(1, 100);

    Brightness::set(changed as u8);
}
