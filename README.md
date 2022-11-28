# Lockheed L-12a for X-Plane 12

This repository offers a modified and extended version of [Steve Baugh's's Lockheed L-12a Electra Junior](https://forums.x-plane.org/index.php?/files/file/75273-lockheed-model-12a-electra-junior/) for X-Plane 12 (with permission from the author).

**This is for X-Plane 12 beta 14 and newer only!**

&nbsp;

<a name="toc"></a>
## Table of Contents
1. [Changes from the original model](#1.0)
2. [Installation](#2.0)
3. [Repaints/Aircraft Configuration](#3.0)
4. [Notes](#4.0)
5. [Credits](#5.0)
6. [License](#6.0)

&nbsp;

<a name="1.0"></a>
## 1. Changes from the original model

See the ["Notes"](#4.0) section for any known issues and the ["Credits"](#5.0) section for links to the original modification or source material (if applicable).   
The baseline version was 2.0.0.

&nbsp;

### 1.1 Aircraft Configuration File

- Unified the modern and vintage models into a single aircraft file to facilitate updates. See ["Repaint compatibility"](#3.0) below for configuring present and future repaints.
- X-Plane 12 payload stations.

&nbsp;

### 1.2 Exterior

- Pilot is hidden when master switch is off.
- Glass and solid cockpit roof types can now be switched via manipulator.
- Independent left and right landing lights.

&nbsp;

### 1.3 Interior

- Glass and solid cockpit roof types can now be switched via manipulator.

&nbsp;

### 1.4 Interactive elements

- Reworked all manipulators and all now have tooltips.
- Number of custom commands greatly cut down.
- New manipulators for the yokes.
- Manipulators to toggle between cockpit types (modern/vintage)
- Manipulators to toggle roof type (solid/glass)
- Control lock lever works now.

&nbsp;

### 1.5 Systems

- Rewrote ARN-7 vintage nav radio logic for more robustness.
- Rewrote RCA com radio logic for 8.33 kHz capability and more robustness.
- Rewrote fuel system logic. Fuel gauge indication is now affected by aircraft pitch.
- Reworked ignition system logic. Magneto selectors now operable independently of master ignition switch position. However, actual engine ignition will only be available if master ignition is on.
- Rewrote lights logic. True independent left and right landing lights that turn on with the main switch on and when deployed. Nose light now requires that the baggage door is closed.

&nbsp;

### 1.6 Sounds

- Unified modern and vintage sound files.





&nbsp;

<a name="2.0"></a>
## 2. Download and Installation

- Press the green "Code" button above and choose "Download ZIP" or click [here](https://github.com/JT8D-17/x-plane-metroliner/archive/refs/heads/main.zip).
- Extract the zipped file.
- Put the _"..."_ folder into _"X-Plane 12/Aircraft"_ (or where ever else you keep your add-on aircraft).

If successful, there will be a separate UI entry named _""_ in X-Plane 12's aircraft menu.

&nbsp;

<a name="3.0"></a>
## 3. Repaints/Aircraft Configuration

### 3.1 Compatibility

Repaints done for the base model are generally compatible to this one.   
**Repaints for Steve's (s85skater) Metroliner Mod cause transparency issues on the cabin windows!**

- If the repaint contains an altered _metro8.png (or .dds)_ file, it must be located in _"[Your livery folder]/objects/AC"_ for the passenger version or _"[Your livery folder]/objects/AT"_ for a freighter.   
Otherwise X-Plane will load the default texture (see file structure of the _"objects"_ folder for reference).

### 3.2 Aircraft configuration files

Aircraft configuration files are located in the livery folder at _"liveries/[Your livery folder]/config.txt"_. They may contain none or all of the following parameters and values:
```
IsFreighter=0/1
CockpitGlass=0/1
CabinWindows=0/1
PilotType=Male/Female
PropType=4Blade/5Blade
```

Parameter notes:   
`IsFreighter=1` hides the passenger cabin and enables the freighter cabin.   
`CockpitGlass=1` hides the black cockpit glass and enables transparent cockpit glass.   
`CabinWindows=0` hides the black cabin windows. **Required for any repaint for Steve's PBR mod.**
`PilotType=Female` switches to a female pilot. **Pilots are only visible when cockpit glass has been enabled.**  
`PropType=5Blade` enabled the MT Propellers 5-bladed prop. The default dataref for the number of propellers will be adjusted accordingly.

The default state is:   
```
IsFreighter=0
CockpitGlass=0
CabinWindows=1
PilotType=Male
PropType=4Blade
```
So if you want any other configuration for a repaint, prepare a corresponding config.txt.

See the included liveries for example configurations.

&nbsp;

<a name="4.0"></a>
## 4. Notes

Known issues, helpful hints, etc.

- Changing a repaint from passenger to freighter (or the other way around) will not perform an aircraft configuration check. An aircraft reload with the _"Reload the Current Aircraft (Skip Art Reload)" from X-Plane's _"Developer"_ menu is required.

&nbsp;

<a name="5.0"></a>
## 5. Contributors/Credits

- Steve Baugh, Dan Hopgood [Lockheed L-12a](https://forums.x-plane.org/index.php?/files/file/75273-lockheed-model-12a-electra-junior/)
- BK (me)

&nbsp;

<a name="6.0"></a>
## 6. License

With Steve Baugh's blessing, this project uses a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/) (CC-BY-NC-SA).
