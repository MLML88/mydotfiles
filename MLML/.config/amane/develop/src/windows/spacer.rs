use amane::{
    Monitor, LayerWindow, Full, Vertical, Layer, Zone, Margin,
};

pub fn view(_monitor: &Monitor) -> LayerWindow {
    LayerWindow::new()
        .width(Full)
        .height(40.0)
        .anchor_vertical(Vertical::Top)
        .layer(Layer::Top)
        .space(Zone::Reserve)
        .margin(Margin { top: 10, right: 0, bottom: 3, left: 0 })
        .click_through()
}
