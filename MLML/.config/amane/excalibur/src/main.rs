mod ui;
mod modules;
mod windows;

use amane::{ App };

use crate::windows::{
    bar, toggle,
    stats, 
};

fn main() {
    App::new()
        .window_per_monitor(bar::view)
        .ipc("toggle-launcher", toggle)
        .window(stats::view)
        .run();
}
