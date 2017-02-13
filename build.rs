extern crate gcc;

fn main() {
    // gcc::Config::new().file("src/double.c").compile("libdouble.a");
    println!("cargo:rustc-link-search=framework={}", "/System/Library/PrivateFrameworks");
}