use amane::{
    Service, Battery, Rectangle, Parent, Full,
    Center, Text, Stack, children, 
};

use crate::components::{ gauge };
use crate::theme;

pub fn view() -> Rectangle {
    let theme = theme::current();
    let battery = Battery::read();

    let icon = match battery.percent() {
        100.. => "󰁹",
        90.. => "󰂂",
        80.. => "󰂁",
        70.. => "󰂀",
        60.. => "󰁿",
        50.. => "󰁾",
        40.. => "󰁽",
        30.. => "󰁼",
        20.. => "󰁻",
        10.. => "󰁺",
        0.. => "󰂎",
    };

    let label = format!("{}", icon);

    Rectangle::new()
        .width(40.0)
        .height(Parent)
        .radius(Full)
        .fill(theme.background)
        .align_child(Center, Center)
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
                    .child(gauge(battery.percent().into(), 17.0, 40.0)),
            ])
        )
}
