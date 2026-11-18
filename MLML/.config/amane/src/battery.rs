use amane::{
    Service, Battery, Rectangle, Parent, Full, Color, Center, Text
};

pub fn view() -> Rectangle {
    let battery = Battery::read();

    let label = format!("Battery {}%", battery.percent());

    Rectangle::new()
        .width(120.0)
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
