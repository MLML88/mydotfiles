use amane::{
    Rectangle, Parent, Full, Color, Center, Text,
};

pub fn pill(content: &str) -> Rectangle {
    Rectangle::new()
        .width(50.0)
        .height(Parent)
        .radius(Full)
        .fill(Color::BLACK)
        .align_child(Center, Center)
        .child(
            Text::new(content)
                .size(18.0)
                .color(Color::WHITE)
        )
}
