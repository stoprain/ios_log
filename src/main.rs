extern crate libc;

use libc::c_char;
use std::ffi::CStr;
use std::str;


#[link(name = "CoreFoundation", kind = "framework")]
#[link(name = "MobileDevice", kind = "framework")]

extern {
    fn connect(cb: extern fn(*const libc::c_char)) -> libc::c_int;
}

extern fn callback(a: *const libc::c_char) {
    let c_str: &CStr = unsafe { CStr::from_ptr(a) };
    let buf: &[u8] = c_str.to_bytes();
    let str_slice: &str = str::from_utf8(buf).unwrap();
    let str_buf: String = str_slice.to_owned();  // if necessary
    println!("callback {}", str_buf);
}

// #[link(name = "device", kind = "static")]
fn main() {
    unsafe { connect(callback) };
}





// #![allow(non_camel_case_types,dead_code)]
// extern crate core_foundation_sys;
// extern crate core_foundation;
// extern crate coreaudio_sys;

// extern crate libc;
// use libc::*;

// use core_foundation::string::CFString;
// use core_foundation_sys::string::CFStringRef;
// use core_foundation::base::TCFType;
// use std::{fs, mem, path, ptr, process, sync, thread};
// use coreaudio_sys::audio_unit::{CFSocketRef, CFSocketCallBackType, CFDataRef, CFSocketCallBack};

// #[repr(C)]
// #[derive(Copy, Clone, Debug)]
// pub struct am_device {
//     unknown0: [c_char; 16],
//     device_id: c_int,
//     product_id: c_int,
//     serial: *const c_char,
//     unknown1: c_int,
//     unknown2: [c_char; 4],
//     lockdown_conn: c_int,
//     unknown3: [c_char; 8],
// }

// unsafe impl Send for am_device {}

// pub const ADNCI_MSG_CONNECTED: c_uint = 1;
// pub const ADNCI_MSG_DISCONNECTED: c_uint = 2;
// pub const ADNCI_MSG_UNSUBSCRIBED: c_uint = 3;

// #[repr(C)]
// #[derive(Copy, Clone, Debug)]
// pub struct am_device_notification_callback_info {
//     pub dev: *mut am_device,
//     pub msg: ::std::os::raw::c_uint,
//     pub subscription: *mut am_device_notification,
// }

// #[repr(C)]
// #[derive(Copy, Clone)]
// pub struct am_device_notification {
//     unknown0: c_int,
//     unknown1: c_int,
//     unknown2: c_int,
//     callback: *const am_device_notification_callback,
//     unknown3: c_int,
// }

// pub type am_device_notification_callback = extern "C" fn(*mut am_device_notification_callback_info,
//                                                          *mut c_void);

// extern "C" fn DeviceNotificationCallback(info: *mut am_device_notification_callback_info, devices: *mut c_void) {
//     // println!("DeviceNotificationCallback {}", unsafe { (*info).msg });

//     let msg = unsafe { (*info).msg };
//     println!("msg {}", msg);
//     if msg == 1 {
//         let mut device = unsafe { (*info).dev };
//         if unsafe { AMDeviceConnect(device) } == 0 {
//             let paired = unsafe { AMDeviceIsPaired(device) };
//             let validate = unsafe { AMDeviceValidatePairing(device) };
//             if paired == 1 && validate == 0 {
//                 let session = unsafe { AMDeviceStartSession(device) };
//                 println!("AMDeviceStartSession {}", session);
//                 if session == 0 {
//                     let mut fd: c_int = 0;
//                     let service = unsafe { AMDeviceStartService(device, 
//                         CFString::from_static_string("com.apple.syslog_relay").as_concrete_TypeRef(), 
//                         &mut fd, std::ptr::null()) };
//                     println!("AMDeviceStartService {}", service);
//                     let a: CFSocketCallBack = SocketCallback;
//                     let s = unsafe { coreaudio_sys::audio_unit::CFSocketCreateWithNative(coreaudio_sys::audio_unit::kCFAllocatorDefault, 
//                         fd, 3, a, std::ptr::null()) };

//                     // println!("AMDeviceStartService");
//                 }
//             }
//         }
//     }
//     println!("DeviceNotificationCallback");

// }

// // pub type CFSocketCallBack =
// //     ::std::option::Option<extern "C" fn
// //                               (s: CFSocketRef, _type: CFSocketCallBackType,
// //                                address: CFDataRef,
// //                                data: *const ::libc::c_void,
// //                                info: *mut ::libc::c_void) -> ()>;

// extern "C" fn SocketCallback(s: CFSocketRef, _type: CFSocketCallBackType, address: CFDataRef, data: *const c_void, info: *mut c_void) {
//     println!("SocketCallback");
// }

// #[link(name = "MobileDevice", kind = "framework")]
// #[link(name = "CoreFoundation", kind = "framework")]
// // extern crate libc;

// // struct am_device {

// // }

// // extern "C" fn DeviceNotificationCallback() {

// // }

// extern "C" {
//     // fn double_input(input: libc::c_int) -> libc::c_int;
//     // fn connect();
//     // fn register_callback(cb: extern fn(i32)) -> i32;
//     // fn trigger_callback();
//     fn CFRunLoopRun();
//     pub fn AMDeviceNotificationSubscribe(callback: am_device_notification_callback,
//                                          unused0: c_uint,
//                                          unused1: c_uint,
//                                          dn_unknown3: c_uint,
//                                          notification: *mut *const am_device_notification)
//                                          -> c_int;
//     pub fn AMDeviceConnect(device: *const am_device) -> c_int;
//     pub fn AMDeviceIsPaired(device: *const am_device) -> c_int;
//     pub fn AMDeviceValidatePairing(device: *const am_device) -> c_int;
//     pub fn AMDeviceStartSession(device: *const am_device) -> c_int;
//     pub fn AMDeviceStartService(device: *const am_device,
//                                 service_name: CFStringRef,
//                                 socket_fd: *mut c_int,
//                                 unknown: *const c_int)
//                                 -> c_int;
// }

// fn main() {
//     // let input = 4;
//     // let output = unsafe { double_input(input) };
//     // println!("{} * 2 = {}", input, output);

//     // unsafe {
//     //     register_callback(callback);
//     //     trigger_callback(); // Triggers the callback.
//     // }
//     unsafe {
//         //AMDeviceNotificationSubscribe();
//         let notify: *const am_device_notification = std::ptr::null();
//         AMDeviceNotificationSubscribe(DeviceNotificationCallback, 0, 0, 0, 
//             &mut notify.into());
//         CFRunLoopRun();
//     }

// }

// // extern fn callback(a: i32) {
// // //     println!("I'm called from C with value {0}", a);
// // }