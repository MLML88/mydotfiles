use amane::{
    LayerWindow, Parent, Color, Full, Rectangle,
    Layer, Vertical, Zone, Align, Widget,
    children, Row, Start, Center, End, Monitor, Text,
    Padding
};

use crate::{
    clock, battery, wifi, volume, workspace,
};

pub fn view(_monitor: &Monitor) -> LayerWindow {
    let apart: f32 = 6.0;

    let left = Row::new(children![
        pill("󰣇 "),
        workspace::view(),
    ]).gap(apart);

    let middle = Row::new(children![
        clock::view(),
    ]).gap(apart);

    let right = Row::new(children![
        volume::view(),
        wifi::view(),
        battery::view(),
        pill("  "),
    ]).gap(apart);

    LayerWindow::new()
        .width(Full)
        .height(50.0)
        .anchor_vertical(Vertical::Top)
        .layer(Layer::Top)
        .space(Zone::Reserve)
        .child(
            Rectangle::new()
                .width(Parent)
                .height(Parent)
                .fill(Color::TRANSPARENT)
                .padding(Padding { top: 10.0, right: 15.0, bottom: 5.0, left: 15.0 })
                .child(Row::new(children![
                    section(left, Start),
                    section(middle, Center),
                    section(right, End),
                ])),
        )
}

fn pill(content: &str) -> Rectangle {
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

fn section(content: impl Widget + 'static, align: impl Into<Align>) -> Rectangle {
    Rectangle::new()
        .width(Parent)
        .height(Parent)
        .align_child(align, Center)
        .child(content)
}
