import sys
import subprocess
import shutil
import os

ASM = "nasm"

build_dir = "build"
bootstrap_file = os.path.join("src", "bootstrap", "bootstrap.asm")
bootstrap_output = os.path.join(build_dir, "bootstrap.o")

kernel_file = os.path.join("src", "kernel", "simple_kernel.asm")
kernel_output = os.path.join(build_dir, "simple_kernel.o")
kernel_image = os.path.join(build_dir, "kernel.img")


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
    run_command(f"{ASM} -f bin {kernel_file} -o {kernel_output}")
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

        with open(kernel_output, "rb") as kf:
            img.write(kf.read(512 * 5))


def run_command(cmd: str) -> None:
    subprocess.run(cmd.split())


if __name__ == "__main__":
    main()
