use amane::{
    Canvas, Shape, shapes, Arc, Cap,
};

use crate::theme;

pub fn gauge(value: f32, w: f32, h: f32) -> Canvas {
    let theme = theme::current();

    Canvas::new()
        .width(w)
        .height(h)
        .shapes(shapes![
            Arc::new()
                .radius(w)
                .start(-150.0)
                .sweep(300.0)
                .stroke(5.0, theme.foreground)
                .cap(Cap::Round),
            Arc::new()
                .radius(w)
                .start(-150.0)
                .sweep(300.0 * (value / 100.0))
                .stroke(5.0, theme.accent)
                .cap(Cap::Round)
        ])
}
