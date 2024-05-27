import json


def generate_IDT_as_words(idt_as_json: str, *, nasm_format=False) -> str:
    idt = json.loads(idt_as_json)
    idt_as_words = ""

    for entry in idt:
        if nasm_format:
            idt_as_words += "dw "

        present = (1 if entry["present"] else 0) << 7
        dpl = entry["dpl"] << 6
        size = (1 if entry["gate_descriptor_size"] == "32-bit" else 0) << 3
        gate_type = 0 if entry["interrupt_gate"] else 1

        byte_five = present | dpl | (0 << 11) | size | (1 << 2) | (1 << 1) | gate_type

        word_three = "0x" + format(byte_five, "x").zfill(2) + "00"

        idt_as_words += (
            entry["isr_routine_name"]
            + ", "
            + str(entry["isr_segment_selector"])
            + ", "
            + word_three
            + ", 0x0000"
            + "\n"
        )

    return idt_as_words


if __name__ == "__main__":

    routines = [
        f'{{"isr_routine_name": "isr_{idx}", "isr_segment_selector": 8, "present": true, "dpl": 0, "gate_descriptor_size": "32-bit", "interrupt_gate": true }}'
        for idx in range(49)
    ]

    idt = f'[{",".join(routines)}]'
    print(generate_IDT_as_words(idt, nasm_format=True))
