#[repr(C)]
struct am_device {
    unknown0: [u32; 16],
    device_id: u32,
    product_id: u32,
    serial: *mut u32,
    unknown1: u32,
    unknown2: [u32; 4],
    lockdown_conn: u32,
    unknown3: [u32; 8],
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
    println!("DeviceNotificationCallback {}", unsafe { (*info).msg });
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