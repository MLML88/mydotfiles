use amane::{
    Monitor, LayerWindow, Vertical, Layer, Zone,
    Margin,
};

use crate::modules::{
    clock,
};

pub fn view(_monitor: &Monitor) -> LayerWindow {
    LayerWindow::new()
        .width(120.0)
        .height(40.0)
        .anchor_vertical(Vertical::Top)
        .layer(Layer::Top)
        .space(Zone::Ignore)
        .margin(Margin { top: 10, right: 0, bottom: 3, left: 0 })
        .child(clock::view())
}
