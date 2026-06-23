"""
X39MATRIX :: Generador de imagenes cosmicas Kepler-x39
- 3 imagenes en estilo cypherpunk-cosmic
- Triangulo glow rojo (sin verde)
- Caballo galopando (Año del Caballo 2026 · abundancia)
- Kepler distance light-years backdrop
- Paleta: negro #0b0b0b · rojo #cc0000 · ambar
"""
import asyncio
import os
import base64
from dotenv import load_dotenv
from emergentintegrations.llm.chat import LlmChat, UserMessage

load_dotenv("/app/backend/.env")
api_key = os.getenv("EMERGENT_LLM_KEY")

OUT_DIR = "/app/frontend/public/x39_assets"
os.makedirs(OUT_DIR, exist_ok=True)

PROMPTS = [
    {
        "name": "x39_kepler_horse_twitter_card.png",
        "session": "x39-twitter-card",
        "prompt": """Cinematic cosmic poster in 16:9 ultra-wide aspect ratio.

Setting: deep interstellar void as seen from the Kepler space telescope — light-years of distance, distant stars, faint nebulae in deep crimson and amber tones. ABSOLUTELY NO GREEN, NO BLUE, NO TEAL. Only black, deep red, ember orange, and dim white starlight.

Center foreground: a sharp glowing wireframe equilateral triangle floating in space, edges in vivid neon red (#cc0000), surrounded by a soft halo of crimson light. Inside the triangle, three lines of monospace text rendered in red: "ED25519", "x509", "ARQUITECTO X39", stacked vertically and centered. Concentric ruby red rings emanate softly from the triangle's center, suggesting cosmic resonance.

Mid-ground: a magnificent powerful horse silhouette galloping across the cosmic plane, the horse rendered entirely from streaks of crimson light and red ember particles, mane and tail trailing as solar wind. The horse is mid-stride, full of motion and abundance — a symbol of the Chinese Year of the Horse 2026. The horse appears to gallop FROM the triangle outward into infinite space.

Background: a horizontal chain of small orange-amber hexagonal blocks fading into the cosmic distance — visual metaphor for Bitcoin's blockchain stretching across light-years. Subtle white pinprick stars scattered sparsely.

Bottom of frame (small monospace red text): "curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash"
Top-left small caption: "X-39MATRIX · 9-LAYER SOVEREIGN PROTOCOL · BITCOIN MAINNET"
Top-right small caption: "馬 · 2026 · ABUNDANCE"

Style: cypherpunk meets Kepler exoplanet survey science art. Ultra-detailed, photoreal cosmic sci-fi, sharp contrast, terminal aesthetic. Palette strictly: pure black #0b0b0b, neon red #cc0000, ember orange #ff6633, dim ivory stars. ZERO green. ZERO blue. ZERO teal. ZERO purple. No humans, no faces, no logos other than the triangle. Mood: solemn, sovereign, cosmic, indelible."""
    },
    {
        "name": "x39_kepler_horse_og_square.png",
        "session": "x39-og-square",
        "prompt": """Square 1:1 minimal cypherpunk-cosmic poster.

Background: pure black void #0b0b0b with sparse distant red-amber stars, suggesting Kepler exoplanet survey distance. ABSOLUTELY NO GREEN, NO BLUE, NO TEAL, NO PURPLE. Only black, neon red, ember orange, and dim ivory starlight.

Center: a bright glowing wireframe equilateral triangle with razor-sharp neon red (#cc0000) edges, occupying about 55% of the frame. Inside the triangle, in monospace red font, three stacked lines: "ED25519", "x509", "ARQUITECTO X39". A single bright Bitcoin orange dot anchored at the bottom-left vertex of the triangle.

Behind the triangle, a subtle silhouette of a galloping horse made of crimson red light particles — partially visible through the triangle's wireframe — symbolizing the 2026 Year of the Horse and abundance. The horse moves left-to-right, in mid-leap, dynamic and powerful.

Soft radial red glow emanates from the triangle's center, fading into black.

Top of frame: "X39MATRIX" in red letterspaced monospace.
Below the triangle: "Don't trust. Verify. — 51 / 51" in dim red monospace.
Bottom-right corner small mark: "馬 2026" in red.

Style: cypherpunk poster art, minimalist, sovereign, indelible, cosmic. Strict palette: pure black, neon red #cc0000, ember orange. ZERO green/blue/teal/purple. No humans, no faces. Photoreal cosmic precision."""
    },
    {
        "name": "x39_kepler_horse_banner.png",
        "session": "x39-banner",
        "prompt": """Ultra-wide cinematic banner, 3:1 aspect ratio (1500 x 500 ideal), perfect for Twitter/X header.

Setting: a sweeping panoramic view of deep interstellar space, as if observed from the Kepler space telescope at light-year distances. Faint nebulae glow in deep crimson and amber. Sparse dim white pinprick stars scattered across the field. ABSOLUTELY NO GREEN, NO BLUE, NO TEAL, NO PURPLE — only black, neon red, ember orange, ivory.

Left third of the frame: a magnificent horse silhouette galloping mid-leap, body composed entirely of streaks of crimson red light and ember orange embers. Mane and tail trail behind as cosmic wind. The horse moves from left to right with immense momentum and energy — representing the Chinese Year of the Horse 2026, abundance and power.

Center: a brilliant glowing wireframe red triangle (X39MATRIX), pristine and razor-sharp, suspended weightlessly in the cosmic void. Inside the triangle: monospace red text "ED25519 / x509 / ARQUITECTO X39" stacked. Concentric red ripples emanate from the triangle into the cosmic distance.

Right third of the frame: a horizontal chain of small amber-orange hexagonal blocks (visual metaphor for Bitcoin blockchain) extending toward the cosmic horizon, fading into red haze. Floating small monospace red text readouts: "#952131", "11 canisters", "51/51", "single author".

Style: cypherpunk meets scientific astronomy art. Photoreal cosmic precision, sharp contrast, sovereign and indelible mood. Strict palette: pure black #0b0b0b, neon red #cc0000, ember orange #ff6633, dim ivory stars. ZERO green/blue/teal/purple. No humans, no faces, no logos other than the triangle and the abstract hexagonal chain."""
    }
]


async def generate_one(spec):
    chat = LlmChat(api_key=api_key, session_id=spec["session"], system_message="You are an expert cypherpunk-cosmic visual artist.")
    chat.with_model("gemini", "gemini-3.1-flash-image-preview").with_params(modalities=["image", "text"])

    msg = UserMessage(text=spec["prompt"])
    text, images = await chat.send_message_multimodal_response(msg)

    if images:
        img = images[0]
        path = os.path.join(OUT_DIR, spec["name"])
        img_bytes = base64.b64decode(img["data"])
        with open(path, "wb") as f:
            f.write(img_bytes)
        print(f"✓ {spec['name']}  ({len(img_bytes)} bytes)")
        return path
    else:
        print(f"✗ NO IMAGE for {spec['name']}  text response: {text[:200]}")
        return None


async def main():
    print(f"Generando {len(PROMPTS)} imagenes en {OUT_DIR}...")
    tasks = [generate_one(p) for p in PROMPTS]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    success = sum(1 for r in results if r and not isinstance(r, Exception))
    print(f"\n{success}/{len(PROMPTS)} imagenes generadas en {OUT_DIR}")


if __name__ == "__main__":
    asyncio.run(main())
