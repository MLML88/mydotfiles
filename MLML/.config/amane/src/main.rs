mod bar;
mod clock;
mod battery;
mod wifi;
mod volume;
mod workspace;

use amane::{ App };

fn main() {
    App::new()
        .window_per_monitor(bar::view)
        .run();
}
