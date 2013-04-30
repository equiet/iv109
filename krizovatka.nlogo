;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [
  world1
  world2
  world3
  world4
  world-size-x
  world-size-y
]

patches-own [
  patch-type ;; Type of patch, can be "road", "grass", "intersection", "spawn"
  spawn-location ;; For spawns, can be points of compass
  can-go? ;; Is green light?
  can-go-north? can-go-south? can-go-east? can-go-west?
  chosen-direction
  priority
]

turtles-own [
  ticks-alive
  previous-turn
  speed
  moved?
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  
  set world-size-x 21
  set world-size-y 21
  
  set world1 (make-world 0 0)
  make-intersection-priority 0 0
  
  set world2 (make-world 21 0)
  make-intersection-interval-lights 21 0
  
  set world3 (make-world 42 0)
  make-intersection-adaptive-lights 42 0
  
  set world4 (make-world 63 0)
  make-intersection-roundabout 63 0
  
  reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create worlds
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report make-world [ offset-x offset-y ]

  let tmp (list)

  let center-x (offset-x + (world-size-x - 1) / 2)
  let center-y (offset-y + (world-size-y - 1) / 2)
  let max-x (offset-x + world-size-x)
  let max-y (offset-y + world-size-y)
  
  
  ;; 1. Get patches of current world
  let current-world patches with [
    (pxcor >= offset-x and pxcor <= max-x)
    and (pycor >= offset-y and pycor <= max-y)
  ]


  ;; 2. Make grass
  make-grass current-world
  
  
  ;; 3. Make roads
  set tmp (current-world with [ pxcor = center-x ])
  make-road tmp 1
  set-direction-south tmp true
  
  set tmp (current-world with [ pxcor = center-x + 1])
  make-road tmp 1
  set-direction-north tmp true
  
  set tmp (current-world with [ pycor = center-y ])
  make-road tmp 1
  set-direction-east tmp true
  
  set tmp (current-world with [ pycor = center-y + 1 ])
  make-road tmp 1
  set-direction-west tmp true
  
  
  ;; 4. Make border
  set tmp current-world with [
    (pxcor = max-x or pxcor = offset-x)
    or (pycor = max-y or pycor = offset-y)
  ]
  make-border tmp
   

  ;; 5. Make spawn areas
  ask patch (center-x + 1) (offset-y + 1) [
    set patch-type "spawn"
    set spawn-location "south"
  ]
  ask patch (max-x - 1) (center-y + 1) [
    set patch-type "spawn"
    set spawn-location "east"
  ]
  ask patch center-x (max-y - 1) [
    set patch-type "spawn"
    set spawn-location "north"
  ]
  ask patch (offset-x + 1) center-y [
    set patch-type "spawn"
    set spawn-location "west"
  ]
  ask patches with [ patch-type = "spawn" ] [
    set pcolor 44
  ]
  
  report current-world
  
end

to make-grass [ fields ]
  ask fields [
    set patch-type "grass"
    set pcolor 56
    set can-go-north? false
    set can-go-south? false
    set can-go-east? false
    set can-go-west? false
  ]
end

to make-road [ fields priority-value ]
  ask fields [
    set patch-type "road"
    set pcolor priority-value
    set priority priority-value
  ]
end

to make-border [ fields ]
  ask fields [
    set patch-type "border"
    set pcolor 3
    set can-go-north? false
    set can-go-south? false
    set can-go-east? false
    set can-go-west? false
  ]
end

to set-direction-north [ fields value ]
  ask fields [ set can-go-north? value ]
end
to set-direction-south [ fields value ]
  ask fields [ set can-go-south? value ]
end
to set-direction-east [ fields value ]
  ask fields [ set can-go-east? value ]
end
to set-direction-west [ fields value ]
  ask fields [ set can-go-west? value ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create intersections
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to make-intersection-priority [ offset-x offset-y ]

  let tmp (list)
  
  let center-x (offset-x + (world-size-x - 1) / 2)
  let center-y (offset-y + (world-size-y - 1) / 2)
  
  let max-x (offset-x + world-size-x)
  let max-y (offset-y + world-size-y)
  
  let current-world patches with [
    (pxcor > (center-x - 3) and pxcor < (center-x + 4))
    and (pycor > (center-y - 3) and pycor < (center-y + 4))
  ]
 
  set tmp patches with [ (pxcor > center-x - 3) and (pxcor <= center-x) and (pycor = center-y) ]
  make-road tmp 2
  
  set tmp patches with [ (pxcor > center-x) and (pxcor <= center-x + 3) and (pycor = center-y + 1) ]
  make-road tmp 2

end

to make-intersection-interval-lights [ offset-x offset-y ]

  let tmp (list)
  
  let center-x (offset-x + (world-size-x - 1) / 2)
  let center-y (offset-y + (world-size-y - 1) / 2)
  
  set tmp patches with [
    (pxcor = center-x or pxcor = center-x + 1)
    and (pycor = center-y or pycor = center-y + 1)
  ]
  make-road tmp 2
  
  change-light (center-x - 1) (center-y) true
  change-light (center-x + 1) (center-y - 1) false
  change-light (center-x + 2) (center-y + 1) true
  change-light (center-x) (center-y + 2) false
  
end

to change-light [x y green?]
  ask patch x y [
    set patch-type "intersection"
    ifelse (green?) [ set pcolor 65 ] [ set pcolor 15 ]
    set can-go? green?
  ]
end

to make-intersection-adaptive-lights [ offset-x offset-y ]
end

to make-intersection-roundabout [ offset-x offset-y ]

  let tmp (list)

  let center-x (offset-x + (world-size-x - 1) / 2)
  let center-y (offset-y + (world-size-y - 1) / 2)
    
  
  ;; Center grass
  set tmp patches with [
    (pxcor = center-x or pxcor = (center-x + 1))
    and (pycor = center-y or pycor = (center-y + 1))
  ]
  make-grass tmp
  
  
  ;; Bottom road
  set tmp patches with [
     (pxcor >= (center-x - 1) and pxcor < (center-x + 2))
     and (pycor = (center-y - 1))
  ]
  make-road tmp 2
  set-direction-east tmp true
  
  set tmp (tmp with [ pxcor = center-x + 1 ])
  set-direction-north tmp false
  
  
  ;; Top road
  set tmp patches with [
     (pxcor > (center-x - 1) and pxcor <= (center-x + 2))
     and (pycor = (center-y + 2))
  ]
  make-road tmp 2
  set-direction-west tmp true
  
  set tmp (tmp with [ pxcor = center-x ])
  set-direction-south tmp false
  
  
  ;; Left road
  set tmp patches with [
     (pxcor = (center-x - 1))
     and (pycor > (center-y - 1) and pycor <= (center-y + 2))
  ]
  make-road tmp 2
  set-direction-south tmp true
  
  set tmp (tmp with [ pycor = center-y ])
  set-direction-east tmp false
  
  
  ;; Right road
  set tmp patches with [
     (pxcor = (center-x + 2))
     and (pycor >= (center-y - 1) and pycor < (center-y + 2))
  ]
  make-road tmp 2
  set-direction-north tmp true
  
  set tmp (tmp with [ pycor = center-y + 1 ])
  set-direction-west tmp false
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add cars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to add-from-north
  car-factory "north" 180
end

to add-from-south
  car-factory "south" 0
end

to add-from-east
  car-factory "east" 270
end

to add-from-west
  car-factory "west" 90
end

to car-factory [ location orientation ] 
  let car-color (random 3) * 10 + 84 + (random 8) * 0.5 
  
  ask patches with [ spawn-location = location ] [
    sprout 1 [
      set chosen-direction "undecided"
      set heading orientation
      set color car-color
      set size 1.5
      set previous-turn -1
      set speed 1
    ]
  ]
end

to add-cars-on-frequency
  if (random 100 < north-frequency) [ add-from-north ]
  if (random 100 < south-frequency) [ add-from-south ]
  if (random 100 < east-frequency) [ add-from-east ]
  if (random 100 < west-frequency) [ add-from-west ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Go
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  add-cars-on-frequency
  
  ask turtles [ set moved? false ]
  move-turtles (turtles-on patches with [ priority = 2 ])
  move-turtles (turtles-on patches with [ priority = 1 ])

  switch-lights-on-frequency
  
  tick
end

to move-turtles [ turtle-list ]

  ask turtle-list [ if not moved? [
  
    ;; Get turn choices
    let turn-choices (list)
    if can-go-north? [ set turn-choices (lput 0 turn-choices) ]
    if can-go-south? [ set turn-choices (lput 180 turn-choices) ]
    if can-go-east? [ set turn-choices (lput 90 turn-choices) ]
    if can-go-west? [ set turn-choices (lput 270 turn-choices) ]
    
    ;; Prevent double turn to left/right
    if (previous-turn = 90 or previous-turn = 270) [
      let invalid-turn ((heading + previous-turn) mod 360)
      set turn-choices (remove invalid-turn turn-choices)
    ]
    
    ;; Die if no turn options
    if (length turn-choices = 0) [ die ]
    
    ;; Save current heading
    let previous-heading heading
    
    ;; Make random turn
    if (chosen-direction = "undecided") [
      set chosen-direction (item (random (length turn-choices)) turn-choices)
      set heading chosen-direction
    ]
    
    ;; To which side did turtle turn? (90 - turn right, 270 - turn left)
    let current-turn ((heading - previous-heading) mod 360)
    set previous-turn current-turn
    
    ;; Move at this speed
    ;;let speed 1
    
    ;; Stop if turtle ahead
    ifelse (any? turtles-on patch-ahead 1) [
      set speed 0
    ] [
      set speed (speed + acceleration)
      if speed > 1 [ set speed 1 ]
    ]
    
    ;; Daj prednost v jazde (translate THIS)
    let count-priority 0
    ask patch-ahead 1 [
      set count-priority ( count turtles-on neighbors4 with [ priority = 2 ] )
    ]
    ask patch-here [
      if priority = 2 [ set count-priority 0 ]
    ]
    if count-priority > 0 [ set speed 0 ]   
    
    ;; Stop if on red light
    let tmp speed
    ask patch-here [
      if (patch-type = "intersection" and (not can-go?)) [
        set tmp 0
      ]
    ]
    set speed tmp
    
    ;; Move
    if (speed > 0) [
      forward speed
      set chosen-direction "undecided"
    ]
    
    
    ;; Increment how long turtle is alive
    set ticks-alive ticks-alive + 1
    
  ] set moved? true ]
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Switch lights
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to switch-lights-on-frequency
  if (ticks mod switch-lights-frequency) = 0 [
    switch-lights
  ]
end

to switch-lights
  ask patches with [
    patch-type = "intersection"
  ] [
    ifelse (can-go?) [
      change-light pxcor pycor false
    ] [
      change-light pxcor pycor true
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
170
151
1200
446
-1
-1
12.0
1
6
1
1
1
0
1
1
1
0
84
0
21
1
1
1
ticks
30.0

BUTTON
19
20
85
53
NIL
setup
NIL
1
T
OBSERVER
NIL
I
NIL
NIL
1

BUTTON
1215
269
1348
302
NIL
add-from-east
NIL
1
T
OBSERVER
NIL
E
NIL
NIL
1

BUTTON
613
62
750
95
NIL
add-from-north
NIL
1
T
OBSERVER
NIL
N
NIL
NIL
1

BUTTON
622
464
756
497
NIL
add-from-south
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
28
273
154
306
NIL
add-from-west
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
104
20
189
53
go-once
go
NIL
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
209
21
272
54
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
289
21
401
54
NIL
switch-lights
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
613
102
751
135
north-frequency
north-frequency
0
50
13
1
1
NIL
HORIZONTAL

SLIDER
1214
313
1349
346
east-frequency
east-frequency
0
50
10
1
1
NIL
HORIZONTAL

SLIDER
621
508
758
541
south-frequency
south-frequency
0
50
15
1
1
NIL
HORIZONTAL

SLIDER
27
316
156
349
west-frequency
west-frequency
0
50
17
1
1
NIL
HORIZONTAL

PLOT
158
584
470
758
Turtles count
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"priority" 1.0 0 -11221820 true "" "plot count turtles-on world1"
"interval-lights" 1.0 0 -2674135 true "" "plot count turtles-on world2"
"adaptive-lights" 1.0 0 -13840069 true "" "plot count turtles-on world3"
"roundabout" 1.0 0 -955883 true "" "plot count turtles-on world4"

PLOT
489
584
832
758
Turtles average time spent on road
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"priority" 1.0 0 -11221820 true "" "if (count turtles-on world1 > 0 ) [ plot mean [ticks-alive] of turtles-on world1 ]"
"interval-lights" 1.0 0 -2674135 true "" "if (count turtles-on world2 > 0 ) [ plot mean [ticks-alive] of turtles-on world2 ]"
"adaptive-lights" 1.0 0 -13840069 true "" "if (count turtles-on world3 > 0 ) [ plot mean [ticks-alive] of turtles-on world3 ]"
"roundabout" 1.0 0 -817084 true "" "if (count turtles-on world4 > 0 ) [ plot mean [ticks-alive] of turtles-on world4 ]"

SLIDER
19
67
198
100
switch-lights-frequency
switch-lights-frequency
0
100
80
1
1
NIL
HORIZONTAL

SLIDER
210
68
382
101
acceleration
acceleration
0
1
0.03
0.01
1
NIL
HORIZONTAL

PLOT
845
581
1198
759
Average speed
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"priority" 1.0 0 -11221820 true "" "if (count turtles-on world1 > 0 ) [ plot mean [speed] of turtles-on world1 ]"
"interval-lights" 1.0 0 -2674135 true "" "if (count turtles-on world2 > 0 ) [ plot mean [speed] of turtles-on world2 ]"
"adaptive-lights" 1.0 0 -13840069 true "" "if (count turtles-on world3 > 0 ) [ plot mean [speed] of turtles-on world3 ]"
"roundabout" 1.0 0 -955883 true "" "if (count turtles-on world4 > 0 ) [ plot mean [speed] of turtles-on world4 ]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
1.0 
    org.nlogo.sdm.gui.AggregateDrawing 4 
        org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 174 143 60 40 
            org.nlogo.sdm.gui.WrappedStock "" "" 0   
        org.nlogo.sdm.gui.RateConnection 3 246 162 321 162 396 162 NULL NULL 0 0 0 
            org.jhotdraw.standard.ChopBoxConnector REF 1  
            org.jhotdraw.standard.ChopBoxConnector 
                org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 408 143 60 40 
                    org.nlogo.sdm.gui.WrappedStock "" "" 0    
            org.nlogo.sdm.gui.WrappedRate "" "" REF 2 REF 7 0   
        org.nlogo.sdm.gui.ReservoirFigure "attributes" "attributes" 1 "FillColor" "Color" 192 192 192 371 145 30 30  REF 6
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count turtles-on world1</metric>
    <metric>count turtles-on world2</metric>
    <enumeratedValueSet variable="north-frequency">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="west-frequency">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-color-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="south-frequency">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="east-frequency">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
