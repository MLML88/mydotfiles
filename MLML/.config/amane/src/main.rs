mod bar;
mod clock;
mod battery;

use amane::{ App };

fn main() {
    App::new().window(bar::view).run();
}
