# Homeward 🎒

A 2D multiplayer tile-based board game developed using **Godot Engine** for a Game Development class.

Players take the role of students trying to get home first by moving across a map using dice rolls while encountering special tiles and shortcuts.

---

## 🎮 Game Overview

**Homeward** is inspired by classic board games like *Snakes and Ladders* but introduces new mechanics such as **power tiles, waypoint shortcuts, and multiple map sizes**.

Players navigate through the board while facing random events that may help or hinder their progress.

---

## 🧩 Features

* 2–4 player multiplayer
* Dice-based movement
* Tile-based board navigation
* Special **Power Tiles** that give advantages or challenges
* **Waypoint shortcuts** that allow fast travel across the map
* Multiple map sizes:

  * 6×6 (Quick Game)
  * 8×8 (Standard Game)
  * 12×12 (Extended Game)

---

## 🎲 Game Mechanics

### Turn System

Players take turns rolling a dice and move forward based on the number rolled.

### Power Tiles

Landing on a power tile triggers a special effect such as:

* Move forward
* Move backward
* Skip turn
* Roll again

### Waypoints

Waypoints act as shortcuts across the map.
Landing on a waypoint moves the player to another tile with the same waypoint.

### Win Condition

The first player to reach the **Home tile** wins the game.

---

## 🗺 Maps

| Map Size | Tiles | Description              |
| -------- | ----- | ------------------------ |
| 6×6      | 36    | Short matches            |
| 8×8      | 64    | Standard gameplay        |
| 12×12    | 144   | Longer strategic matches |

---

## 🛠 Technology Stack

* **Engine:** Godot Engine
* **Language:** GDScript
* **Version Control:** Git & GitHub

---

## 📂 Project Structure

```
assets/      → Game sprites, audio, and textures  
scenes/      → Godot scenes  
scripts/     → Game logic scripts  
maps/        → Board map configurations  
docs/        → Additional documentation  
```

---

## 👥 Team Roles

| Role                | Responsibility                    |
| ------------------- | --------------------------------- |
| Gameplay Programmer | Dice logic, tile system, movement |
| UI Developer        | Interface and menus               |
| Artist              | Game assets and sprites           |
| Designer            | Game mechanics and map layout     |

---

## 🚀 Development Goals

* Implement turn-based board gameplay
* Create dynamic tile effects
* Support multiplayer gameplay
* Design multiple board maps

---
