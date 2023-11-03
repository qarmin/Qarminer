use std::fs;
use std::process::Command;

use walkdir::WalkDir;
use rayon::prelude::*;

const NUMBER_OF_STEPS: usize = 1;

const DISABLED_FILES: &[&str] = &[
    "../IssueTesting/66754.gd", // X11 thing, cannot reproduce with headless
    "../IssueTesting/53558.gd", // 3.x branch
    //
    // "../IssueTesting/53604.gd",
    // "../IssueTesting/66002.gd",
    // "../IssueTesting/67589.gd",
    // "../IssueTesting/71150.gd",
    // "../IssueTesting/83927.gd",
    // "../IssueTesting/84152.gd",
    // "../IssueTesting/84178.gd",
    // "../IssueTesting/84202.gd",
    // "../IssueTesting/53775.gd",
    // "../IssueTesting/61507.gd",
    // "../IssueTesting/69258.gd",
    // "../IssueTesting/71863.gd",
    // "../IssueTesting/73202.gd",
    // "../IssueTesting/66758.gd",
    // "../IssueTesting/60325.gd",
    // "../IssueTesting/60297.gd",
    // "../IssueTesting/84176.gd",
    // "../IssueTesting/60337.gd",
    // "../IssueTesting/60338.gd",
    // "../IssueTesting/60492.gd",
    // "../IssueTesting/60324.gd",
    // "../IssueTesting/60357.gd",
];

fn main() {
    let args = std::env::args().collect::<Vec<_>>();
    let godot_path = &args[1];

    // Clears temp folder
    let _ =  fs::remove_dir_all("temp");
    fs::create_dir_all("temp").unwrap();

    let gdfiles_to_check = collect_files_to_check();
    check_files_in_parrallel(godot_path, gdfiles_to_check);
}

fn check_files_in_parrallel(godot_path: &str, gdfiles_to_check: Vec<String>) {
    gdfiles_to_check.into_par_iter().for_each(|file_to_check| {
        let new_temp_dir_name = format!("temp/{}", rand::random::<u64>());
        fs::create_dir_all(&new_temp_dir_name).unwrap();

        let file_contents = fs::read_to_string(&file_to_check).unwrap();
        fs::write(format!("{}/Node.gd", new_temp_dir_name), file_contents).unwrap();
        fs::copy("../IssueTesting/project.godot", format!("{}/project.godot", new_temp_dir_name)).unwrap();
        fs::copy("../IssueTesting/Node.tscn", format!("{}/Node.tscn", new_temp_dir_name)).unwrap();

        let mut broken_counter = 0;
        let mut non_broken_counter = 0;
        for _ in 0..NUMBER_OF_STEPS {

            if check_if_godot_crashes(godot_path, &new_temp_dir_name) {
                broken_counter += 1;
            } else {
                non_broken_counter += 1;
            }
        }

        if non_broken_counter == NUMBER_OF_STEPS {
            println!("[NOT_CRASHES] on file: {}", file_to_check);
        } else if broken_counter != NUMBER_OF_STEPS {
            println!("Sometimes on file: {}", file_to_check);
            println!("\"{file_to_check}\",");
        } else {
            println!("Always crashes on file: {}", file_to_check);
            println!("\"{file_to_check}\",");
        }
        fs::remove_dir_all(&new_temp_dir_name).unwrap();
    });
}


fn collect_files_to_check() -> Vec<String> {
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
    gdfiles_to_check.retain(|e|{
        !DISABLED_FILES.contains(&e.as_str())
    });
    gdfiles_to_check
}

fn check_if_godot_crashes(godot_path: &str, path: &str) -> bool {
    let mut command = Command::new("timeout");
    let command = command
        .args(&["-v", "60", godot_path, "--path", path, "--quit"]);
    // let command = command.args(["--rendering-dirver", "opengl3"]);
    let command = command.args(["--headless"]);

    let output = command
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
        || all.contains("timeout: the monitored command dumped core")
        || (all.contains("ERROR: LeakSanitizer:") && all.contains("#4 0x"))
    {
        return true;
    }
    println!("{path} - {all}");
    false
}
