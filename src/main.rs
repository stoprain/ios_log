extern crate libc;

use libc::c_char;
use std::ffi::CStr;
use std::str;
use std::{thread, time};

#[link(name = "CoreFoundation", kind = "framework")]
#[link(name = "MobileDevice", kind = "framework")]

extern {
    fn CFRunLoopRun();
    fn connect(cb: extern fn(*const libc::c_char)) -> libc::c_int;
}

extern fn callback(a: *const libc::c_char) {
    let c_str: &CStr = unsafe { CStr::from_ptr(a) };
    let buf: &[u8] = c_str.to_bytes();
    let str_slice: &str = str::from_utf8(buf).unwrap();
    let str_buf: String = str_slice.to_owned();
    print!("{}", str_buf);
}

fn main() {
    unsafe { 
        connect(callback);
        CFRunLoopRun();
     };
}