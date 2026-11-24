use std::time::Duration;

use amane::{
    Monitor, LayerWindow, Vertical, Layer, Zone,
    Margin, Animation, Service, Text, Parent, 
};

use crate::modules::{
    clock,
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
            width: Animation::new(120.0),
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
       pill(
           Text::new("Testing"),
           Parent,
           Parent,
       )
    } else {
        clock::view()
    };

    LayerWindow::new()
        .width(stat.width.value())
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
        stat.width.to(120.0);
        stat.height.to(40.0);
        String::from("closed")
    }
}
