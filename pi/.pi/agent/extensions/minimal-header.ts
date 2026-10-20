import { VERSION, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  backgroundAnsi, foregroundAnsi, isAppleTerminalSession, rgbColor,
  Text, truncateToWidth, visibleWidth, type Component,
} from "@earendil-works/pi-tui";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setHeader((tui, theme) => {
      const inspected = new WeakSet<Component>();

      // Pi has no diagnostic renderer API. Decorate only its warning Text
      // components through the public component tree, leaving messages alone.
      function boxWarnings(component: Component, width: number) {
        if (component instanceof Text && !inspected.has(component)) {
          inspected.add(component);
          const render = component.render.bind(component);
          const firstLine = render(Math.max(80, width))[0] ?? "";
          const plain = firstLine.replace(/\x1b\[[0-9;]*m/g, "").trimStart();
          if (/^(Warning:|\[(Skill conflicts|Prompt conflicts|Extension issues|Theme conflicts)\])/.test(plain)) {
            component.render = (columns: number) => {
              if (columns < 5) return render(columns).map((line) => truncateToWidth(line, columns));
              const inside = columns - 4;
              const border = (text: string) => theme.fg("warning", text);
              return [
                border(`╭${"─".repeat(columns - 2)}╮`),
                ...render(inside).map((line) => {
                  const text = truncateToWidth(line, inside);
                  return border("│") + " " + text + " ".repeat(inside - visibleWidth(text) + 1) + border("│");
                }),
                border(`╰${"─".repeat(columns - 2)}╯`),
              ];
            };
          }
        }
        const children = (component as Component & { children?: Component[] }).children;
        for (const child of children ?? []) boxWarnings(child, width);
      }

      return {
        render(width: number) {
          for (const child of tui.children) boxWarnings(child, width);
          const mode = theme.getColorMode();
          const coral = foregroundAnsi(rgbColor(228, 138, 122), mode);
          const blue = foregroundAnsi(rgbColor(79, 142, 179), mode);
          const yellow = foregroundAnsi(rgbColor(234, 182, 93), mode);
          const reset = "\x1b[0m";
          const logo = isAppleTerminalSession()
            ? [`${coral}P${yellow}i${reset}`]
            : [
                `${coral}${backgroundAnsi(rgbColor(79, 142, 179), mode)}▀${reset}${coral}▀█${reset} `,
                `${blue}█▀${reset} ${yellow}█${reset}`,
              ];
          return ["", ...logo, theme.fg("dim", `v${VERSION}`), ""].map((line) => {
            const text = truncateToWidth(line, width);
            return " ".repeat(Math.max(0, Math.floor((width - visibleWidth(text)) / 2))) + text;
          });
        },
        invalidate() {},
      };
    });
  });
}
