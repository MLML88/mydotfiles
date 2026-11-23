use amane::{
    Audio, Button, Center, Color, Full,
    Parent, Rectangle, Scroll, Service, Text
};

pub fn view() -> Rectangle {
    let audio = Audio::read();

    let label = if audio.muted() {
        String::from(" ")
    } else {
        let icon = match audio.volume() {
            0..=33 => "",
            34..=66 => "",
            _ => "",
        };
        format!("{icon}  {}%", audio.volume())
    };

    Rectangle::new()
        .width(80.0)
        .height(Parent)
        .radius(Full)
        .fill(Color::BLACK)
        .align_child(Center, Center)
        .on_click(clicked)
        .on_scroll(scrolled)
        .child(
            Text::new(label)
                .size(18.0)
                .color(Color::WHITE)
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
