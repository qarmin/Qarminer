use std::fs;
use std::process::Command;

use walkdir::WalkDir;

fn main() {
    let mut gdfiles_to_check = Vec::new();
    for i in WalkDir::new("../IssueTesting").into_iter().flatten() {
        let full_name = i.path().display().to_string();
        if full_name.ends_with(".gd") {
            gdfiles_to_check.push(full_name);
        }
    }

    for file_to_check in gdfiles_to_check {
        let file_contents = fs::read_to_string(&file_to_check).unwrap();
        fs::write("../IssueTesting/Node.gd", file_contents).unwrap();

        // Run Godot on IssueTestingFolder and check if crashes
    }
    dbg!(&gdfiles_to_check);
}

const PROBLEMATIC_ERRORS: [&str; 2] = [
    "AddressSanitizer",
    "ERROR: _get_node: Condition ' !node ' is true. returned: null",
];

fn check_if_godot_crashes() {
    let output = Command::new("/home/rafal/Downloads/A/godot4")
        .args(&["--path", "../IssueTesting"])
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
        dbg!(all);
    }
    // if file_contents.find("ERROR: LeakSanitizer:") != -1:
    // if file_contents.find("#4 0x") != -1:
    // file_contents.find("Program crashed with signal") != -1
    // or file_contents.find("Dumping the backtrace") != -1
    // or file_contents.find("Segmentation fault (core dumped)") != -1
    // or file_contents.find("Aborted (core dumped)") != -1
    // or file_contents.find("(core dumped)") != -1
    // or file_contents.find("Aborted") != -1
    // or file_contents.find("Assertion") != -1
}
