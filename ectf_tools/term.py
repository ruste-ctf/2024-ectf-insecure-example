import serial
import argparse

def list(args):
    ser = serial.Serial(
        port=args.port,
        baudrate=115200,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
    )

    output = ""
    while True:
        char = ser.read()
        char = char.decode("utf-8")
        print(char, end='')

# Main function
def main():
    parser = argparse.ArgumentParser(
        prog="eCTF Term Host Tool",
        description="Connect to the raw term of the controller",
    )

    parser.add_argument(
        "-p", "--port", required=True, help="Serial device of the AP"
    )

    args = parser.parse_args()

    list(args)


if __name__ == "__main__":
    main()

