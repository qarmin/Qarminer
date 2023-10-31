use std::fs;
use std::process::Command;

use walkdir::WalkDir;

fn main() {
    let args = std::env::args().collect::<Vec<_>>();
    let godot_path = &args[1];

    let mut gdfiles_to_check = Vec::new();
    for i in WalkDir::new("../IssueTesting").into_iter().flatten() {
        let full_name = i.path().display().to_string();
        if full_name.ends_with(".gd") {
            gdfiles_to_check.push(full_name);
        }
    }
    gdfiles_to_check.retain(|e| {
        !e.ends_with("Node.gd")
    });

    for file_to_check in gdfiles_to_check {
        let file_contents = fs::read_to_string(&file_to_check).unwrap();
        fs::write("../IssueTesting/Node.gd", file_contents).unwrap();

        if check_if_godot_crashes(godot_path) {
            println!("Godot crashes on file: {}", file_to_check);
        } else {
            println!("[NOT_CRASHES] on file: {}", file_to_check);
        }
    }
}

fn check_if_godot_crashes(godot_path: &str) -> bool {
    let output = Command::new("timeout")
        .args(&["-v", "60", godot_path, "--path", "../IssueTesting", "--headless", "--quit"])
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::piped())
        .spawn()
        .unwrap()
        .wait_with_output()
        .unwrap();
    let error = String::from_utf8_lossy(&output.stderr);
    let stdout = String::from_utf8_lossy(&output.stdout);
    let all = format!("{}\n{}", error, stdout);
    if all.contains("AddressSanitizer")
        || all.contains("Assertion failed")
        || all.contains("Program crashed with signal")
        || all.contains("Dumping the backtrace")
        || all.contains("Segmentation fault (core dumped)")
        || all.contains("Aborted (core dumped)")
        || all.contains("(core dumped)")
        || all.contains("Aborted")
        || all.contains("Assertion")
        || all.contains("ObjectDB instances leaked at exit")
        || all.contains("Killed")
        || all.contains("timeout: sending signal")
        || (all.contains("ERROR: LeakSanitizer:") && all.contains("#4 0x"))
    {
        return true;
    }
    false
}
