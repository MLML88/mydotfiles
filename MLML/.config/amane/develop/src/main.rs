mod components;
mod windows;
mod modules;
mod theme;

use amane::{ App, Palette, Service };

use crate::windows::{
    spacer, island, toggle_stat,
};

fn main() {
    Palette::write().open("/home/excalibur/mydotfiles/Wallpapers/6ae1f657239e448175b7d3177ryCBSh207.jpg", 16);
    App::new()
        .window_per_monitor(spacer::view)
        .window_per_monitor(island::view)
        .ipc("toggle_stat", toggle_stat)
        .run();
}
