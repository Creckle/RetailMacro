# RetailMacro

RetailMacro aims to bring the macro API from recent WoW versions to Vanilla WoW. This includes the bracket syntax ([]) and commands as described in http://wowwiki.wikia.com/wiki/Making_a_macro

Default UI now has mouseover capability. (except raid pullout frames)
A focus frame was added

Commands

"/cast"
"/castrandom"
"/castsequence"
"/stopcasting"

"/clearfocus"
"/focus"
"/targetfocus"

"/target"
"/cleartarget"
"/assist"

"/use"
"/userandom"
"/equip"

"/cancelaura"
"/cancelform"

"/petagressive"
"/petdefensive"
"/petpassive"

"/petattack"
"/petfollow"
"/petstay"

Mouseover:
  Mouseover has a .5 sec timeout except on unit frames.
  That means you cannot perform consecutive actions on a target by keeping the pointer over it.
  
Focus and Mouseover:
  Focus and Mouseover are stored internally by name.
  This can lead to unpredictable behaviour in areas with NPCs who share the same name.

Example maco for one button focus

/focus [mod:alt, @mouseover]

/target [nomod] focus

/clearfocus [mod:ctrl]
