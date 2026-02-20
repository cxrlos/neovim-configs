use std::collections::HashMap;

fn main() {
    let mut data: HashMap<String, Vec<i32>> = HashMap::new();
    data.insert("first".to_string(), vec![1, 2, 3, 4, 5]);
    data.insert("second".to_string(), vec![10, 20, 30]);

    for (key, values) in &data {
        println!("{}:", key);
        for v in values {
            if *v > 5 {
                println!("  big: {}", v);
            } else {
                println!("  small: {}", v);
            }
        }
    }

    let result = process_data(&data);
    println!("{:?}", result);
}

fn process_data(input: &HashMap<String, Vec<i32>>) -> Vec<String> {
    let mut out = Vec::new();
    for (k, v) in input {
        out.push(format!("{}={}", k, v.iter().sum::<i32>()));
    }
    out
}
