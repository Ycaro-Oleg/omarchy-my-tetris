#!/usr/bin/env python3
import math
import struct
import subprocess
import sys
from pathlib import Path

RATE = 44100
SRC = Path("/home/ycarooleg/Downloads/MusicThemeOmarchy-Tetris")
OUT = Path(__file__).resolve().parent
FADE = int(RATE * 0.045)
TARGETS = (12.8, 25.6)

NAMES = {
    "piano": "Classicals.de+-+Tetris+Theme+-+Korobeiniki+-+Rearranged+-+Arranged+for+Piano.mp3",
    "strings": "Classicals.de+-+Tetris+Theme+-+Korobeiniki+-+Rearranged+-+Arranged+for+Strings.mp3",
    "music-box": "Classicals.de+-+Tetris+Theme+-+Korobeiniki+-+Rearranged+-+Arranged+for+Music+Box.mp3",
}


def decode(path: Path) -> list[float]:
    raw = subprocess.check_output(
        [
            "ffmpeg",
            "-v",
            "error",
            "-i",
            str(path),
            "-t",
            "40",
            "-f",
            "f32le",
            "-ac",
            "1",
            "-ar",
            str(RATE),
            "-",
        ]
    )
    return list(struct.unpack("<" + "f" * (len(raw) // 4), raw))


def decode_stereo(path: Path, start: int, length: int) -> bytes:
    return subprocess.check_output(
        [
            "ffmpeg",
            "-v",
            "error",
            "-ss",
            f"{start / RATE:.6f}",
            "-t",
            f"{length / RATE:.6f}",
            "-i",
            str(path),
            "-f",
            "s16le",
            "-ac",
            "2",
            "-ar",
            str(RATE),
            "-",
        ]
    )


def first_onset(mono: list[float]) -> int:
    hop = 441
    threshold = 0.02
    for i in range(0, len(mono) - hop, hop):
        rms = math.sqrt(sum(s * s for s in mono[i : i + hop]) / hop)
        if rms > threshold and i > RATE // 4:
            return max(0, i - hop)
    return RATE


def env(mono: list[float], hop: int = 441) -> list[float]:
    out = []
    for i in range(0, len(mono) - hop, hop):
        out.append(math.sqrt(sum(s * s for s in mono[i : i + hop]) / hop))
    return out


def best_lag(values: list[float], hop: int) -> int:
    scored = []
    for target in TARGETS:
        center = int(target * RATE / hop)
        window = max(4, int(0.04 * center))
        for lag in range(center - window, center + window + 1):
            if lag <= 0 or lag >= len(values):
                continue
            acc = 0.0
            norm_a = 0.0
            norm_b = 0.0
            for i in range(len(values) - lag):
                acc += values[i] * values[i + lag]
                norm_a += values[i] * values[i]
                norm_b += values[i + lag] * values[i + lag]
            if norm_a <= 0 or norm_b <= 0:
                continue
            scored.append((acc / math.sqrt(norm_a * norm_b), lag * hop))
    scored.sort(reverse=True)
    return scored[0][1] if scored else int(TARGETS[0] * RATE)


def splice(pcm: bytes) -> bytes:
    frame = 4
    samples = list(struct.unpack("<" + "h" * (len(pcm) // 2), pcm))
    fade = FADE * 2
    if len(samples) <= fade * 2:
        return pcm
    body = samples[:-fade]
    for i in range(fade):
        t = i / fade
        fade_out = math.cos(t * math.pi / 2)
        fade_in = math.sin(t * math.pi / 2)
        mixed = int(samples[-fade + i] * fade_out + samples[i] * fade_in)
        mixed = max(-32768, min(32767, mixed))
        body[i] = mixed
    return struct.pack("<" + "h" * len(body), *body)


def encode(pcm: bytes, dest: Path) -> None:
    proc = subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-f",
            "s16le",
            "-ar",
            str(RATE),
            "-ac",
            "2",
            "-i",
            "-",
            "-c:a",
            "libopus",
            "-b:a",
            "48k",
            "-application",
            "audio",
            str(dest),
        ],
        input=pcm,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.decode("utf-8", "replace"))


def build(name: str, source: Path) -> None:
    mono = decode(source)
    start = first_onset(mono)
    period = best_lag(env(mono[start:]), 441)
    stereo = decode_stereo(source, start, period)
    looped = splice(stereo)
    dest = OUT / f"{name}.opus"
    encode(looped, dest)
    print(f"{name}: start={start / RATE:.2f}s period={period / RATE:.2f}s -> {dest.stat().st_size} bytes")


if __name__ == "__main__":
    for name, filename in NAMES.items():
        path = SRC / filename
        if not path.is_file():
            sys.stderr.write(f"missing {path}\n")
            sys.exit(1)
        build(name, path)
