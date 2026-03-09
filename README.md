Done. I generated the full starter pack.



\## Files



\* \[Starter package ZIP](sandbox:/mnt/data/march-of-legends-starter-package.zip)

\* \[Godot project folder](sandbox:/mnt/data/march-of-legends/godot)

\* \[Notion import CSV package](sandbox:/mnt/data/march-of-legends/notion\_import)

\* \[Docs folder](sandbox:/mnt/data/march-of-legends/docs)



\## What’s inside



\### Godot scaffold



A Godot 4 \*\*2D\*\* starter repo with:



\* `project.godot`

\* autoload singletons:



&nbsp; \* `GameState.gd`

&nbsp; \* `SceneRouter.gd`

&nbsp; \* `AudioManager.gd`

&nbsp; \* `ContentDB.gd`

\* playable placeholder scenes:



&nbsp; \* `MainMenu.tscn`

&nbsp; \* `Campus.tscn`

&nbsp; \* `FieldCommand.tscn`

&nbsp; \* `RhythmBattle.tscn`

\* starter JSON content:



&nbsp; \* characters

&nbsp; \* formations

&nbsp; \* skills

&nbsp; \* levels

\* agent prompt library in `godot/prompts/`



That structure follows Godot’s core model of \*\*scenes composed of nodes\*\*, which is exactly the sane way to keep AI-generated changes modular instead of turning the repo into a haunted swamp. Godot’s own docs also recommend \*\*starting with 2D\*\* for beginners. (\[Godot Engine documentation]\[1])



\### Notion import package



You asked for something importable, not a vague “yeah man just set up a workspace.” So the package includes CSV databases for:



\* Projects

\* Epics

\* Tasks

\* Characters

\* Band Sections

\* Levels

\* Systems

\* Formations

\* Art Assets

\* Prompts



Notion officially supports CSV import, expects a header row, prefers UTF-8 CSV, and uses the first plain-text column as the primary title field. It also does \*\*not\*\* directly merge CSV columns into relation properties during import, so I included ID columns for you to wire into relations after import. (\[Notion]\[2])



\### Docs



Included docs:



\* `REPO\_ARCHITECTURE.md`

\* `SETUP\_GUIDE.md`

\* `ASSET\_PIPELINE.md`

\* `NOTION\_IMPORT\_GUIDE.md`

\* `AGENT\_SYSTEM.md`



These are written for a \*\*vibe-coding-first\*\* workflow, not for “become a proper game engineer over 14 weeks and discover yourself along the way” nonsense.



\## Important implementation choices



I used \*\*GDScript\*\*, not C#, because Godot’s official web export docs state that \*\*Godot 4 C# projects cannot be exported to the web\*\*, while HTML5 export works through WebAssembly/WebGL 2. That makes GDScript the less cursed starter choice for your case. (\[Godot Engine documentation]\[3])



Also: I optimized this for \*\*desktop-first\*\* iteration. Web export can come later, once the vertical slice works. (\[Godot Engine documentation]\[3])



\## What it already does



Right now the scaffold supports a rough prototype loop:



1\. boot into menu

2\. enter campus scene

3\. move around with placeholder player block

4\. interact for mascot-flavored text

5\. enter field command mode

6\. click cells to create a fake formation

7\. jump into rhythm battle

8\. finish and return to campus



So this is a \*\*starter skeleton\*\*, not a complete game. The bones are there. The flesh is still legally questionable.



\## One honest caveat



I created the scaffold and checked the file structure, but I did \*\*not\*\* run the Godot editor inside this environment, so there may still be a syntax or scene-wiring issue that needs one pass of real editor validation. That’s normal for generated starter packs.



\## Best next move



The highest-leverage next step is:

\*\*generate the real vertical-slice implementation prompts and code tasks for Codex, one file at a time, against this exact scaffold.\*\*



That’s where the weak-sauce phase ends and the gremlin orchestra begins.



\[1]: https://docs.godotengine.org/en/stable/getting\_started/first\_2d\_game/index.html "https://docs.godotengine.org/en/stable/getting\_started/first\_2d\_game/index.html"

\[2]: https://www.notion.com/help/import-data-into-notion "https://www.notion.com/help/import-data-into-notion"

\[3]: https://docs.godotengine.org/en/4.4/tutorials/export/exporting\_for\_web.html "https://docs.godotengine.org/en/4.4/tutorials/export/exporting\_for\_web.html"



