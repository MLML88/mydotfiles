use amane::{
    Rectangle, Widget, Color, Size
};

pub fn pill(content: impl Widget + 'static, w: impl Into<Size>, h: impl Into<Size>) -> Rectangle {
    Rectangle::new()
        .width(w)
        .height(h)
        .radius(18.0)
        .fill(Color::BLACK)
        .clip()
        .child(content)
}
