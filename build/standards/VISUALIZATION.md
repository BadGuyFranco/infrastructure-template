# Visualization Standards

How to create architecture visuals for {PROJECT_NAME} components. These diagrams are for the founder's comprehension, not for LLM context. The AI does not read them at session start.

## When to Create a Visual

When the founder asks for one. Not as a mandatory build step. Visuals are a communication tool, not a process gate.

## Where They Live

Each component has a `diagrams/` folder. One file per visual, named for what it shows.

```
{project-name}-client/diagrams/layout-overview.html
{project-name}-services/diagrams/prompt-assembly-pipeline.html
{project-name}-services/diagrams/auth-flow.html
infrastructure/diagrams/system-overview.html
```

Create the `diagrams/` folder when the first visual for that component is needed, not before.

## Format: HTML

Self-contained HTML files. No external dependencies. Open in any browser.

**Why HTML over Mermaid:** These are for the founder, not for GitHub rendering or LLM consumption. HTML gives full control over styling, color coding, layout, and interactivity.

**Design principles:**
- Dark theme (matches the IDE aesthetic)
- Color-coded sections to distinguish pipeline stages, data sources, future work
- Legend explaining colors and icons
- Responsive layout (sidebar + main flow, or full-width for simpler diagrams)
- Self-contained: inline CSS, no external stylesheets or scripts

## Diagram Types

| What You're Showing | Layout Approach |
|---------------------|----------------|
| Pipeline flow (how data moves through stages) | Vertical step sequence with side-panel showing output |
| Component architecture (how parts connect) | Box-and-arrow layout, grouped by layer |
| Request flow (message sequence between services) | Horizontal swim lanes or vertical sequence |
| State transitions | State boxes with labeled arrows |
| Data relationships | Entity boxes with connection lines |
| System overview (high-level) | Layered architecture with grouped components |

## Naming

Name files for what the visual shows, not the component or technology:
- `prompt-assembly-pipeline.html` (not `smart-layer.html`)
- `auth-flow.html` (not `clerk-integration.html`)
- `system-overview.html` (not `architecture.html`)

## Maintenance

Visuals are not living documents. They're snapshots. If the architecture changes significantly, create a new visual or update the existing one when the founder asks. Don't add "update diagrams" as a mandatory plan task.
