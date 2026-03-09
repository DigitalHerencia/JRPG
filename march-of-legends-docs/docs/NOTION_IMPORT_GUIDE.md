# Notion Import Guide

## Included CSV databases

- `01_Projects.csv`
- `02_Epics.csv`
- `03_Tasks.csv`
- `04_Characters.csv`
- `05_Band_Sections.csv`
- `06_Levels.csv`
- `07_Systems.csv`
- `08_Formations.csv`
- `09_Art_Assets.csv`
- `10_Prompts.csv`

## Import order

Import them in numeric order.

## Important constraint
CSV import is great for seeding databases, but direct relation-property mapping is not preserved automatically during CSV import. That is why the package includes text columns like `Project ID`, `Epic ID`, and `Character ID`. After import, convert those into relation properties inside Notion.

## Recommended Notion views

### Tasks
- Board by Status
- Table by Priority
- Timeline by Target Date

### Art Assets
- Board by Status
- Gallery by Asset Type

### Characters
- Gallery by Section
- Table by Role

### Prompts
- Table by Prompt Type
- Board by Target Agent

## Useful rollups after import

- Project → count of open tasks
- Epic → count of tasks by status
- Character → linked levels and systems
- System → linked prompts and implementation tasks
