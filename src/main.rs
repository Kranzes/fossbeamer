use std::env;

fn main() -> wry::Result<()> {
    if let Some(url) = env::args().nth(1) {
        println!("Opening {}", url);
        fossbeamer::spawn_browser(url, None)
    } else {
        println!("BornScreen requires a URL as a parameter.");
        Ok(())
    }
}
