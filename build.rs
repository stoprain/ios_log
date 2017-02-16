extern crate gcc;

fn main() {
    println!("cargo:rustc-link-search=framework={}", "/System/Library/PrivateFrameworks");
    gcc::Config::new()
        .file("src/device.c")
        .flag("-F /System/Library/PrivateFrameworks")
        .flag("-F /System/Library/Frameworks")
        // .flag("-framework MobileDevice -framework CoreFoundation")
        .compile("libdevice.a");
}