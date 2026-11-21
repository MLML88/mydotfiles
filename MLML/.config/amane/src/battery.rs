use amane::{
    Service, Battery, Rectangle, Parent, Full, Color, Center, Text
};

pub fn view() -> Rectangle {
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

    let label = format!("{} {}%", icon, battery.percent());

    Rectangle::new()
        .width(80.0)
        .height(Parent)
        .radius(Full)
        .fill(Color::BLACK)
        .align_child(Center, Center)
        .child(
            Text::new(label)
                .size(18.0)
                .color(Color::WHITE)
        )
}
