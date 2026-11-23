use std::time::Duration;

use amane::{
    LayerWindow, Vertical, Layer, Zone, Color,
    Parent, Rectangle, Margin, Service, 
    Animation, Easing
};

struct Panel {
    width: Animation,
    height: Animation,
}

impl Service for Panel {
    fn new() -> Self {
        Self {
            width: Animation::new(120.0)
                .duration(Duration::from_millis(300))
                .easing(Easing::Out),
            height: Animation::new(35.0)
                .duration(Duration::from_millis(300))
                .easing(Easing::Out),
        }
    }

    fn interval() -> Duration {
        Duration::from_secs(3600)
    }
}

struct Launcher {
    open: bool,
}

impl Service for Launcher {
    fn new() -> Self {
        Self { open: false }
    }

    fn interval() -> Duration {
        Duration::from_secs(3600)
    }
}

pub fn view() -> LayerWindow {
    let launcher = Launcher::read();
    let panel = Panel::read();

    LayerWindow::new()
        .width(panel.width.value())
        .height(panel.height.value())
        .anchor_vertical(Vertical::Top)
        .layer(Layer::Overlay)
        .space(Zone::Ignore)
        .margin(Margin { top: 10, right: 0, bottom: 0, left: 0 })
        .visible(launcher.open)
        .child(
            Rectangle::new()
                .width(Parent)
                .height(Parent)
                .radius(8.0)
                .fill(Color::BLACK)
        )
}

pub fn expand() {
    let mut panel = Panel::write();
    let w = if panel.width.value() < 130.0 { 500.0 } else { 120.0 };
    let h = if panel.height.value() < 40.0 { 700.0 } else { 35.0 };

    panel.width.to(w);
    panel.height.to(h);
}

pub fn toggle(_: &[String]) -> String {
    let mut launcher = Launcher::write();
    launcher.open = !launcher.open;

    if launcher.open {
        expand();
        String::from("opened")
    } else {
        expand();
        String::from("closed")
    }
}
