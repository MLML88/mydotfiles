mod components;
mod windows;
mod modules;

use amane::{ App };

use crate::windows::{
    spacer, island
};

fn main() {
    App::new()
        .window_per_monitor(spacer::view)
        .window_per_monitor(island::view)
        .run();
}
