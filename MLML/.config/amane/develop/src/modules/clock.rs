use std::time::Duration;

use amane::{
    Service, Text, Rectangle, Parent, 
    Color, Center,
};

use crate::components::{
   pill, 
};

const FORMAT: &str = "date '+%I:%M %p'";

pub struct Clock {
    time: String,
}

impl Service for Clock {
    fn new() -> Self {
        Self { time: amane::output(FORMAT) }
    }

    fn interval() -> Duration {
        Duration::from_secs(1)
    }

    fn update(&mut self) -> bool {
        let time = amane::output(FORMAT);
        let changed = time != self.time;
        self.time = time;
        changed
    }
}

pub fn view() -> Rectangle {
    let clock = Clock::read();
    let content = Text::new(&clock.time)
        .size(18.0)
        .color(Color::WHITE);

    pill(content, Parent, Parent)
        .align_child(Center, Center)
}
