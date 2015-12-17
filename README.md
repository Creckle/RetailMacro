# RetailMacro

RetailMacro aims to bring the macro API from recent WoW versions to Vanilla WoW. This includes the bracket syntax ([]) and commands as described in http://wowwiki.wikia.com/wiki/Making_a_macro

Default UI now has mouseover capability. (except raid pullout frames)
A focus frame was added

Commands

* "/cast"
* "/castrandom"
* "/castsequence"
* "/stopcasting"
* "/clearfocus"
* "/focus"
* "/targetfocus"
* "/target"
* "/cleartarget"
* "/assist"
* "/use"
* "/userandom"
* "/equip"
* "/cancelaura"
* "/cancelform"
* "/petagressive"
* "/petdefensive"
* "/petpassive"
* "/petattack"
* "/petfollow"
* "/petstay"

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

*unit id* is either of the following
* "player"
* "target"
* "pet"
* "partyN" where N is a number between 0 and 5
* "raidN" where N is a number between 0 and 40

*expression* a simple expression like "stance:1/2/3", which would translate to 'player is in either stance 1 or 2 or 3'

*index* the stance index number as listed in the following table

         | Warrior   | Druid                               | Priest               | Rogue	       | Shaman   
---------|-----------|-------------------------------------|----------------------|--------------|-------------
Stance 0 |           | _no stance_                         | _no stance_          | _no stance   | _no stance_
Stance 1 | Battle    | Bear 	                             | Shadowform or        | Stealth 	   | Ghost Wolf 
         |           |                                     | Spirit of Redemption |              |
Stance 2 | Defensive | Cat                                 |                      |              | 			
Stance 3 | Berserker | Travel                              |                      |              |
         |           | (includes Aquatic and Flight forms) | 					            |              |
Stance 4 |           | Moonkin                             |			                |              |


Mouseover has a .5 sec timeout except on unit frames.
That means you cannot perform consecutive actions on a target by keeping the pointer over it.
  
Focus and Mouseover are stored internally by name.
This can lead to unpredictable behaviour in areas with NPCs who share the same name.

Example macro for one button focus
```
/focus [mod:alt, @mouseover]
/target [nomod] focus
/clearfocus [mod:ctrl]
```
