use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Instant;

fn main() {
    let num_workers = 100;
    let items_per_worker = 100000;
    
    let data = Arc::new(Mutex::new(HashMap::new()));
    let mut handles = vec![];

    for worker_id in 0..num_workers {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            for j in 0..items_per_worker {
                let mut map = data.lock().unwrap();
                map.entry(j)
                .or_insert_with(Vec::new)
                .push(worker_id);
            }
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }
}