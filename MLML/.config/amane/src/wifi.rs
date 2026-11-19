use std::time::Duration;

use amane::{
    Full, Service, Text, Rectangle, Parent, 
    Color, Center, Bus
};

pub struct Wifi {
    enabled: bool,
}

impl Service for Wifi {
    fn new() -> Self {
        Self { enabled: read_enabled() }
    }

    fn interval() -> Duration {
        Duration::from_secs(5)
    }

    fn update(&mut self) -> bool {
        let enabled = read_enabled();
        let changed = enabled != self.enabled;
        self.enabled = enabled;
        changed
    }
}

fn read_enabled() -> bool {
    let bus = Bus::system();

    let enabled = bus.property(
        "org.freedesktop.NetworkManager",
        "/org/freedesktop/NetworkManager",
        "org.freedesktop.NetworkManager",
        "WirelessEnabled",
    );

    enabled.bool()
}

pub fn view() -> Rectangle {
    let wifi = Wifi::read();
    let label = if wifi.enabled { "wifi on" } else { "wifi off" };

    Rectangle::new()
        .width(120.0)
        .height(Parent)
        .radius(Full)
        .fill(Color::BLACK)
        .align_child(Center, Center)
        .child(
            Text::new(label)
                .size(18.0)
                .color(Color::WHITE)
        )
}
