# RetailMacro

RetailMacro aims to bring the macro API from recent WoW versions to Vanilla WoW. This includes the bracket syntax ([]) and commands as described in http://wowwiki.wikia.com/wiki/Making_a_macro

###UNIT FRAMES
* Default UI now has mouseover capability. (except raid pullout frames)
* An experimental focus frame 

###MACROS
#####Commands

Command         | Parameter
----------------|-------------
"/cast"         | spellname
"/castrandom"   | comma separated list of spellnames
"/castsequence" | _reset condition_ and comma separated list of spellnames
"/stopcasting"  | none
"/clearfocus"   | none
"/focus"        | _unit id_
"/targetfocus"  | none
"/target"       | _unit id_
"/cleartarget"  | none
"/assist"       | _unit id_
"/use"          | _inventory slot_ or _bagslot_ or itemname
"/userandom"    | comma separated list of itemnames
"/equip"        | 
"/cancelaura"   | buffname
"/cancelform"   | _index_
"/petagressive" | none
"/petdefensive" | none
"/petpassive"   | none
"/petattack"    | none
"/petfollow"    | none
"/petstay"      | none

#####Conditions

Condition          | Value                              | Example        
-------------------|------------------------------------|----------------
"combat"           | none                               |                
"dead"             | none                               |                
"exists"           | none                               |                
"group"            | none                               |                
"harm"             | none                               |                
"help"             | none                               |                
"mod" / "modifier" | none or "shift" or "alt" or "ctrl" | mod:shift      
"mounted"          | none                               |                
"party"            | _unit id_                          | party:target   
"pet"              | pet name                           | pet:Voidwalker 
"raid"             | _unit id_                          | raid:pettarget 
"stance" / "form"  | none or _index_ or _expression_    | stance:1/2     
"stealth"          | none                               |                

every condition can be negated by writing 'no' in front of it. For example "nocombat" and "nomod" are valid conditions

*reset condition:* describes the timeout condition for when a sequence restarts
```
/castsequence reset=10 Curse of Agony, Corruption, Shadow Bolt
```
*inventory slot:* a number rangeing from 0 to 19 where 13 is the first trinket slot and 14 the secone one
```
/use 13           (use item in inventoryslot 13)
```
*bag slot:* two numbers separated by a whitespace; first number is for the bagslot and second number the container index of the according bag
```
/use 4 2          (use item number 2 in bag number 4)
```
*unit id:* is either of the following
* "player"
* "target"
* "pet"
* "partyN" where N is a number between 0 and 5
* "raidN" where N is a number between 0 and 40

you can string together several 'target' behind every unit id. For example "playertarget" or "raid7target" or "pettargettargettargettarget" are valid unit ids, too

*expression:* a simple expression like "stance:1/2/3", which would translate to 'player is in either stance 1 or 2 or 3'
```
/cast [stance:0/4] Moonfire
```
*index:* the stance index number as listed in the following table

         | Warrior   | Druid                   | Priest               | Rogue	    | Shaman   
---------|-----------|-------------------------|----------------------|--------------|-------------
Stance 0 |           | _no stance_             | _no stance_          | _no stance_  | _no stance_
Stance 1 | Battle    | Bear 	           | Shadowform or        | Stealth 	    | Ghost Wolf 
         |           |                         | Spirit of Redemption |              |
Stance 2 | Defensive | Cat                     |                      |              | 			
Stance 3 | Berserker | Travel                  |                      |              |
         |           | (includes Aquatic form) | 		       |              |
Stance 4 |           | Moonkin                 |		       |              |

Example macro for one button focus
```
/focus [mod:alt, @mouseover]
/target [nomod] focus
/clearfocus [mod:ctrl]
```
###CAUTION

Mouseover has a .5 sec timeout except on unit frames.
That means you cannot perform consecutive actions on a target by keeping the pointer over it.
  
Focus and Mouseover are stored internally by name.
This can lead to unpredictable behaviour in areas with NPCs who share the same name.

###For developers

Nearly every function that takes *unit id* as parameter has been altered to accept "focus" and "mouseover"
parameters
```
RetailMacro:get_focus()
RetailMacro:get_mouseover()
RetailMacro:set_focus(string)
RetailMacro:set_mouseover(string)
```
are available if you want to add the according ability to your unit frames
