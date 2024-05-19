import json


def generate_DGT_as_words(gdt_as_json: str, *, nasm_format=False) -> str:
    gdt = json.loads(gdt_as_json)
    gdt_as_words = ""

    for entry in gdt:
        if nasm_format:
            gdt_as_words += f"{entry['name']}: dw "

        if entry["type"] == "null":
            gdt_as_words += "0, 0, 0, 0\n"
        elif entry["type"] == "code" or entry["type"] == "data":
            base_address = int(entry["base_address"], 16)
            limit = int(entry["limit"], 16)

            base_address_parts = (
                base_address & 0xFFFF,
                (base_address >> 16) & 0xFF,
                (base_address >> 24) & 0xFF,
            )
            limit_parts = (limit & 0xFFFF, (limit >> 16) & 0xF)

            type_flag = (1 if entry["type"] == "code" else 0) << 3
            accessed = 1 if entry["accessed"] else 0
            type_field = None
            db_flag = None

            if entry["type"] == "code":
                conforming = (1 if entry["conforming"] else 0) << 2
                read_enabled = (1 if entry["read_enabled"] else 0) << 1
                type_field = type_flag | conforming | read_enabled | accessed

                db_flag = (1 if entry["operation_size"] == "32bit" else 0) << 2

            else:
                expands = (1 if entry["expands"] == "down" else 0) << 2
                write_enabled = (1 if entry["write_enabled"] else 0) << 1

                type_field = type_flag | expands | write_enabled | accessed

                db_flag = (1 if entry["upper_bound"] == "4gb" else 0) << 2

            present = (1 if entry["present"] else 0) << 3
            privilege_level = entry["privilege_level"] << 1
            system_segment = 1 if not entry["system_segment"] else 0

            first_prop_set = present | privilege_level | system_segment

            granularity = (1 if entry["granularity"] == "4kb" else 0) << 3
            long_mode = (1 if entry["64bit"] else 0) << 1

            second_prop_set = granularity | db_flag | long_mode | 0

            words = (
                limit_parts[0],
                base_address_parts[0],
                (((first_prop_set << 4) | type_field) << 8) | base_address_parts[1],
                (((base_address_parts[2] << 4) | second_prop_set) << 4)
                | limit_parts[1],
            )

            words = map(lambda word: f"0x{format(word, 'x').zfill(4)}", words)

            gdt_as_words += ", ".join(words) + "\n"
        else:
            raise Exception("Unkown Segment Type: " + str(entry))

    return gdt_as_words


if __name__ == "__main__":
    gdt = """
    [
        {   "name": "null_descriptor", "type": "null" },
        
        {   "name": "kernel_code", "base_address": "0", 
            "limit": "fffff", "granularity": "4kb", 
            "system_segment": false, "type": "code", 
            "accessed": false, "read_enabled": true, "conforming": false,
            "privilege_level": 0, "present": true, "operation_size": "32bit", "64bit": false  },
            
        {   "name": "kernel_data", "base_address": "0", 
            "limit": "fffff", "granularity": "4kb", 
            "system_segment": false, "type": "data", 
            "accessed": false, "expands": "up", "write_enabled": true,
            "privilege_level": 0, "present": true, "upper_bound": "4gb", "64bit": false  },
            
        {   "name": "userspace_code", "base_address": "0", 
            "limit": "fffff", "granularity": "4kb", 
            "system_segment": false, "type": "code", 
            "accessed": false, "read_enabled": true, "conforming": false,
            "privilege_level": 3, "present": true, "operation_size": "32bit", "64bit": false  },
            
        {   "name": "userspace_data", "base_address": "0", 
            "limit": "fffff", "granularity": "4kb", 
            "system_segment": false, "type": "data", 
            "accessed": false, "expands": "up", "write_enabled": true,
            "privilege_level": 3, "present": true, "upper_bound": "4gb", "64bit": false  }
    ]
    """

    print(generate_DGT_as_words(gdt, nasm_format=True))
