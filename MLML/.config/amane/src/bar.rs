use amane::{
    LayerWindow, Parent, Color, Full, Rectangle,
    Layer, Vertical, Zone, Align, Widget,
    children, Row, Start, Center, End, Monitor, Text
};

use crate::{
    clock, battery, wifi
};

pub fn view(monitor: &Monitor) -> LayerWindow {
    let left = Row::new(children![
        pill("Icon"),
        pill("Workspace"),
    ]).gap(6.0);

    let middle = Row::new(children![
        clock::view(),
    ]).gap(6.0);

    let right = Row::new(children![
        pill("Volume"),
        wifi::view(),
        battery::view(),
        pill("Notification")
    ]).gap(6.0);

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
                    section(left, Start),
                    section(middle, Center),
                    section(right, End),
                ])),
        )
}

fn pill(content: &str) -> Rectangle {
    Rectangle::new()
        .width(120.0)
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

fn section(content: impl Widget + 'static, align: impl Into<Align>) -> Rectangle {
    Rectangle::new()
        .width(Parent)
        .height(Parent)
        .align_child(align, Center)
        .child(content)
}
