extern crate core_foundation_sys;
extern crate core_foundation;

use core_foundation::string::CFString;
use core_foundation_sys::string::CFStringRef;
use core_foundation::base::TCFType;

#[repr(C)]
struct am_device {
    unknown0: [char; 16],
    device_id: u32,
    product_id: u32,
    serial: *mut u32,
    unknown1: u32,
    unknown2: [char; 4],
    lockdown_conn: u32,
    unknown3: [char; 8],
}

struct am_device_notification_callback_info {
    dev: *mut am_device,
    msg: u32,
}

struct am_device_notification {
    unknown0: u32,
    unknown1: u32,
    unknown2: u32,
    callback: u32,
    unknown3: u32,
}

extern "C" fn DeviceNotificationCallback(info: *mut am_device_notification_callback_info) {
    // println!("DeviceNotificationCallback {}", unsafe { (*info).msg });

    let msg = unsafe { (*info).msg };
    println!("msg {}", msg);
    if msg == 1 {
        let mut device = unsafe { (*info).dev };
        if unsafe { AMDeviceConnect(device) } == 0 {
            let a = unsafe { AMDeviceIsPaired(device) };
            let b = unsafe { AMDeviceValidatePairing(device) };
            if a == 1 && b == 0 {
                if unsafe { AMDeviceStartSession(device) } == 0 {
                    let a1 = 0;
                    let r1 = a1 as *mut u32;
                    let a2 = 0;
                    let r2 = a2 as *mut u32;
                    let s = unsafe { CFString::new("com.apple.syslog_relay").as_concrete_TypeRef() };
                    let service = unsafe { AMDeviceStartService(device, s, r1, r2) };
                    println!("AMDeviceStartService {}", service);
                }
            }
        }
    }

}

#[link(name = "MobileDevice", kind = "framework")]
#[link(name = "CoreFoundation", kind = "framework")]
// extern crate libc;

// struct am_device {

// }

// extern "C" fn DeviceNotificationCallback() {

// }

extern {
    // fn double_input(input: libc::c_int) -> libc::c_int;
    // fn connect();
    // fn register_callback(cb: extern fn(i32)) -> i32;
    // fn trigger_callback();
    fn CFRunLoopRun();
    fn AMDeviceNotificationSubscribe(callback: extern fn(info: *mut am_device_notification_callback_info), 
        unused0: u32, unused1: u32, dn_unknown3: u32, 
        notification: am_device_notification) -> i32;
    fn AMDeviceConnect(device: *mut am_device) -> i32;
    fn AMDeviceStartService(device: *mut am_device, service_name: CFStringRef, handle: *mut u32, unknown: *mut u32) -> i32;
    fn AMDeviceStartSession(device: *mut am_device) -> i32;
    fn AMDeviceIsPaired(device: *mut am_device) -> i32;
    fn AMDeviceValidatePairing(device: *mut am_device) -> i32;
}

fn main() {
    // let input = 4;
    // let output = unsafe { double_input(input) };
    // println!("{} * 2 = {}", input, output);

    // unsafe {
    //     register_callback(callback);
    //     trigger_callback(); // Triggers the callback.
    // }
    unsafe {
        //AMDeviceNotificationSubscribe();
        let a = am_device_notification { unknown0: 0, unknown1: 0, unknown2: 0, callback: 0, unknown3: 0 };
        AMDeviceNotificationSubscribe(DeviceNotificationCallback, 0, 0, 0, a);
        CFRunLoopRun();
    }

}

// extern fn callback(a: i32) {
// //     println!("I'm called from C with value {0}", a);
// }