"""Generates Swift message structs from tools/mavlink_defs.json.

mavlink_defs.json is dumped from Mission Planner's MAVLink.dll by
dump_mavlink_defs.ps1, so the generated code has exactly Mission Planner's
message IDs, CRC_EXTRA bytes, payload lengths and wire-order field offsets.

Run:  python -I tools/gen_swift.py
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "Packages", "MAVLinkKit", "Sources", "MAVLinkKit", "Generated",
                   "MAVLinkMessages.swift")

SWIFT = {"Byte": ("UInt8", 1, "uint8"), "SByte": ("Int8", 1, "int8"),
         "UInt16": ("UInt16", 2, "uint16"), "Int16": ("Int16", 2, "int16"),
         "UInt32": ("UInt32", 4, "uint32"), "Int32": ("Int32", 4, "int32"),
         "UInt64": ("UInt64", 8, "uint64"), "Int64": ("Int64", 8, "int64"),
         "Single": ("Float", 4, "float"), "Double": ("Double", 8, "double")}

KEYWORDS = {"associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import",
            "init", "inout", "internal", "let", "open", "operator", "private", "protocol", "public",
            "rethrows", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue",
            "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat",
            "return", "switch", "where", "while", "as", "catch", "false", "is", "nil", "super", "self",
            "Self", "throw", "throws", "true", "try", "Type", "Protocol", "any", "some"}


def camel(name):
    """snake_case -> camelCase. MAVLinkKitTests.camel() uses the identical rule."""
    parts = [p for p in name.split("_") if p]
    return parts[0] + "".join(p[:1].upper() + p[1:] for p in parts[1:])


def ident(name):
    c = camel(name)
    return f"`{c}`" if c in KEYWORDS else c


def type_name(msg_name):
    return "".join(p[:1].upper() + p[1:].lower() for p in msg_name.split("_") if p)


def main():
    defs = json.load(open(os.path.join(HERE, "mavlink_defs.json"), encoding="utf-8"))
    defs.sort(key=lambda m: m["id"])
    L = []
    w = L.append
    w("// GENERATED FILE - do not edit. Regenerate with: python -I tools/gen_swift.py")
    w("//")
    w("// REA Parity Source: Mission Planner MAVLink.dll (MAVLink.MAVLINK_MESSAGE_INFOS and the")
    w("// mavlink_*_t structs), dumped by tools/dump_mavlink_defs.ps1. Field order is wire order")
    w("// (sorted by size), offsets and CRC_EXTRA bytes are taken verbatim from that assembly.")
    w(f"// {len(defs)} messages.")
    w("")
    w("// swiftlint:disable all")
    w("")
    w("/// Namespace for all generated MAVLink message types, e.g. `MAV.Heartbeat`.")
    w("public enum MAV {}")
    w("")
    w("public enum MAVLinkMessages {")
    w("    /// Message table lookup (CRC_EXTRA, lengths). `nil` for IDs Mission Planner doesn't know.")
    w("    public static func info(for id: UInt32) -> MAVMessageInfo? {")
    w("        switch id {")
    for m in defs:
        w(f"        case {m['id']}: return MAV.{type_name(m['name'])}.mavInfo")
    w("        default: return nil")
    w("        }")
    w("    }")
    w("")
    w("    /// Decodes a payload into its typed message struct. Short (v2-truncated) payloads are zero-extended.")
    w("    public static func decode(id: UInt32, payload: [UInt8]) -> MAVLinkMessage? {")
    w("        switch id {")
    for m in defs:
        t = type_name(m["name"])
        w(f"        case {m['id']}: return MAV.{t}(payload: MAVLinkPayloadReader(payload, length: {m['length']}))")
    w("        default: return nil")
    w("        }")
    w("    }")
    w("}")
    for m in defs:
        t = type_name(m["name"])
        fields = m["fields"]
        w("")
        w(f"/// {m['name']} (#{m['id']})")
        w("extension MAV {")
        w(f"    public struct {t}: MAVLinkMessage, Equatable {{")
        w(f"        public static let mavInfo = MAVMessageInfo(id: {m['id']}, name: \"{m['name']}\", "
          f"crcExtra: {m['crc']}, minLength: {m['minlength']}, length: {m['length']})")
        for f in fields:
            st = SWIFT[f["type"]][0]
            ext = "  // extension field" if f["offset"] >= m["minlength"] else ""
            if f["array"]:
                w(f"        public var {ident(f['name'])}: [{st}]{ext}")
            else:
                w(f"        public var {ident(f['name'])}: {st}{ext}")
        # memberwise init with defaults
        params = []
        for f in fields:
            st = SWIFT[f["type"]][0]
            if f["array"]:
                params.append(f"{ident(f['name'])}: [{st}] = [{st}](repeating: 0, count: {f['array']})")
            else:
                params.append(f"{ident(f['name'])}: {st} = 0")
        w("")
        w(f"        public init({', '.join(params)}) {{")
        for f in fields:
            n = ident(f["name"])
            w(f"            self.{n.strip('`')} = {n}")
        w("        }")
        w("")
        w("        public init(payload p: MAVLinkPayloadReader) {")
        for f in fields:
            st, size, rd = SWIFT[f["type"]]
            n = camel(f["name"])
            if f["array"]:
                w(f"            self.{n} = (0..<{f['array']}).map {{ p.{rd}({f['offset']} + $0 * {size}) }}")
            else:
                w(f"            self.{n} = p.{rd}({f['offset']})")
        w("        }")
        w("")
        w("        public func encode(into w: inout MAVLinkPayloadWriter) {")
        for f in fields:
            st, size, rd = SWIFT[f["type"]]
            n = camel(f["name"])
            if f["array"]:
                w(f"            for k in 0..<Swift.min({f['array']}, self.{n}.count) {{ w.put(self.{n}[k], {f['offset']} + k * {size}) }}")
            else:
                w(f"            w.put(self.{n}, {f['offset']})")
        w("        }")
        w("    }")
        w("}")
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(L) + "\n")
    print(f"wrote {len(defs)} message types to {os.path.normpath(OUT)}")
    names = [type_name(m["name"]) for m in defs]
    assert len(set(names)) == len(names), "duplicate type names"


if __name__ == "__main__":
    main()
