use amane::{
    Full, Service, Text, Rectangle, Parent, 
    Center, Network, Stack, children,
};

use crate::components::{ gauge };
use crate::theme;

pub fn view() -> Rectangle {
    let theme = theme::current();
    let network = Network::read();
    let icon = match network.strength() {
        100.. => "󰤨  ",
        75.. => "󰤥  ",
        50.. => "󰤢  ",
        25.. => "󰤟  ",
        0.. => "󰤯  ",
    };

    // let label = match network.link() {
    //     Link::Wifi => format!("{}   {} ({}%)", icon, network.ssid(), network.strength()),
    //     Link::Wired => String::from("Wired"),
    //     Link::Other => String::from("Other"),
    //     Link::Offline => String::from("Disconnected"),
    // };

    Rectangle::new()
        .width(40.0)
        .height(Parent)
        .radius(Full)
        .fill(theme.background)
        .align_child(Center, Center)
        .child(
            Stack::new(children![
                Rectangle::new()
                    .width(Parent)
                    .height(Parent)
                    .align_child(Center, Center)
                    .child(Text::new(icon).color(theme.accent)),
                Rectangle::new()
                    .width(Parent)
                    .height(Parent)
                    .align_child(Center, Center)
                    .child(gauge(network.strength().into(), 17.0, 40.0)),
            ])
        )
}
