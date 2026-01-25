import yaml
import os
import sys

def base24_to_base16(data):
    # Copy non-palette metadata and update system
    result = {k: v for k, v in data.items() if k != "palette"}
    result["system"] = "base16"
    # Extract only base00 to base0F (0..15) from palette
    palette16 = {k: v for k, v in data["palette"].items() if k.startswith("base") and int(k[4:], 16) <= 15}
    result["palette"] = palette16
    return result

def main():
    if len(sys.argv) != 3:
        print("Usage: python base24_to_base16.py <input_file> <output_dir>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_dir = sys.argv[2]
    filename = os.path.splitext(os.path.basename(input_file))[0]
    out_file = os.path.join(output_dir, f"{filename}-converted.yml")

    with open(input_file, "r") as infile:
        data = yaml.safe_load(infile)
    outdata = base24_to_base16(data)

    os.makedirs(output_dir, exist_ok=True)
    with open(out_file, "w") as outfile:
        yaml.dump(outdata, outfile, default_flow_style=False, sort_keys=False)

    print(f"Converted Base16 file written to: {out_file}")

if __name__ == "__main__":
    main()
