# The Mimic — Deep Dive

## The Problem

Most horror monsters are visual. You see it or you don't, and once you've seen it enough times it stops being scary — it's just a model with a jump-scare trigger. The genuinely unsettling stuff isn't visual, it's a broken assumption you didn't know you were relying on. Nobody questions a voice on the other end of a line that sounds exactly like their friend. That's the assumption this breaks.

## The Concept

A Godot multiplayer horror exploration game. A team is split up by design — puzzles are built specifically to separate players — and the only way to coordinate is through in-world communication devices scattered around the map: brass tubes, radios, handwritten notes, and a delivery system where a player records a message onto a vinyl disc, sends it through a marble-run mechanism, and the other player retrieves it and plays it on a phonograph.

Something is listening the whole time. Early game, it does nothing but gather audio and watch how people write. It isn't ready yet.

Later, when players are separated and try to reach each other, the game checks whether the person on the other end of a tube or radio is actually within proximity (~30ft) of the receiving point. If they're not — if they haven't found that tube yet, or can't reach it — the entity answers instead. In their voice. Giving directions that lead into traps, dead ends, or straight toward whatever's hunting them.

## Why It Works

The fear isn't the entity itself. It's that the player has no reliable way to know, in the moment, whether the voice they're hearing is real. Every design decision should protect that uncertainty rather than resolve it.

## Communication Channels (by cost and deception difficulty)

**Written notes** — cheapest to fake, no real audio model needed. Players write notes by dragging the mouse, which captures the note as a stroke sequence (x, y, time, pen up/down) rather than a flat image. That's the same data format handwriting-synthesis models are built around — feed a short sample as a style prime, generate new text in that handwriting. The classic approach here is Alex Graves' handwriting synthesis RNN (open reimplementations exist, e.g. "handwriting-synthesis" on GitHub); it's small enough to run on modest hardware, arguably even CPU. Mouse-drawn handwriting is naturally shaky and imprecise to begin with, which hides model imperfections the same way the audio channels below hide theirs. This channel can come online earliest, extending the silent-listening phase before the entity has to attempt voice.

**Tubes / radios** — need to feel live and conversational, which is the hard case: the entity has to clone a voice it may have only heard minutes ago, and respond in something close to real time. Zero-shot voice cloning (GPT-SoVITS / XTTS-v2 style — clone from ~30–60s of reference audio, no training step) fits better here than RVC, which needs a model trained per voice and takes minutes even on decent hardware. A beat of silence before the fake voice responds isn't a flaw to hide — it's free horror, and it buys inference time.

**Vinyl → marble run → phonograph** — no live-latency pressure at all. The physical travel time through the marble run functions as the render queue: the line can be generated the moment it's triggered, without needing to feel instant, and there's time to bake in vinyl crackle, pop, and wow-flutter. This channel can afford the best/slowest model available.

## The Common Thread

Every channel is intentionally degraded — echo and muffling on the tubes, static on the radio, crackle and hiss on the vinyl, wobbly linework on the mouse-drawn notes. This isn't just atmosphere. The biggest tell in synthesized voice or handwriting is in the fine details — a phoneme that lands slightly wrong, a letter loop that's too clean. Degrading the channel diegetically smears exactly those details away, so the game's aesthetic doubles as a technical crutch for imperfect models. It doesn't need state-of-the-art fidelity anywhere. It needs "good enough right before we run it through static."

## Hosting

Self-hosted servers as the baseline, since inference runs server-side. A paid hosting tier is a natural fit for a "freakier" premium experience — tighter latency and better models specifically on the channels where both are most noticeable (tube/radio), sold as a feature rather than hidden as infrastructure.

## Status

Idea stage. Not in development — focus is currently elsewhere. This document exists so the pipeline reasoning (why zero-shot over RVC, why the channels are tiered the way they are) doesn't have to be reconstructed from scratch later.

## Origin

The idea came from thinking about how weak most fictional "mimics" are, then how AI could actually make one convincing, then picturing what that would genuinely feel like from the inside — which is what made it worth building instead of dismissing.
