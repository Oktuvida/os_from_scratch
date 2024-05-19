import sys
import subprocess
import shutil
import os

ASM = "nasm"
CC = "gcc"
KERNEL_FLAGS = "-Wall -m32 -c -ffreestanding -fno-asynchronous-unwind-tables -fno-pie"

build_dir = "build"

bootstrap_file = os.path.join("src", "bootstrap", "bootstrap.asm")
bootstrap_output = os.path.join(build_dir, "bootstrap.o")

init_kernel_files = os.path.join("src", "kernel", "starter.asm")
init_kernel_output = os.path.join(build_dir, "starter.o")

kernel_file = os.path.join("src", "kernel", "main.c")
kernel_elf = os.path.join(build_dir, "kernel.elf")
kernel_bin = os.path.join(build_dir, "kernel.o")
kernel_image = os.path.join(build_dir, "kernel.img")

linker_file = os.path.join("src", "tools", "linker.ld")
linker_output = os.path.join(build_dir, "linker.elf")

def main() -> None:
    argv = sys.argv
    func = argv[-1]
    run_func(func)


def run_func(func: str) -> None:
    funcs = {"build_kernel": build_kernel, "run_kernel": run_kernel}
    if func not in funcs:
        print("FUNCTION NOT PRESENT")
        return
    funcs[func]()


def build_kernel() -> None:
    recreate_directory(build_dir)
    run_command(f"{ASM} -f bin {bootstrap_file} -o {bootstrap_output}")
    run_command(f"{ASM} -f elf32 {init_kernel_files} -o {init_kernel_output}")
    run_command(f"{CC} {KERNEL_FLAGS} {kernel_file} -o {kernel_elf}")
    run_command(f"ld -melf_i386 -T{linker_file} {init_kernel_output} {kernel_elf} -o {linker_output}")
    run_command(f"objcopy -O binary {linker_output} {kernel_bin}")
    create_kernel_image()


def run_kernel() -> None:
    run_command(f"qemu-system-x86_64 -s {kernel_image}")


def recreate_directory(path: str) -> None:
    if os.path.exists(path):
        shutil.rmtree(path)
    os.makedirs(path)


def create_kernel_image() -> None:
    with open(kernel_image, "wb") as img:
        with open(bootstrap_output, "rb") as bs:
            img.write(bs.read())

        img.seek(512)

        with open(kernel_bin, "rb") as kb:
            img.write(kb.read(512 * 5))

        img.seek(512*6)
        img.write(bytearray(512 * 2046))

def run_command(cmd: str) -> None:
    subprocess.run(cmd.split())


if __name__ == "__main__":
    main()
