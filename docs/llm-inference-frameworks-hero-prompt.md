# 推理框架文章头图

- 生成日期：2026-10-26。
- 方式：imagegen 技能，内置 `image_gen` 工具；未使用 CLI 或 API Key。
- 类型：stylized-concept，全新生成的概念插画，不是硬件结构图。
- 用途：文章 front matter 的 `image.path`，用于顶部横幅与文章卡片。
- 当前项目文件：`assets/img/posts/llm-inference-frameworks/hero-with-title.png`；无字首版保留为 `hero.png`。
- 输出尺寸：1672 × 941，约 16:9；不透明背景。
- 验收：已查看最终结果，主标题“一次 LLM 请求背后”、副标题“AI 应用工程师需要懂的推理框架”准确，装置主体及支脚完整，四周有留白，没有品牌标识；用输入与输出的颜色区分阅读方向。

## 首版插画提示词

```text
Use case: stylized-concept
Asset type: wide editorial hero illustration for a Chinese engineering blog post titled “一次 LLM 请求背后：AI 应用工程师需要懂的推理框架”.
Primary request: illustrate the hidden machinery behind a single LLM request, as a carefully crafted physical cutaway inference engine, approachable but technically sophisticated.
Scene: a clean off-white paper background, a single elegant tabletop machine shown in a shallow isometric cutaway. A compact stack of input tiles enters the machine from the left; inside, a small orderly queue, a fan of parallel processing elements, and a clearly visible bank of reusable cache blocks surround a central compute module; a neat stream of individual output tiles emerges to the right, one after another. Use the physical composition to suggest input processing, scheduling, cache reuse and sequential generation. This is a conceptual editorial illustration, not a literal hardware blueprint.
Style: premium technical magazine illustration, precise ink outlines, restrained flat color with subtle material texture and gentle dimensional shading, uncluttered, thoughtful, crisp edges and generous white space. Readable silhouette at thumbnail size.
Color: harmonize with the blog’s existing technical illustrations: off-white, deep navy, soft blue, warm orange input accents, restrained lavender compute/cache accents, pale mint output accents. No neon glow.
Composition: wide landscape 16:9, one coherent scene, main machine and all essential elements comfortably within the central 80% of the frame, balanced margins, nothing cropped. No extra panels or inset boxes.
Text: no words, no letters, no numbers, no logos, no watermark. The article title is already rendered by the blog.
Avoid: humanoid robots, brains, chat bubbles, cosmic backgrounds, glossy sci-fi HUDs, dense arrows, meaningless circuitry, decorative charts.
```

## 留白微调提示词

```text
Use case: precise-object-edit. Edit this existing Chinese blog cover.
Change only the machine illustration's scale and placement: uniformly reduce the whole machine illustration slightly, about 10%, and position it below the subtitle so that every part, including the lowest support feet and the far-right conveyor, is fully inside the canvas with a clear off-white margin of at least 35 pixels on every side, especially the bottom.
Keep the canvas size, off-white background, the two existing headline lines, their exact wording, glyphs, font style, color, size and position UNCHANGED. Keep the machine's design, components, line work, colors and left-to-right orientation unchanged. Do not reword, add, remove, stretch or crop anything. Main headline remains "一次 LLM 请求背后". Subtitle remains "AI 应用工程师需要懂的推理框架". No other text or marks.
```

## 中文标题修订提示词

用户要求头图加入中文文案，保留首版无字插画，新增带主副标题的版本。

```text
Use case: precise-object-edit
Asset type: Chinese engineering blog hero image, wide landscape approximately 16:9.
Input image: reference and edit target, the existing cutaway inference engine illustration.
Change only composition and add the specified Chinese typography. Preserve the same machine design, its ink-and-material editorial illustration style, orange input tiles, lavender compute/cache blocks, mint output tiles, off-white paper background, and color palette. Scale the machine down slightly and move it lower so the upper quarter is clean space for a proper headline. Keep all parts fully within the frame, preserve the left-input to right-output direction.
Add a beautifully typeset, large, dark navy Chinese main headline in the upper area, left aligned with a comfortable margin. Beneath it add a smaller, clearly legible subtitle in matching ink. Make this a polished Chinese technical magazine cover: confident typography, generous spacing, excellent contrast, harmonious illustration below. No text overlapping the machine.
Text (verbatim):
Main headline: "一次 LLM 请求背后"
Subtitle: "AI 应用工程师需要懂的推理框架"
Render those two lines exactly, with accurate Simplified Chinese glyphs and correct English letters, no missing characters. Do not add other words, labels, logos or watermarks. Keep the original warm, restrained color mood and the opaque background.
```
