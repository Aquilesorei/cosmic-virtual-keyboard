// Mandatory COSMIC imports
use cosmic::app::Core;
use cosmic::iced::{
    platform_specific::shell::commands::popup::{destroy_popup, get_popup},
    window::Id,
    Limits,
};
use cosmic::iced_runtime::core::window;
use cosmic::{Action, Element, Task};

// Widgets we're going to use
use cosmic::widget::{list_column, settings, text};
use cosmic::widget::button;

// Standard library imports
use std::process::{Command, Stdio};

// Every COSMIC Application and Applet MUST have an ID
const ID: &str = "io.github.aquilesorei.Spaceboard";

/*
 * Every COSMIC model must be a struct data type.
 * Mandatory fields for a COSMIC Applet are core and popup.
 * Core is the core settings that allow it to interact with COSMIC
 * and popup, as you'll see later, is the field that allows us to open
 * and close the applet.
 * 
 * We also track the keyboard state to show the correct status.
 */
#[derive(Default)]
pub struct Window {
    core: Core,
    popup: Option<Id>,
    keyboard_running: bool,
}

#[derive(Clone, Debug)]
pub enum Message {
    TogglePopup,           // Mandatory for open and close the applet
    PopupClosed(Id),       // Mandatory for the applet to know if it's been closed
    ToggleKeyboard,        // Toggle the virtual keyboard on/off
    ShowKeyboard,          // Show the keyboard
    HideKeyboard,          // Hide the keyboard
    KeyboardStateChanged(bool), // Update keyboard state
}

impl Window {
    /// Check if wvkbd is currently running
    fn is_keyboard_running() -> bool {
        Command::new("pgrep")
            .arg("wvkbd")
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()
            .map(|status| status.success())
            .unwrap_or(false)
    }

    /// Start the virtual keyboard
    async fn start_keyboard() -> Result<(), String> {
        std::process::Command::new("wvkbd-mobintl")
            .arg("-L")
            .arg("200")
            .spawn()
            .map_err(|e| format!("Failed to start keyboard: {}", e))?;
        Ok(())
    }

    /// Hide the virtual keyboard by sending SIGUSR1
    async fn hide_keyboard() -> Result<(), String> {
        std::process::Command::new("pkill")
            .args(["-SIGUSR1", "wvkbd"])
            .output()
            .map_err(|e| format!("Failed to hide keyboard: {}", e))?;
        Ok(())
    }

    /// Show the virtual keyboard by sending SIGUSR2
    async fn show_keyboard() -> Result<(), String> {
        std::process::Command::new("pkill")
            .args(["-SIGUSR2", "wvkbd"])
            .output()
            .map_err(|e| format!("Failed to show keyboard: {}", e))?;
        Ok(())
    }

    /// Kill the virtual keyboard process
    async fn kill_keyboard() -> Result<(), String> {
        std::process::Command::new("pkill")
            .arg("wvkbd")
            .output()
            .map_err(|e| format!("Failed to kill keyboard: {}", e))?;
        Ok(())
    }
}

impl cosmic::Application for Window {
    /*
     * Executors are a mandatory thing for both COSMIC Applications and Applets.
     * They're basically what allows for multi-threaded async operations for things that
     * may take too long and block the thread the GUI is running on. This is also where
     * Tasks take place.
     */
    type Executor = cosmic::SingleThreadExecutor;
    type Flags = (); // Honestly not sure what these are for.
    type Message = Message; // These are setting the application messages to our Message enum
    const APP_ID: &'static str = ID; // This is where we set our const above to the actual ID

    // Setup the immutable core functionality.
    fn core(&self) -> &Core {
        &self.core
    }

    // Set up the mutable core functionality.
    fn core_mut(&mut self) -> &mut Core {
        &mut self.core
    }

    // Initialize the applet
    fn init(core: Core, _flags: Self::Flags) -> (Self, Task<Action<Self::Message>>) {
        let window = Window {
            core,
            keyboard_running: Self::is_keyboard_running(),
            ..Default::default()
        };

        (window, Task::none())
    }

    // Create what happens when the applet is closed
    fn on_close_requested(&self, id: window::Id) -> Option<Message> {
        Some(Message::PopupClosed(id))
    }

    // Here is the update function, it's the one that handles all the messages that
    // are passed within the applet.
    fn update(&mut self, message: Self::Message) -> Task<Action<Self::Message>> {
        match message {
            // Handle the TogglePopup message
            Message::TogglePopup => {
                // Update keyboard state when opening popup
                self.keyboard_running = Self::is_keyboard_running();
                
                // Close the popup
                return if let Some(popup_id) = self.popup.take() {
                    destroy_popup(popup_id)
                } else {
                    // Create and "open" the popup
                    let new_id = Id::unique();
                    self.popup.replace(new_id);
                    let mut popup_settings = self.core.applet.get_popup_settings(
                        self.core.main_window_id().unwrap(),
                        new_id,
                        None,
                        None,
                        None
                    );
                    popup_settings.positioner.size_limits = Limits::NONE
                        .max_width(300.0)
                        .min_width(250.0)
                        .min_height(150.0)
                        .max_height(300.0);

                    get_popup(popup_settings)
                }
            }
            // Unset the popup field after it's been closed
            Message::PopupClosed(popup_id) => {
                if self.popup.as_ref() == Some(&popup_id) {
                    self.popup = None;
                }
            }
            Message::ToggleKeyboard => {
                if self.keyboard_running {
                    self.keyboard_running = false;
                    return Task::perform(Self::kill_keyboard(), |_| Message::KeyboardStateChanged(false)).map(Action::App);
                } else {
                    self.keyboard_running = true;
                    return Task::perform(Self::start_keyboard(), |_| Message::KeyboardStateChanged(true)).map(Action::App);
                }
            }
            Message::ShowKeyboard => {
                if self.keyboard_running {
                    return Task::perform(Self::show_keyboard(), |_| Message::KeyboardStateChanged(true)).map(Action::App);
                } else {
                    self.keyboard_running = true;
                    return Task::perform(Self::start_keyboard(), |_| Message::KeyboardStateChanged(true)).map(Action::App);
                }
            }
            Message::HideKeyboard => {
                if self.keyboard_running {
                    return Task::perform(Self::hide_keyboard(), |_| Message::KeyboardStateChanged(true)).map(Action::App);
                }
            }
            Message::KeyboardStateChanged(running) => {
                self.keyboard_running = running;
            }
        }

        Task::none()
    }

    /*
     * For an applet, the view function describes what an applet looks like. There's a
     * secondary view function (view_window) that shows the widgets in the popup when it's
     * opened.
     */
    fn view(&self) -> Element<'_, Self::Message> {
        let icon_name = if self.keyboard_running {
            "input-keyboard-symbolic"
        } else {
            "input-keyboard-symbolic"  // Same icon for now, could be different
        };

        self.core
            .applet
            .icon_button(icon_name)
            .on_press(Message::TogglePopup)
            .into()
    }

    // The actual GUI window for the applet. It's a popup.
    fn view_window(&self, _id: Id) -> Element<'_, Self::Message> {
        let status_text = if self.keyboard_running {
            "Virtual keyboard is running"
        } else {
            "Virtual keyboard is not running"
        };

        let toggle_button_text = if self.keyboard_running {
            "Turn Off Keyboard"
        } else {
            "Turn On Keyboard"
        };

        let content_list = list_column()
            .padding(5)
            .spacing(10)
            .add(settings::item(
                "Status",
                text(status_text),
            ))
            .add(settings::item(
                "Control",
button::standard(toggle_button_text)
                    .on_press(Message::ToggleKeyboard),
            ));

        // Add show/hide buttons if keyboard is running
        let content_list = if self.keyboard_running {
            content_list
                .add(settings::item(
                    "Show",
                    button::standard("Show Keyboard")
                        .on_press(Message::ShowKeyboard),
                ))
                .add(settings::item(
                    "Hide",
                    button::standard("Hide Keyboard")
                        .on_press(Message::HideKeyboard),
                ))
        } else {
            content_list
        };

        self.core.applet.popup_container(content_list).into()
    }
}