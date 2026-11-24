mod components;
mod windows;
mod modules;

use amane::{ App };

use crate::windows::{
    spacer, island, toggle_stat,
};

fn main() {
    App::new()
        .window_per_monitor(spacer::view)
        .window_per_monitor(island::view)
        .ipc("toggle_stat", toggle_stat)
        .run();
}
