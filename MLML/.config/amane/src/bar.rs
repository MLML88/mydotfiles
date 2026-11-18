use amane::{
    LayerWindow, Parent, Color, Full, Rectangle,
    Layer, Vertical, Zone, Align, Widget,
    children, Row, Start, Center, End
};

use crate::{
    clock, battery
};

pub fn view() -> LayerWindow {
    LayerWindow::new()
        .width(Full)
        .height(35.0)
        .anchor_vertical(Vertical::Top)
        .layer(Layer::Top)
        .space(Zone::Reserve)
        .child(
            Rectangle::new()
                .width(Parent)
                .height(Parent)
                .fill(Color::TRANSPARENT)
                .child(Row::new(children![
                    section(clock::view(), Start),
                    section(clock::view(), Center),
                    section(battery::view(), End),
                ])),
        )
}

fn section(content: impl Widget + 'static, align: impl Into<Align>) -> Rectangle {
    Rectangle::new()
        .width(Parent)
        .height(Parent)
        .align_child(align, Center)
        .child(content)
}
