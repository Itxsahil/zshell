import QtQuick

// Procedural demo wallpaper: dusk sky, stars, sun glow, layered ridges.
// Deterministic (seeded) so screenshots are reproducible.
Canvas {
    id: canvas

    renderTarget: Canvas.Image

    onPaint: {
        const ctx = getContext("2d");
        const w = width, h = height;
        let seed = 1337;
        const rand = () => (seed = (seed * 16807) % 2147483647) / 2147483647;

        const sky = ctx.createLinearGradient(0, 0, 0, h);
        sky.addColorStop(0, "#070b1f");
        sky.addColorStop(0.45, "#241a4d");
        sky.addColorStop(0.72, "#7a3b78");
        sky.addColorStop(0.9, "#f08a6c");
        ctx.fillStyle = sky;
        ctx.fillRect(0, 0, w, h);

        for (let i = 0; i < 520; i++) {
            const x = rand() * w, y = rand() * h * 0.62, r = rand() * 1.6 + 0.3;
            ctx.fillStyle = Qt.rgba(1, 1, 1, 0.25 + rand() * 0.7);
            ctx.beginPath();
            ctx.arc(x, y, r, 0, Math.PI * 2);
            ctx.fill();
        }

        const glow = ctx.createRadialGradient(w * 0.68, h * 0.74, 0, w * 0.68, h * 0.74, h * 0.55);
        glow.addColorStop(0, "rgba(255, 196, 120, 0.95)");
        glow.addColorStop(0.12, "rgba(255, 150, 110, 0.75)");
        glow.addColorStop(0.4, "rgba(220, 90, 140, 0.25)");
        glow.addColorStop(1, "rgba(120, 40, 120, 0)");
        ctx.fillStyle = glow;
        ctx.fillRect(0, 0, w, h);

        const ridges = [
            [0.66, 0.16, "#3a2457"],
            [0.74, 0.12, "#291a44"],
            [0.82, 0.1, "#1b1233"],
            [0.9, 0.07, "#100b22"]
        ];
        for (const [base, amp, col] of ridges) {
            ctx.fillStyle = col;
            ctx.beginPath();
            ctx.moveTo(0, h);
            let y = h * base;
            for (let x = 0; x <= w; x += 24) {
                y += (rand() - 0.5) * h * amp * 0.35;
                y = Math.max(h * (base - amp), Math.min(h * (base + amp * 0.4), y));
                ctx.lineTo(x, y);
            }
            ctx.lineTo(w, h);
            ctx.closePath();
            ctx.fill();
        }
    }
}
