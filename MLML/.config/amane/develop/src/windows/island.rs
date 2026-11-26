use std::time::Duration;

use amane::{
    Monitor, LayerWindow, Vertical, Layer, Zone,
    Margin, Animation, Service, Text, Parent, 
    Color, Center, Row, children, Full,
};

use crate::modules::{
    clock, battery, network, volume, brightness, 
};

use crate::components::{
    pill,
};

struct StatTray {
    open: bool,
    width: Animation,
    height: Animation,
}

impl Service for StatTray {
    fn new() -> Self {
        Self {
            open: false,
            width: Animation::new(675.0),
            height: Animation::new(40.0),
        }
    }

    fn interval() -> Duration {
        Duration::from_secs(3600)
    }
}

pub fn view(_monitor: &Monitor) -> LayerWindow {
    let stat = StatTray::read();
    let content = if stat.open {
        Row::new(children![
           pill(
               Text::new("Testing").color(Color::WHITE),
               Parent, Parent,
           ).align_child(Center, Center)
        ]).width(Parent).justify(Center).align(Center).gap(5.0)
    } else {
        Row::new(children![
            brightness::view(),
            network::view(),
            clock::view(),
            volume::view(),
            battery::view(),
        ]).width(Parent).justify(Center).align(Center).gap(5.0)
    };

    LayerWindow::new()
        .width(Full)
        .height(stat.height.value())
        .anchor_vertical(Vertical::Top)
        .layer(Layer::Top)
        .space(Zone::Ignore)
        .margin(Margin { top: 10, right: 0, bottom: 3, left: 0 })
        .child(content)
}

pub fn toggle_stat(_: &[String]) -> String {
    let mut stat = StatTray::write();

    stat.open = !stat.open;

    if stat.open {
        stat.width.to(500.0);
        stat.height.to(500.0);
        String::from("opened")
    } else {
        stat.width.to(675.0);
        stat.height.to(40.0);
        String::from("closed")
    }
}
