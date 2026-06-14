#!/usr/bin/env python3
# /* ---- 💫 https://github.com/seyboo/Sway-Dots 💫 ---- */
# Parser for Sway bindsym keybind lines.
# Reads ~/.config/sway/configs/Keybinds.conf (and optional user/laptop overlays).
# Outputs one "KEYS — description" line per binding for rofi display.
# Format parsed: bindsym [--flags] <KEYS> <action...> [# comment]

import sys
import re
import os


def normalize_combo(combo: str) -> str:
    return combo.replace(" ", "").replace("\t", "").lower()


def substitute_mod(keys: str) -> str:
    """Replace $mod/$mainMod with SUPER (Mod4 = SUPER in sway)."""
    keys = re.sub(r'\$mainMod\b', 'SUPER', keys, flags=re.IGNORECASE)
    keys = re.sub(r'\$mod\b', 'SUPER', keys, flags=re.IGNORECASE)
    return keys


def parse_bindsym_line(raw_line: str):
    """
    Parse a sway bindsym line.
    Returns (combo_key, keys_display, description) or None if not a bindsym.

    Accepted forms:
      bindsym [--flags...] KEYS action... [# inline comment]
      bindsym+Mod KEYS action...
    """
    # Strip inline comments to extract a trailing description
    inline_comment = ""
    comment_match = re.search(r'\s+#\s*(.+)$', raw_line)
    if comment_match:
        inline_comment = comment_match.group(1).strip()
        raw_line = raw_line[:comment_match.start()]

    line = raw_line.strip()

    # Must start with bindsym (including bindsym+Mod variants)
    m = re.match(r'^bindsym(?:\+\S+)?\s+(.*)', line, re.IGNORECASE)
    if not m:
        return None

    rest = m.group(1).strip()

    # Skip optional flags like --no-repeat, --locked, --release, --inhibited, --border, etc.
    while rest.startswith('--'):
        rest = re.sub(r'^--\S+\s*', '', rest)

    if not rest:
        return None

    # First token is the key combination
    parts = rest.split(None, 1)
    keys = parts[0]
    action = parts[1].strip() if len(parts) > 1 else ""

    # Substitute variable references
    keys = substitute_mod(keys)
    action = substitute_mod(action)

    # Build human description: prefer inline comment, then derive from action
    if inline_comment:
        description = inline_comment
    elif action:
        description = _derive_description(action)
    else:
        description = ""

    # Normalize combo for deduplication key
    combo_key = normalize_combo(keys)

    return combo_key, keys, description


def _derive_description(action: str) -> str:
    """
    Derive a human-readable description from a sway action string.
    Common dispatchers are mapped to friendly text.
    """
    # swaymsg exec / exec_always
    exec_m = re.match(r'^exec(?:_always)?\s+(.*)', action, re.IGNORECASE)
    if exec_m:
        cmd = exec_m.group(1).strip().lstrip('"').rstrip('"')
        # Shorten long commands to just the binary name + first arg
        tokens = cmd.split()
        if tokens:
            bin_name = os.path.basename(tokens[0].lstrip('$'))
            extra = " ".join(tokens[1:2]) if len(tokens) > 1 else ""
            if extra and not extra.startswith('-'):
                return f"exec {bin_name} {extra}"
            return f"exec {bin_name}"
        return f"exec {cmd}"

    # focus / move / layout / etc.
    FRIENDLY = {
        'focus left': 'focus left',
        'focus right': 'focus right',
        'focus up': 'focus up',
        'focus down': 'focus down',
        'focus parent': 'focus parent',
        'focus child': 'focus child',
        'focus output left': 'focus output left',
        'focus output right': 'focus output right',
        'move left': 'move window left',
        'move right': 'move window right',
        'move up': 'move window up',
        'move down': 'move window down',
        'move to workspace': 'move to workspace',
        'workspace': 'switch workspace',
        'layout toggle': 'toggle layout',
        'layout tabbed': 'layout tabbed',
        'layout stacking': 'layout stacking',
        'layout splith': 'layout splith',
        'layout splitv': 'layout splitv',
        'fullscreen': 'toggle fullscreen',
        'floating toggle': 'toggle floating',
        'floating enable': 'enable floating',
        'floating disable': 'disable floating',
        'kill': 'close window',
        'reload': 'reload sway config',
        'exit': 'exit sway',
        'resize': 'resize window',
        'split h': 'split horizontal',
        'split v': 'split vertical',
        'split toggle': 'toggle split',
        'sticky toggle': 'toggle sticky',
        'scratchpad show': 'show scratchpad',
        'move scratchpad': 'move to scratchpad',
        'bar': 'toggle bar',
    }
    a_lower = action.lower()
    for key, val in FRIENDLY.items():
        if a_lower.startswith(key):
            remainder = action[len(key):].strip()
            if remainder:
                return f"{val} {remainder}"
            return val

    # Fall back to the raw action (truncated if very long)
    if len(action) > 60:
        return action[:57] + "..."
    return action


def parse_files(files):
    """
    Parse a list of sway config files for bindsym lines.
    Later files (user overrides) take precedence on the same combo.
    Returns (list_of_(keys_display, description), suggestions_list)
    """
    binding_map = {}   # combo_key -> (keys_display, description)
    source_map = {}    # combo_key -> file_path
    unbound_set = set()  # combos explicitly unbound in user files
    default_seen = {}  # combo_key -> True if seen in non-last file
    all_combos_ordered = []  # preserve insertion order

    user_conf_path = files[-1] if len(files) > 1 else None

    for file_path in files:
        if not os.path.exists(file_path):
            continue
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                for raw_line in f:
                    raw_line = raw_line.rstrip('\n')
                    stripped = raw_line.strip()

                    if not stripped or stripped.startswith('#'):
                        continue

                    # Handle unbindsym (user can unbind a default)
                    if re.match(r'^unbindsym\b', stripped, re.IGNORECASE):
                        ub_m = re.match(r'^unbindsym(?:\+\S+)?\s+(\S+)', stripped, re.IGNORECASE)
                        if ub_m:
                            ub_combo = normalize_combo(substitute_mod(ub_m.group(1)))
                            if file_path == user_conf_path:
                                unbound_set.add(ub_combo)
                            # Remove from map
                            binding_map.pop(ub_combo, None)
                            source_map.pop(ub_combo, None)
                        continue

                    result = parse_bindsym_line(raw_line)
                    if result is None:
                        continue

                    combo_key, keys_display, description = result
                    is_user = (file_path == user_conf_path)

                    if not is_user:
                        default_seen[combo_key] = True

                    if combo_key not in all_combos_ordered:
                        all_combos_ordered.append(combo_key)

                    # User file overrides earlier definitions
                    if combo_key not in binding_map or is_user:
                        binding_map[combo_key] = (keys_display, description)
                        source_map[combo_key] = file_path

        except Exception as e:
            sys.stderr.write(f"Error reading {file_path}: {e}\n")
            continue

    # Build output list preserving order
    results = []
    suggestions = []

    for combo_key in all_combos_ordered:
        if combo_key not in binding_map:
            continue
        keys_display, description = binding_map[combo_key]
        results.append((keys_display, description))

        # Suggestion: user override without explicit unbind
        src = source_map.get(combo_key)
        if (src == user_conf_path and
                combo_key in default_seen and
                combo_key not in unbound_set):
            suggestions.append(f"unbindsym {keys_display}")

    return results, suggestions


def format_for_rofi(binds):
    lines = []
    for keys_display, description in binds:
        if description:
            lines.append(f"{keys_display} — {description}")
        else:
            lines.append(keys_display)
    return lines


def main():
    if len(sys.argv) < 2:
        sys.exit(0)

    config_files = sys.argv[1:]
    binds, suggestions = parse_files(config_files)

    if not binds:
        print("no keybinds found.")
        sys.exit(1)

    formatted = format_for_rofi(binds)
    for line in formatted:
        print(line)

    if suggestions:
        import tempfile
        try:
            with tempfile.NamedTemporaryFile(mode='w', delete=False,
                                             prefix='sway-unbind-suggestions-',
                                             suffix='.conf') as tf:
                tf.write('\n'.join(suggestions) + '\n')
            with open("/tmp/sway_keybind_suggestions_file", "w") as sf:
                sf.write(tf.name)
        except Exception:
            pass


if __name__ == "__main__":
    main()
