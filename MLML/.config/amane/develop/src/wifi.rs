use amane::{
    Full, Service, Text, Rectangle, Parent, 
    Color, Center, Link, Network
};

pub fn view() -> Rectangle {
    let network = Network::read();
    let icon = match network.strength() {
        100.. => "󰤨",
        75.. => "󰤥",
        50.. => "󰤢",
        25.. => "󰤟",
        0.. => "󰤯",
    };

    let label = match network.link() {
        Link::Wifi => format!("{}   {} ({}%)", icon, network.ssid(), network.strength()),
        Link::Wired => String::from("Wired"),
        Link::Other => String::from("Other"),
        Link::Offline => String::from("Disconnected"),
    };

    Rectangle::new()
        .width(250.0)
        .height(Parent)
        .radius(Full)
        .fill(Color::BLACK)
        .align_child(Center, Center)
        .child(
            Text::new(label)
                .size(15.0)
                .color(Color::WHITE)
        )
}
