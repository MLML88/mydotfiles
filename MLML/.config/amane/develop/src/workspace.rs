use amane::{
    Color, Full, Parent, Rectangle,
    Row, Service, Text, Widget,
    Workspace, Workspaces, Center
};

pub fn view() -> Rectangle {
    let workspaces = Workspaces::read();
    let mut buttons: Vec<Box<dyn Widget>> = Vec::new();

    for workspace in workspaces.list() {
        buttons.push(Box::new(button(workspace)));
    }

    Rectangle::new()
        .width(90.0)
        .height(Parent)
        .radius(Full)
        .fill(Color::BLACK)
        .align_child(Center, Center)
        .child(
            Row::new(buttons)
        )
}

fn button(workspace: &Workspace) -> Rectangle {
    let fill = if workspace.focused() {
        Color::BLUE
    } else if workspace.urgent() {
        Color::RED
    } else {
        Color::BLACK
    };

    let id = workspace.id();

    Rectangle::new()
        .width(30.0)
        .height(Parent)
        .radius(Full)
        .fill(fill)
        .align_child(Center, Center)
        .on_click(move |_| Workspaces::focus(id))
        .child(Text::new(workspace.index().to_string()).color(Color::WHITE))
}
