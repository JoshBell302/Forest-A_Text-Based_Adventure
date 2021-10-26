; Forest Game			(Forest.asm)
; Authors: Josh Bell and Sierra Freihoeffer
; Course ID: CS-271		Date: 3/2/20
; Description: An adventure game call "Forest" created for the final project for CS-271

INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

; ------------------------------------------------------------------------------
; ---------------------------------Constants------------------------------------
; ------------------------------------------------------------------------------
ARRAY_SIZE = 2 
ERROR = 1
NO_ERROR = 0

.data
; ------------------------------------------------------------------------------
; ---------------------------------Variables------------------------------------
; ------------------------------------------------------------------------------

; ==============================================================================
; Player and Monster Stats
; ==============================================================================
playerArray		DWORD	ARRAY_SIZE	DUP(?); ST=5 SPD=5
wolfArray		DWORD	ARRAY_SIZE	DUP(?); ST=4 SPD=6
bunnyArray		DWORD	ARRAY_SIZE	DUP(?); ST=1 SPD=1
batsArray		DWORD	ARRAY_SIZE	DUP(?); ST=1 SPD=1
giantSpiderArr	DWORD	ARRAY_SIZE	DUP(?); ST=7 SPD=2
trollArray		DWORD	ARRAY_SIZE	DUP(?); ST=6 SPD=6

; ==============================================================================
; Intro and Endings
; ==============================================================================
intro1			BYTE	"You find yourself in a deep forest full of monsters",0
intro2			BYTE	"You are armed with only yourself, you must escape!",0
ending			BYTE	"You have made it out of the forest, YOU WIN!",0
death			BYTE	"You have been slained, YOU LOSE!",0

; ==============================================================================
; Monsters
; ==============================================================================
monstrE			BYTE	"You encountered a monster! You encountered ",0
wolf			BYTE	"a Wolf",0
bunny			BYTE	"a Bunny",0
bats			BYTE	"a Bats",0
giantSpider		BYTE	"a Giant Spider",0
troll			BYTE	"a Troll",0
monsterKilled	BYTE	"You have killed a monster!",0
monsterEvad     BYTE    "You have escaped the monster!",0
monsterEqual	BYTE	"You have equal power, you get away but you go back to your previous spot!",0

; ==============================================================================
; Combat
; ==============================================================================
fightIntro		BYTE	"Would you like to run away, or fight it?",0
fightInst		BYTE	"Fight -> 0, Run Away -> 1",0

; ==============================================================================
; Stats
; ==============================================================================
strengthIncr	BYTE	"You have increased your Strength!",0
speedIncr		BYTE	"You have increased your Speed!",0

; ==============================================================================
; Movement
; ==============================================================================
crossroad		BYTE	"You have found a crossroad!",0
choice			BYTE	"What will you choose: ",0
turnR			BYTE	"Would you like to turn right?",0
turnL			BYTE	"Would you like to turn left?",0
turnU			BYTE	"Would you like to go Up?",0
turnD			BYTE	"Would you like to go down?",0
instTrnLR		BYTE	"Left -> 0, Right -> 1",0
instTrnRU		BYTE	"Right -> 1, Up -> 2",0
instTrnLRU		BYTE	"Left -> 0, Right -> 1, Up -> 2",0
instTrnLRD		BYTE	"Left -> 0, Right -> 1, Down -> 3",0
instTrnLRUD		BYTE	"Left -> 0, Right -> 1, Up -> 2, Down -> 3",0
continue		BYTE	"Press 'Enter' to continue on your journey!"

direction1		DWORD	?
direction2		DWORD	?
direction3		DWORD	?

; ==============================================================================
; Map Values
; ==============================================================================
mapCurrent		DWORD	14
updateMapValue	DWORD	?
mapPrevious		DWORD	?

; ==============================================================================
; Error
; ==============================================================================
errorPrompt		BYTE	"There was an error from your typed value. Please try again!",0

; ==============================================================================
; Other
; ==============================================================================
textBoxLine		BYTE	"================================================================================",0
typedValue		DWORD	?

; ==============================================================================
; ASCII Art
; ==============================================================================
w1 BYTE "                                                  ,,,;,,,                 ",0
w2 BYTE "                       ,,ggg@@@@@@@@@g@@@@@@@@@g@@$$@@$MllliLL,           ",0
w3 BYTE "                  ,g@@@@$$$@$@@$@@@$@@$@@@@@@@@M$&&$@@&%$LlL|L||Lg$@F     ",0
w4 BYTE "                g$Mll$$$&$@$$@$$@@$@$@@@$@$@$$@&&$$$@$&l$$Tll|T|||lT      ",0
w5 BYTE "              ,T||||l$@$$@@@$$$@@$$$$$@@$$gggg$$$@$$&l@Lllll|||lTL|L      ",0
w6 BYTE "              |L||l$@$$@@$@$$$@@$$@$$$&@@$gg$gg$g$$g$g&$$l|||lL||||ljg    ",0
w7 BYTE "             |||||l$@$$$$@@@$@@$$@$$@$gg$$g$$@M$$ll||lW|L|@@|||@@ lll     ",0
w8 BYTE "             ||l|L|&$$$$$$$$$@$R$$&g$$g$&$$g$$$$Ml||LlWL||||||||' ||&L    ",0
w9 BYTE "             |lj@l$#$$$$$@$$$MM$Ti$&&g$$$&M&$$l|lllll$$lW|||||LL |l`      ",0
w10 BYTE "             |ll$@j$$$$$$$$g$l$l|!l&g$$M$llll|||||||lllW|w|||]$L|`        ",0
w11 BYTE "             ll$$$@l$$@&&ll$l|llL|ljW$$lT|||||l|||||||||||w|j$$@`         ",0
w12 BYTE "             j$Ql&$ll&M$llL||$|L||||||l|||!'` |||||l' lll|||              ",0
w13 BYTE "             j$$l$$|lll||||,@&M'              ||||L    l||||              ",0
w14 BYTE "             }&&$$$k&lT||;@$TL                ||||      ||||              ",0
w15 BYTE "              lll$Fll||,$$TF                  ||||       ||||             ",0
w16 BYTE "              |l$|lL||/l$|L                   '|||       '|||             ",0
w17 BYTE "               |||||L$$$||                     |||        l|||            ",0
w18 BYTE "                ||||  $L|L                     |||         |||            ",0
w19 BYTE "                 l||   $L|                    ||||         *||            ",0
w20 BYTE "                  ||L   'l|L                   |||          }||           ",0
w21 BYTE "                  }|lw,,  '|llllL              '||           |||,,        ",0
w22 BYTE "                   W&#W&P                       ||gllL,       *M=4R*      ",0
w23 BYTE "                                                 ``````                   ",0


r1 BYTE "                                             gTw,         gF   ",0
r2 BYTE "                                             ll&$%     ,g$T    ",0
r3 BYTE "                                             $&$$W$,  g$$$`    ",0
r4 BYTE "                                             ]$$$W$$,/@$$L     ",0
r5 BYTE "                                              '$$$@$@@$$$      ",0
r6 BYTE "                                               l$$$$$$$@$      ",0
r7 BYTE "                                              ,$&|ll$$$$$@     ",0
r8 BYTE "                                              llllQ&W&$$$$r    ",0
r9 BYTE "                                          ,,,=|llT$ll$$$$$$L   ",0
r10 BYTE "                                       ,$$l&$@&lL||l&$$@&&$F   ",0
r11 BYTE "                                     a$$&$$l$l$$@@l|l$&$|$L    ",0
r12 BYTE "                                   ,lllllll&&ll&@$$&&$@$$L     ",0
r13 BYTE "                                  ,llLllll&$L|$@$$$$$$@$$L     ",0
r14 BYTE "                                  ||l|lllTl$T|AW$MM&l$$&*      ",0
r15 BYTE "                                  |||||||L||l&&$@$l$@@$        ",0
r16 BYTE "                                  |TL|||||||$$@$@$$$$$L        ",0
r17 BYTE "                                  l||1$@$g@@$$$$$$$$$$@@,      ",0
r18 BYTE "                                   |$$$$$@@&l$$$&$ @$$$$T      ",0
r19 BYTE "                                            '5MM&**Tl'''       ",0

b1 BYTE "           yg                                                                       ",0
b2 BYTE "           ^*@@.                                 7BNgg                    g         ",0
b3 BYTE "             *'$@@ggg                              ]@@@N                  'J@4N'    ",0
b4 BYTE "                + ]P*N*-              g@P           @@@@@g                          ",0
b5 BYTE "                                    g@@@           *B@@@@@p                         ",0
b6 BYTE "                                   $@@@C             *$@@@@                         ",0
b7 BYTE "                           ,;,  &]g@@@P               $@@@@P gK                     ",0
b8 BYTE "                       ^*MB@@@@@@@@@                  ']%@@N@@gg@  ;gggggggg;       ",0
b9 BYTE "                           --'*L  '                      ]@@@@@@g@@@@@@@@@@@@@N,    ",0
b10 BYTE "                                                         ]@@@@@NB@@@@NN@@@P*,-[7V   ",0
b11 BYTE "           ,;                          +gg                 ->     *7    +           ",0
b12 BYTE "            =7B@Nwg                      PB@g;p-,ggggg.                             ",0
b13 BYTE "               3@@@@@N,                    }-%@'PP**                                ",0
b14 BYTE "                ]@@@@@@@@,                                               ,          ",0
b15 BYTE "                 '*%@@@@@@@p  y@  ,                                    g@@          ",0
b16 BYTE "                     %@@@@@@g;@@g@@     ,gg/,                        ,@@@7          ",0
b17 BYTE "                     **T'7MB@@@@@@gg@@@@@@@@@@@@@@@gg,             g $@Nh           ",0
b18 BYTE "                            @@@@@@N@@@@@@@@@@@@@N*T^*'[-          %@@@r             ",0
b19 BYTE "                            ]RNPC    ]%@P7<-<*7'               gg@@P**|             ",0
b20 BYTE "             ~g,,@'                    -                     g@@@NC                 ",0
b21 BYTE "               +-                                           P*P'                    ",0

s1 BYTE "                                                    ;gC                     ",0
s2 BYTE "                                            ,g@B$F+]M& Np                   ",0
s3 BYTE "                                          ;@$PZ      w'Q$&.                 ",0
s4 BYTE "                                 ggg,    ] B7/   -..  + R$                  ",0
s5 BYTE "                           gmp@7 @gg BN    PV(pC]] gg-r7J$ g@QP$%Mw         ",0
s6 BYTE "                            7ZJ[g, Z gM&N Qgggj$gg[*7$^yy@Qg$PP7J7NR&ggg    ",0
s7 BYTE "                       ,ggB$BJ$$<+/]PB$gPJ$7-@72P*R $gg  D$$g$Bw;  ]N gBP   ",0
s8 BYTE "                     g@@jg NPT*=]Bg@@E$$q7?  J    v[$ $hj$gPP&$LZ@g         ",0
s9 BYTE "                ,gmBQg@B7-    gggRPPPB  $$gggggg,'[@D @&pC$ , *%@QE$g       ",0
s10 BYTE "                RNPP*      y&P<,>};u7g $ZF 4PC`*$$$B$@$$g&$C$p   &@g @g     ",0
s11 BYTE "                         gP]$BggN$NPZ$ $C`  p  [I$ gL $~  3@F&-   *%g$]Bp   ",0
s12 BYTE "                      g@Dy$@R7 ,BZ$p$@ $+- J@  Q$ @ P $    1gg$     ] @@BB@ ",0
s13 BYTE "                   ggB]&NgB7   $nI@P7 D$@g@2$-.7@ P4MMPp    $PZg      JN@W$ ",0
s14 BYTE "                 g$@72$@P     ] ggP  $L$-$P '$@$$P -@t-E      C$p        777",0
s15 BYTE "                $C-e&B*       @Q$$   4B$      &g@   $@g&     7PP&           ",0
s16 BYTE "              y ?ZgP         ]p-$P   ]&      ]p$@   JEP]      $@L$          ",0
s17 BYTE "            ,@S]$P7          $ZQ$    ]@$      /QP   -@p@       $@ N         ",0
s18 BYTE "            ]NPP=            @]$P     %@    $$ B     @uJ@       $CQ -       ",0
s19 BYTE "                           gPZq@            J7'      $Qg  -      2BBP       ",0
s20 BYTE "                          $$;gP                      7KvC$                  ",0
s21 BYTE "                           J[                         -%@$P                 ",0

t1 BYTE "                                        ggPC?%=ZB                                 ",0
t2 BYTE "                                      ,gN%      ]$                                ",0
t3 BYTE "                                   ,%**L**    ]@@P                                ",0
t4 BYTE "                                   $P @     @  C&]$                               ",0
t5 BYTE "                                   '%  (..)     -R7$w                             ",0
t6 BYTE "                                    @P  ____ |||||,@gQ$Q$&g,                      ",0
t7 BYTE "                             g@N[TT1|| [    ]    |||$@@AT^J]5$$@,                 ",0
t8 BYTE "                           ,$@`yLj@     ----     ;g@Py$`]  -] 'BB@                ",0
t9 BYTE "                         ,g$F[ Q         - ,g   '''  ''&@A+ C-  F`F$]             ",0
t10 BYTE "                        g$4 f]&@.    agk       \y`` ` ]$&QN&-F F P J$Bg           ",0
t11 BYTE "                      ,@PL- lg@$B  0 /gg]^ ]A ;  ,0   $$ *  \gP L  ]]&@           ",0
t12 BYTE "                      &  ] ,g$@hLRRRNC$,  -    $$B$RD&&  &\   \@$ gg -$@          ",0
t13 BYTE "                    yB& l]@$@5@ P,  T  y  t }  1 ] C]g@ $$@     \$$$ ]$@P         ",0
t14 BYTE "                   /QJ C$@P7  @gC    VP, VTJ, }  } } C  TJ$C     @@L [@@P         ",0
t15 BYTE "                  ]@D L$$P    $NN  'F $g&]], \ '  } } C-[j1       @${ Q$$`        ",0
t16 BYTE "                  B@  -@$P    '%@K|g|p$ /yC1,Jy-yg4=)+$',@        $@F $$@         ",0
t17 BYTE "                  $rJ jJ@       y$7ZTPPYPPfrhPfPPPPP$$@B$@         $&  P&W        ",0
t18 BYTE "                 ]$.\\$Q$      )$&QBg g          ,g@$@@@P[]P      @ ] CJ]&        ",0
t19 BYTE "                ,B|||$A      ,$$&%@$ $K ,     $@$@@@$ [ Q@P     @* L  g,A]%g      ",0
t20 BYTE "             ;w4$ |||J@      A@Fcc$$@$& $@   @K$  $KF]C J$$@P     $F   ];& %@$$   ",0
t21 BYTE "            PQ|  |||||&g,   KP@WP T*F7] $- , $$   KKP*+ LQ'@$7          ]&BP$     ",0
t22 BYTE "               p|||Y I1'P   R$$J.R$,F/@@          $$. gwC] @&F                    ",0
t23 BYTE "               Anr)P       @@  &@CQg$P            B$- C4wA $($                    ",0
t24 BYTE "                           JRY5 - T$$P            1@lP}    ]$@                    ",0
t25 BYTE "                           gP$ggggL7@K           NP4P$@$$PM@@                     ",0
t26 BYTE "                           P'1   w;,&           @*/''$ ,+r$$&p                    ",0
t27 BYTE "                          ]w~C,@]=+CJ@         @  }][;,4ggwmMC                    ",0


 lr1 BYTE "ggggggg                         gggm   ggggggg                          ppzggggg",0
 lr2 BYTE "$$$$$$@                         $$$@   $$$$$$@                           p$$$$$$",0
 lr3 BYTE "$$$$$$@              ,g,        $$$P   @$$$$$K           g@C              $$$$$$",0
 lr4 BYTE "$$$$$$                ]RB@Ngg   $$$F   $$$$$$P       ,g@@C                $$$$$$",0
 lr5 BYTE "$$$$$$P                   ZRB$@@$$$F   $$$$$$P     g@$NP                  $$$$$$",0
 lr6 BYTE "$$$$$@                       ]$$$$$F  ]$$$$$$P  y@@$P-                    $$$$$$",0
 lr7 BYTE "$$$$$P                        $$$$$   ]$$$$$$Pg@$NC                       $$$$$$",0
 lr8 BYTE "$$$$$P                        $$$$$   ]$$$$$$$$B7                         $$$$$@",0
 lr9 BYTE "$$$$$P                        $$$$$   ]$$$$$$B-                           $$$$$@",0
 lr10 BYTE "$$$$$P                        ]$$$$   ]$$$$$@P                            $$$$$$",0
 lr11 BYTE "$$$$$P                        ]$$$$F  ]$$$$$@P                            $$$$$$",0
 lr12 BYTE "$$$$$P                        $$$$$F  J$$$$$$@                            $$$$$$",0
 lr13 BYTE "$$$$$F                        $$$$$F  J$$$$$$@                            $$$$$$",0
 lr14 BYTE "$$$$$F                        $$$$$   ]$$$$$$$                            $$$$$$",0
 lr15 BYTE "$$$$$F                        $$$$@   ]$$$$$$$                            $$$$$$",0
 lr16 BYTE "$$$$$-                      g@$$$$@@g@@$$$$$$$                            $$$$$$",0
 lr17 BYTE "$$$$$                       $$P-J&$$$N*$$$$$$$ ,,                         $$$$$$",0
 lr18 BYTE "$$$$$P                    gg$@g|||%P*||$$$$$$@PPMB@p                      $$$$$$",0
 lr19 BYTE "$$$$$P                   $$$*||||||||||$$$$$$@||||$@                      $$$$$$",0
 lr20 BYTE "$$$$$P                   ]$@|||||||||-@$PPBB$|||| $@                      $$$$$$",0
 lr21 BYTE "$$$$$F                     1N||||||| ]$`||||||||||y$@                     $$$$$$",0
 lr22 BYTE "$$$$$F                               &$g||||||||||\@                      $$$$$$",0
 lr23 BYTE "$$$$$                                  T |||||                            $$$$$$",0
 lr24 BYTE "$@$$$                                                                     $$$$$$",0
 lr25 BYTE "$$R@C                                                                     $$$$$$",0


 lrs1 BYTE "J$$$$$$$B             $$$$$        ,$$@\           $$$$&P         g$$@P*     $$$",0
 lrs2 BYTE "@$$$$$@-              $$$$$       g$$$             $$$$&@@    ,@@$$N*        @$$",0
 lrs3 BYTE "$$$$$B               ]$$$$$     g$$C'$$W,          $$$$$&@  g$$$@P           $$$",0
 lrs4 BYTE "$$$$$                $$$$$$   g$@C    $$$g         ]$$$$$@g$$@P-             $$$",0
 lrs5 BYTE "$$$$@                $$$$$$ y$@P       1$$@        ]$$$$$$$P*               ]$$$",0
 lrs6 BYTE "$$$$$                $$$$$$$$C          ]$$$g      $$$$$$F                  $$$$",0
 lrs7 BYTE "$$$$@               ]$$$$$$P              $$$&     $$$$$@                   $$$$",0
 lrs8 BYTE "$$$$P               J$$$$&@                1$$$g   $$$$$@                   $$$$",0
 lrs9 BYTE "$$$$P               ]$$$$&P                  ]$$@g $$$$$P                   $$$$",0
 lrs10 BYTE "$$$$P               ]$$$$&P                   '$$$&@$$$$P                   $$$$",0
 lrs11 BYTE "$$$$                ]$$$$&P                     1$$$$$$$P                   $$$$",0
 lrs12 BYTE "$$$$                ]$$$$$P                      ]$$$$$$P                  ]$$$$",0
 lrs13 BYTE "$$$$                $$$$$$P                       @@$$$$P                  $$$$$",0
 lrs14 BYTE "$$$$                $$$$&$                        ]$$$&$P                  $$$$$",0
 lrs15 BYTE "$$$$                $$$$$&                        $$$$&$P                  @$$$$",0
 lrs16 BYTE "$$$$                $$$$$$                        $$$$$$                   $$$$@",0
 lrs17 BYTE "$$$$                @$$$$$                        $$$$$$                   $$$$F",0
 lrs18 BYTE "$$$$P               @$$$$$                        $$$$$$                  @$$$$$",0
 lrs19 BYTE "$$$$@               $$$$$E                        $$$$$$                  $$$$$$",0
 lrs20 BYTE "$$$$$              ,$$$$$$                       ]$$$$$F                  $$$$@$",0
 lrs21 BYTE "$$$$$             ;$$$$$$$g                      $$$$||$$F               @$$$$$$",0
 lrs22 BYTE "$$$$$            g$$$$$$$$$@p                   /$$||||||$-              $$$$$@$",0
 lrs23 BYTE "$$$$$P         g@$FC@$$@*%N$$g                )@$$||J$$||||&F           $$$$$$@$",0
 lrs24 BYTE "$$$$$@        '*    @&     ]M&N              ^P&F||||||||||             $$$$$$@$",0
 lrs25 BYTE "$$$$$$P                                                                 $$$$$1@$",0

; ------------------------------------------------------------------------------
; ---------------------------------Macro code-----------------------------------
; ------------------------------------------------------------------------------

; ==============================================================================
; updateMap MACRO 
; ------------------------------------------------------------------------------
; Parameters:	updateValue
; ------------------------------------------------------------------------------
; Definition:	Checks the "updateValue" to see what direction the player chose.
;				Next place the current value of "mapCurrent" to "mapPrevious"
;				then update the "mapCurrent" value to see where they are now.
;               There are some special cases where the normal updating procedure
;               doesn't apply if this is true, then we use the special sections
;               to update the "mapCurrent" value to the correct value.
; ------------------------------------------------------------------------------
; Sections:		**moveLeft
;               **specialLeft
;				**moveRight
;               **specialRight1
;               **specialRight2
;				**moveUp
;               **specialUp1
;               **specialUp2
;				**moveDown
;               **specialDown1
;               **specialDown2
;               **specialDown3
;				**done
; ==============================================================================
updateMap MACRO updateValue
mov EAX, mapCurrent                     ; Moves "mapCurrent" into EAX
mov mapPrevious, EAX                    ; Moves the value of EAX into "mapPrevious"
mov EAX, updateValue                    ; Moves "updateValue" into EAX

cmp EAX, 0                              ; Compares the value of EAX to 0
je moveLeft                             ; If "updateValue" is 0 jump to moveLeft
cmp EAX, 1                              ; Compares the value of EAX to 1
je moveRight                            ; If "updateValue" is 1 jump to moveLeft
cmp EAX, 2                              ; Compares the value of EAX to 2
je moveUp                               ; If "updateValue" is 2 jump to moveLeft
cmp EAX, 3                              ; Compares the value of EAX to 3
je moveDown                             ; If "updateValue" is 3 jump to moveLeft

moveLeft:
mov EAX, 31                             ; Moves the value of 31 into EAX, this is used for a special movement comparement
dec mapCurrent                          ; Decrement "mapCurrent" value
cmp EAX, mapCurrent                     ; Compares the value of "mapCurrent" and EAX
je specialLeft                          ; If they are equal then jump to specialLeft
jmp done                                ; After "mapCurrent" is decremented then jump to done

specialLeft:
mov EAX, 43                             ; Moves the value of 43 into EAX
mov mapCurrent, EAX                     ; Moves the value of EAX into "mapCurrent"
jmp done                                ; Jump to done after "mapCurrent" is updated

moveRight:
mov EAX, 16                             ; Moves the value of 16 into EAX, this is used for a special movement comparement
mov EBX, 33c
inc mapCurrent                          ; Increment "mapCurrent" value
cmp EAX, mapCurrent                     ; Compares the value of "mapCurrent" and EAX
je specialRight1                        ; If the values are equal jump to specialRight1
cmp EBX, mapCurrent                     ; Compares the value of "mapCurrent" and EBX
je specialRight2                        ; If the values are equal jump to specialRight2
jmp done                                ; After "mapCurrent" is decremented then jump to done

specialRight1:
mov EAX, 32                             ; Moves the value of 32 into EAX
mov mapCurrent, EAX                     ; Moves the value of EAX into "mapCurrent"
jmp done                                ; Jump to done after "mapCurrent" is updated

specialRight2:
mov EAX, 15                             ; Moves the value of 15 into EAX
mov mapCurrent, EAX                     ; Moves the value of EAX into "mapCurrent"
jmp done                                ; Jump to done after "mapCurrent" is updated

moveUp:
mov EAX, 22                             ; Moves the value of 22 into EAX, this is used for a special movement comparement
mov EBX, 25                             ; Moves the value of 25 into EBX
add mapCurrent, 10                      ; Adds 10 to "mapCurrent" value
cmp EAX, mapCurrent                     ; Compares the value of "mapCurrent" and EAX
je specialUp1                           ; If the values are equal jump to specialUp1
cmp EBX, mapCurrent                     ; Compares the value of "mapCurrent" and EBX
je specialUp2                           ; If the values are equal jump to specialUp2
jmp done                                ; Jump to done after "mapCurrent" is updated

specialUp1:
mov EAX, 41                             ; Moves the value of 41 into EAX
mov mapCurrent, EAX                     ; Moves the value of EAX into "mapCurrent"
jmp done                                ; Jump to done after "mapCurrent" is updated

specialUp2:
mov EAX, 21                             ; Moves the value of 21 into EAX
mov mapCurrent, EAX                     ; Moves the value of EAX into "mapCurrent"
jmp done                                ; Jump to done after "mapCurrent" is updated

moveDown:
mov EAX, 33                             ; Moves the value of 33 into EAX, this is used for a special movement comparement
mov EBX, 21                             ; Moves the value of 21 into EBX
mov ECX, 22                             ; Moves the value of 22 into ECX
sub mapCurrent, 10                      ; Subtracts 10 to "mapCurrent" value
cmp EAX, mapCurrent                     ; Compares the value of "mapCurrent" and EAX
je specialDown1                         ; If the values are equal jump to specialDown2
cmp EBX, mapCurrent                     ; Compares the value of "mapCurrent" and EBX
je specialDown2                         ; If the values are equal jump to specialDown2
cmp ECX, mapCurrent                     ; Compares the value of "mapCurrent" and ECX
je specialDown3                         ; If the values are equal jump to specialDown3
jmp done                                ; Jump to done after "mapCurrent" is updated

specialDown1:
mov EAX, 32                             ; Moves the value of 32 into EAX
mov mapCurrent, EAX                     ; Moves the value of EAX into "mapCurrent"
jmp done                                ; Jump to done after "mapCurrent" is updated

specialDown2:
mov EAX, 12                             ; Moves the value of 12 into EAX
mov mapCurrent, EAX                     ; Moves the value of EAX into "mapCurrent"
jmp done                                ; Jump to done after "mapCurrent" is updated

specialDown3:
mov EAX, 21                             ; Moves the value of 21 into EAX
mov mapCurrent, EAX                     ; Moves the value of EAX into "mapCurrent"
jmp done                                ; Jump to done after "mapCurrent" is updated

done:
call Clrscr                             ; Clears the screen for the next procedure
ENDM

; ==============================================================================
; errorRead MACRO 
; ------------------------------------------------------------------------------
; Parameters:	lowerB, higherB, value
; ------------------------------------------------------------------------------
; Definition:	Checks the "lowerB" value and "higherB" value and compares the 
;				typed value to check if that value is within [MIN: lowerB and 
;				MAX:higherB]. If "value" is in bounds then then it returns 
;				NO_ERROR, and if its not then returns ERROR.
; ------------------------------------------------------------------------------
; Sections:		**errorFound
;				**inBound
;				**done2
; ==============================================================================
errorRead MACRO lowerB, higherB, value
mov EAX, lowerB                         ; Moves the value of "lowerB" into EAX
mov EBX, higherB                        ; Moves the value of "higherB" into EBX
cmp value, EAX                          ; Compares the values of "value" and EAX
jl errorFound                           ; If the value is less than "lowerB" than jump to errorFound
cmp value, EBX                          ; Compares the values of "value" and EBX
jg errorFound                           ; If the value is more than "higherB" than jump to errorFound
jmp inBound                             ; If the typed value is in bounds than jump to inBound

errorFound:
mov EAX, ERROR                          ; Moves the value of ERROR into EAX
jmp done2                               ; Jumps to done2

inBound:
mov EAX, NO_ERROR                       ; Moves the value of NO_ERROR into EAX
jmp done2                               ; Jumps to done2

done2:
call Crlf
ENDM

; ==============================================================================
; errorReadLRD MACRO 
; ------------------------------------------------------------------------------
; Parameters:	boundL, boundR, boundD, value
; ------------------------------------------------------------------------------
; Definition:	Checks the "boundL" value, "boundR" value, and "boundD" value
;				and checks to see if the typed value is either one of these 
;				bound. If "value" is equal to one of these bounds then then it 
;				returns NO_ERROR, and if its not then returns ERROR.
; ------------------------------------------------------------------------------
; Sections:		**errorFoundLRD
;				**inBoundLRD
;				**done3
; ==============================================================================
errorReadLRD MACRO boundL, boundR, boundD, value
mov EAX, boundL                         ; Moves the value of "boundL" into EAX
mov EBX, boundR                         ; Moves the value of "boundR" into EBX
mov ECX, boundD                         ; Moves the value of "boundD" into ECX
cmp value, EAX                          ; Compares the value of "value" and EAX
je inBoundLRD                           ; If they are equal jump to inBoundLRD
cmp value, EBX                          ; Compares the value of "value" and EBX
je inBoundLRD                           ; If they are equal jump to inBoundLRD
cmp value, ECX                          ; Compares the value of "value" and ECX
je inBoundLRD                           ; If they are equal jump to inBoundLRD
jmp errorFoundLRD                       ; Jumps to errorFoundLRD

errorFoundLRD:
mov EAX, ERROR                          ; Moves the value of ERROR into EAX
jmp done3                               ; Jumps to done3

inBoundLRD:
mov EAX, NO_ERROR                       ; Moves the value of NO_ERROR into EAX
jmp done3                               ; Jumps to done3

done3:
call Crlf
ENDM

; ==============================================================================
; monsterAttack MACRO 
; ------------------------------------------------------------------------------
; Parameters:	monsterName, monsterArray
; ------------------------------------------------------------------------------
; Definition:	The player selects the type of technique to use to combat the
;				monster, either fighting or running away. Fighting uses the 
;				Strength stat [ST] and Running away uses the Speed stat [SPD].
;				Then the players choice and compares their stat to the monsters.
;				If the players stat value is greater than the monsters, they	
;				beat it and they increment their stat used. They also might 
;               have a special movement that involves the player to continue the 
;               path and have a special "mapCurrent" value shifting. If the 
;               stats are even then they get away, return back to their previous 
;               spot, but no stat gained. If the players stat value is lower than 
;               the monsters stat value, they lose and the game is over.
; ------------------------------------------------------------------------------
; Sections:		**run_away
;               **lose
;               **win
;               **beginCombat
;               **errorCombat
;               **inBoundCombat
;               **escaped
;               **equal
;               **specialMovement1
;               **specialMovement2
;               **specialMovement3
;               **sm1MoveUp
;               **sm1MoveDown
;               **smContinue
; ==============================================================================
monsterAttack MACRO  monsterName, monsterArray
	LOCAL runAway                       ; Localizes the Sections
	LOCAL lose
	LOCAL win
	LOCAL beginCombat
	LOCAL errorCombat
	LOCAL inBoundCombat
	LOCAL escaped
	LOCAL equal
	LOCAL specialMovement1
	LOCAL specialMovement2
	LOCAL specialMovement3
	LOCAL sm1MoveUp
	LOCAL sm1MoveDown
	LOCAL smContinue

beginCombat:
	mov EDX, OFFSET monstrE 
	call WriteString 
	mov EDX, OFFSET monsterName
	call WriteString
	call Crlf
	mov ESI, OFFSET playerArray
	mov EDI, OFFSET monsterArray
	mov EDX , OFFSET fightIntro
	call WriteString 
	call Crlf
	mov EDX, OFFSET fightInst
	call WriteString
	call Crlf
	mov EDX, OFFSET choice
	call WriteString
	call ReadInt
	call Crlf

	mov typedValue, EAX

	mov EAX, 0
	cmp typedValue, EAX
	jl errorCombat

	mov EAX, 1
	cmp typedValue, EAX
	jg errorCombat

	jmp inBoundCombat

errorCombat:
	mov EDX, OFFSET errorPrompt
	call WriteString
	call Crlf 
	call Crlf
	jmp beginCombat

inBoundCombat:
	mov EAX, typedValue
	cmp EAX, 0
	jg runAway
	mov EBX, [ESI]
	mov EAX, [EDI]
	cmp EAX, EBX
	jg lose
	cmp EAX, EBX
	je equal
	jmp win

runAway:
	mov EBX, [ESI+4]
	mov EAX, [EDI+4]
	cmp EAX, EBX
	jg lose
	cmp EAX, EBX
	je equal
	jmp escaped

lose:
	mov EDX, OFFSET death
	call WriteString
	call Crlf
	call ReadInt
	invoke ExitProcess,0

win:
	mov EDX, OFFSET monsterKilled
	call WriteString
	call Crlf 
	mov EDX, OFFSET strengthIncr
	call WriteString
	call Crlf

	mov ECX, 21
	cmp ECX, mapCurrent
	je specialMovement1

	mov ECX, 42
	cmp ECX, mapCurrent
	je specialMovement2

	mov ECX, 44
	cmp ECX, mapCurrent
	je specialMovement3

	add EBX, 1
	mov [ESI], EBX
	mov EAX, mapPrevious
	mov mapCurrent, EAX

	mov EDX, OFFSET continue
	call WriteString
	call ReadInt
	call continueGame

escaped:
	mov EDX, OFFSET monsterEvad
	call WriteString
	call Crlf 
	mov EDX, OFFSET speedIncr
	call WriteString
	call Crlf

	mov ECX, 21
	cmp ECX, mapCurrent
	je specialMovement1

	mov ECX, 42
	cmp ECX, mapCurrent
	je specialMovement2

	mov ECX, 44
	cmp ECX, mapCurrent
	je specialMovement3

	add EBX, 1
	mov [ESI+4], EBX
	mov EAX, mapPrevious
	mov mapCurrent, EAX

	mov EDX, OFFSET continue
	call WriteString
	call ReadInt
	call continueGame

equal:
	mov EAX, mapPrevious
	mov mapCurrent, EAX
	mov EDX, OFFSET monsterEqual
	call WriteString
	call Crlf
	mov EDX, OFFSET continue
	call WriteString
	call ReadInt
	call continueGame

specialMovement1:
	mov EBX, 15
	mov ECX, 32
	cmp updateMapValue, 2
	je sm1MoveUp
	cmp updateMapValue, 3
	je sm1MoveDown

	sm1MoveUp:
	mov mapCurrent, ECX
	jmp smContinue

	sm1MoveDown:
	mov mapCurrent, EBX
	jmp smContinue

	smContinue:
	mov EDX, OFFSET continue
	call WriteString
	call ReadInt
	call continueGame

specialMovement2:
	mov ECX, 43
	mov mapCurrent, ECX
	mov EDX, OFFSET continue
	call WriteString
	call ReadInt
	call continueGame

specialMovement3:
	mov ECX, 45
	mov mapCurrent, ECX
	mov EDX, OFFSET continue
	call WriteString
	call ReadInt
	call continueGame

ENDM

; ------------------------------------------------------------------------------
; ---------------------------------Procedures-----------------------------------
; ------------------------------------------------------------------------------

.code
; ==============================================================================
; ASCII Drawing Code
; ==============================================================================
    wolfArt proc
      mov EDX, OFFSET w1
      call WriteString
      call Crlf
      mov EDX, OFFSET w2
      call WriteString
      call Crlf
      mov EDX, OFFSET w3
      call WriteString
      call Crlf
      mov EDX, OFFSET w4
      call WriteString
      call Crlf
      mov EDX, OFFSET w5
      call WriteString
      call Crlf
      mov EDX, OFFSET w6
      call WriteString
      call Crlf
      mov EDX, OFFSET w7
      call WriteString
      call Crlf
      mov EDX, OFFSET w8
      call WriteString
      call Crlf
      mov EDX, OFFSET w9
      call WriteString
      call Crlf
      mov EDX, OFFSET w10
      call WriteString
      call Crlf
      mov EDX, OFFSET w11
      call WriteString
      call Crlf
      mov EDX, OFFSET w12
      call WriteString
      call Crlf
      mov EDX, OFFSET w13
      call WriteString
      call Crlf
      mov EDX, OFFSET w14
      call WriteString
      call Crlf
      mov EDX, OFFSET w15
      call WriteString
      call Crlf
      mov EDX, OFFSET w16
      call WriteString
      call Crlf
      mov EDX, OFFSET w17
      call WriteString
      call Crlf
      mov EDX, OFFSET w18
      call WriteString
      call Crlf
      mov EDX, OFFSET w19
      call WriteString
      call Crlf
      mov EDX, OFFSET w20
      call WriteString
      call Crlf
      mov EDX, OFFSET w21
      call WriteString
      call Crlf
      mov EDX, OFFSET w22
      call WriteString
      call Crlf
      mov EDX, OFFSET w23
      call WriteString
      call Crlf
      ret
    wolfArt endp

; ------------------------------------------------------------------------------

    bunnyArt proc
      mov EDX, OFFSET r1
      call WriteString
      call Crlf
      mov EDX, OFFSET r2
      call WriteString
      call Crlf
      mov EDX, OFFSET r3
      call WriteString
      call Crlf
      mov EDX, OFFSET r4
      call WriteString
      call Crlf
      mov EDX, OFFSET r5
      call WriteString
      call Crlf
      mov EDX, OFFSET r6
      call WriteString
      call Crlf
      mov EDX, OFFSET r7
      call WriteString
      call Crlf
      mov EDX, OFFSET r8
      call WriteString
      call Crlf
      mov EDX, OFFSET r9
      call WriteString
      call Crlf
      mov EDX, OFFSET r10
      call WriteString
      call Crlf
      mov EDX, OFFSET r11
      call WriteString
      call Crlf
      mov EDX, OFFSET r12
      call WriteString
      call Crlf
      mov EDX, OFFSET r13
      call WriteString
      call Crlf
      mov EDX, OFFSET r14
      call WriteString
      call Crlf
      mov EDX, OFFSET r15
      call WriteString
      call Crlf
      mov EDX, OFFSET r16
      call WriteString
      call Crlf
      mov EDX, OFFSET r17
      call WriteString
      call Crlf
      mov EDX, OFFSET r18
      call WriteString
      call Crlf
      mov EDX, OFFSET r19
      call WriteString
      call Crlf
      ret
    bunnyArt endp

; ------------------------------------------------------------------------------

    batsArt proc
      mov EDX, OFFSET b1
      call WriteString
      call Crlf
      mov EDX, OFFSET b2
      call WriteString
      call Crlf
      mov EDX, OFFSET b3
      call WriteString
      call Crlf
      mov EDX, OFFSET b4
      call WriteString
      call Crlf
      mov EDX, OFFSET b5
      call WriteString
      call Crlf
      mov EDX, OFFSET b6
      call WriteString
      call Crlf
      mov EDX, OFFSET b7
      call WriteString
      call Crlf
      mov EDX, OFFSET b8
      call WriteString
      call Crlf
      mov EDX, OFFSET b9
      call WriteString
      call Crlf
      mov EDX, OFFSET b10
      call WriteString
      call Crlf
      mov EDX, OFFSET b11
      call WriteString
      call Crlf
      mov EDX, OFFSET b12
      call WriteString
      call Crlf
      mov EDX, OFFSET b13
      call WriteString
      call Crlf
      mov EDX, OFFSET b14
      call WriteString
      call Crlf
      mov EDX, OFFSET b15
      call WriteString
      call Crlf
      mov EDX, OFFSET b16
      call WriteString
      call Crlf
      mov EDX, OFFSET b17
      call WriteString
      call Crlf
      mov EDX, OFFSET b18
      call WriteString
      call Crlf
      mov EDX, OFFSET b19
      call WriteString
      call Crlf
      mov EDX, OFFSET b20
      call WriteString
      call Crlf
      mov EDX, OFFSET b21
      call WriteString
      call Crlf
      ret
    batsArt endp

; ------------------------------------------------------------------------------

    spiderArt proc
      mov EDX, OFFSET s1
      call WriteString
      call Crlf
      mov EDX, OFFSET s2
      call WriteString
      call Crlf
      mov EDX, OFFSET s3
      call WriteString
      call Crlf
      mov EDX, OFFSET s4
      call WriteString
      call Crlf
      mov EDX, OFFSET s5
      call WriteString
      call Crlf
      mov EDX, OFFSET s6
      call WriteString
      call Crlf
      mov EDX, OFFSET s7
      call WriteString
      call Crlf
      mov EDX, OFFSET s8
      call WriteString
      call Crlf
      mov EDX, OFFSET s9
      call WriteString
      call Crlf
      mov EDX, OFFSET s10
      call WriteString
      call Crlf
      mov EDX, OFFSET s11
      call WriteString
      call Crlf
      mov EDX, OFFSET s12
      call WriteString
      call Crlf
      mov EDX, OFFSET s13
      call WriteString
      call Crlf
      mov EDX, OFFSET s14
      call WriteString
      call Crlf
      mov EDX, OFFSET s15
      call WriteString
      call Crlf
      mov EDX, OFFSET s16
      call WriteString
      call Crlf
      mov EDX, OFFSET s17
      call WriteString
      call Crlf
      mov EDX, OFFSET s18
      call WriteString
      call Crlf
      mov EDX, OFFSET s19
      call WriteString
      call Crlf
      mov EDX, OFFSET s20
      call WriteString
      call Crlf
      mov EDX, OFFSET s21
      call WriteString
      call Crlf
      ret
    spiderArt endp

; ------------------------------------------------------------------------------

    trollArt proc
      mov EDX, OFFSET t1
      call WriteString
      call Crlf
      mov EDX, OFFSET t2
      call WriteString
      call Crlf
      mov EDX, OFFSET t3
      call WriteString
      call Crlf
      mov EDX, OFFSET t4
      call WriteString
      call Crlf
      mov EDX, OFFSET t5
      call WriteString
      call Crlf
      mov EDX, OFFSET t6
      call WriteString
      call Crlf
      mov EDX, OFFSET t7
      call WriteString
      call Crlf
      mov EDX, OFFSET t8
      call WriteString
      call Crlf
      mov EDX, OFFSET t9
      call WriteString
      call Crlf
      mov EDX, OFFSET t10
      call WriteString
      call Crlf
      mov EDX, OFFSET t11
      call WriteString
      call Crlf
      mov EDX, OFFSET t12
      call WriteString
      call Crlf
      mov EDX, OFFSET t13
      call WriteString
      call Crlf
      mov EDX, OFFSET t14
      call WriteString
      call Crlf
      mov EDX, OFFSET t15
      call WriteString
      call Crlf
      mov EDX, OFFSET t16
      call WriteString
      call Crlf
      mov EDX, OFFSET t17
      call WriteString
      call Crlf
      mov EDX, OFFSET t18
      call WriteString
      call Crlf
      mov EDX, OFFSET t19
      call WriteString
      call Crlf
      mov EDX, OFFSET t20
      call WriteString
      call Crlf
      mov EDX, OFFSET t21
      call WriteString
      call Crlf
      mov EDX, OFFSET t22
      call WriteString
      call Crlf
      mov EDX, OFFSET t23
      call WriteString
      call Crlf
      mov EDX, OFFSET t24
      call WriteString
      call Crlf
      mov EDX, OFFSET t25
      call WriteString
      call Crlf
      mov EDX, OFFSET t26
      call WriteString
      call Crlf
      mov EDX, OFFSET t27
      call WriteString
      call Crlf
      ret
    trollArt endp

; ------------------------------------------------------------------------------

    leftRightArt proc
      mov EDX, OFFSET lr1
      call WriteString
      call Crlf
      mov EDX, OFFSET lr2
      call WriteString
      call Crlf
      mov EDX, OFFSET lr3
      call WriteString
      call Crlf
      mov EDX, OFFSET lr4
      call WriteString
      call Crlf
      mov EDX, OFFSET lr5
      call WriteString
      call Crlf
      mov EDX, OFFSET lr6
      call WriteString
      call Crlf
      mov EDX, OFFSET lr7
      call WriteString
      call Crlf
      mov EDX, OFFSET lr8
      call WriteString
      call Crlf
      mov EDX, OFFSET lr9
      call WriteString
      call Crlf
      mov EDX, OFFSET lr10
      call WriteString
      call Crlf
      mov EDX, OFFSET lr11
      call WriteString
      call Crlf
      mov EDX, OFFSET lr12
      call WriteString
      call Crlf
      mov EDX, OFFSET lr13
      call WriteString
      call Crlf
      mov EDX, OFFSET lr14
      call WriteString
      call Crlf
      mov EDX, OFFSET lr15
      call WriteString
      call Crlf
      mov EDX, OFFSET lr16
      call WriteString
      call Crlf
      mov EDX, OFFSET lr17
      call WriteString
      call Crlf
      mov EDX, OFFSET lr18
      call WriteString
      call Crlf
      mov EDX, OFFSET lr19
      call WriteString
      call Crlf
      mov EDX, OFFSET lr20
      call WriteString
      call Crlf
      mov EDX, OFFSET lr21
      call WriteString
      call Crlf
      mov EDX, OFFSET lr22
      call WriteString
      call Crlf
      mov EDX, OFFSET lr23
      call WriteString
      call Crlf
      mov EDX, OFFSET lr24
      call WriteString
      call Crlf
      mov EDX, OFFSET lr25
      call WriteString
      call Crlf
      ret
    leftRightArt endp

; ------------------------------------------------------------------------------

    leftRightStraightArt proc
      mov EDX, OFFSET lrs1
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs2
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs3
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs4
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs5
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs6
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs7
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs8
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs9
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs10
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs11
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs12
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs13
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs14
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs15
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs16
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs17
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs18
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs19
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs20
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs21
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs22
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs23
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs24
      call WriteString
      call Crlf
      mov EDX, OFFSET lrs25
      call WriteString
      call Crlf
      ret
    leftRightStraightArt endp

; ==============================================================================
; Movement and Code
; ==============================================================================
; Player will awlays face forward!
; Map variable meanings---------------------------------------------------------
; 1			-	Monster Encounter [Bats]
; 11		-	Monster Encounter [Bunny]
; 12		-	Corssroad [turningLRU]
; 13		-	Corssroad [turningLRU]
; 14(Start)	-	Corssroad [turningLR]
; 15		-	Crossroad [turningLRUD]
; 21		-	Monster Encounter [Wolf]
; 31		-	Monster Encounter [Bats]
; 32		-	Crossroads [turningLRD]
; 41		-	Crossroads [turningRU]
; 42		-	Monster Encounter [Giant Spider]
; 43		-	Crossroads [turningLRD]
; 44		-	Monster Encounter [Troll]
; 45		-	End of the Game!!
; 51		-	Monster Encounter [Wolf]
; *******************Any other numbers is out of bounds!!*******************
; Update Map Value Key----------------------------------------------------------
; 0		=	Left	[mapCurrent - 1]
; 1		=	Right	[mapCurrent + 1]
; 2		=	Up		[mapCurrent + 10]
; 3		=	Down	[mapCurrent - 10]
; ==============================================================================

; ==============================================================================
; continueGame PROC
; ------------------------------------------------------------------------------
; Definition:	This procedure called if either a movement occurs or a combat is 
;               completed. This is used to check the "mapCurrent" value and 
;               perform the correct procedure.
; ------------------------------------------------------------------------------
; Sections:		**monsterBats
;               **monsterBunny
;               **monsterWolf
;               **monsterSpider
;               **monsterTroll
;               **turnLR
;               **turnRU
;               **turnLRD
;               **turnLRU
;               **turnLRUD
;               **endGame
; ==============================================================================

continueGame PROC
mov EAX, mapCurrent
call Clrscr

cmp EAX, 1
je monsterBats
cmp EAX, 11
je monsterBunny
cmp EAX, 12
je turnLRU
cmp EAX, 13
je turnLRU
cmp EAX, 14
je turnLR
cmp EAX, 15
je turnLRUD
cmp EAX, 21
je monsterWolf
cmp EAX, 31
je monsterBats
cmp EAX, 32
je turnLRD
cmp EAX, 41
je turnRU
cmp EAX, 42
je monsterSpider
cmp EAX, 43
je turnLRD
cmp EAX, 44
je monsterTroll
cmp EAX, 45
je endGame
cmp EAX, 51
je monsterWolf

; Monsters----------------------------------------------------------------------
monsterBats:
call batsArt
call textBox
monsterAttack bats, batsArray
monsterBunny:
call bunnyArt
call textBox
monsterAttack bunny, bunnyArray
monsterWolf:
call wolfArt
call textBox
monsterAttack wolf, wolfArray
monsterSpider:
call spiderArt
call textBox
monsterAttack giantSpider, giantSpiderArr
monsterTroll:
call trollArt
call textBox
monsterAttack troll, trollArray

; Crossroads--------------------------------------------------------------------
turnLR:
call turningLR
turnRU:
call turningRU
turnLRD:
call turningLRD
turnLRU:
call turningLRU
turnLRUD:
call turningLRUD

; End---------------------------------------------------------------------------
endGame: 
call playerWon

continueGame ENDP

; ==============================================================================
; turningLR PROC
; ------------------------------------------------------------------------------
; Definition:	Writes that the player has encountered a crossroad, then gives	
;				them the choice of turning left or right, also gives them 
;				instructions of what to enter to make their choice and reads the 
;				typed value and stores it into EAX. Then uses that value to 
;               update the "mapCurrent" to the correct value.
; ------------------------------------------------------------------------------
; Sections:		**beginLR
;				**errorLR
;				**updateLR
; ==============================================================================
turningLR PROC
call leftRightArt
call textBox

beginLR:
mov EDX, OFFSET crossroad
call WriteString
call Crlf
mov EDX, OFFSET turnL
call WriteString
call Crlf
mov EDX, OFFSET turnR
call WriteString
call Crlf
mov EDX, OFFSET instTrnLR
call WriteString
call Crlf
mov EDX, OFFSET choice
call WriteString
call ReadInt

mov updateMapValue, EAX
mov EAX, 0
mov direction1, EAX
mov EAX, 1
mov direction2, EAX

errorRead direction1, direction2, updateMapValue

cmp EAX, 0
jne errorLR
jmp updateLR

errorLR:
mov EDX, OFFSET errorPrompt
call WriteString
call Crlf 
call Crlf
jmp beginLR

updateLR:
updateMap updateMapValue
call continueGame
ret
turningLR ENDP

; ==============================================================================
; turningLRUD PROC
; ------------------------------------------------------------------------------
; Definition:	Writes that the player has encountered a crossroad, then gives	
;				them the choice of turning left, right, up, and down also gives 
;				instructions of what to enter to make their choice and reads the 
;				typed value and stores it into EAX. Then uses that value to 
;               update the "mapCurrent" to the correct value.
; ------------------------------------------------------------------------------
; Sections:		**beginLRUD
;				**errorLRUD
;				**updateLRUD
; ==============================================================================
turningLRUD PROC
call leftRightStraightArt
call textBox

beginLRUD:
mov EDX, OFFSET crossroad
call WriteString
call Crlf
mov EDX, OFFSET turnL
call WriteString
call Crlf
mov EDX, OFFSET turnR
call WriteString
call Crlf
mov EDX, OFFSET turnU
call WriteString
call Crlf
mov EDX, OFFSET turnD
call WriteString
call Crlf
mov EDX, OFFSET instTrnLRUD
call WriteString
call Crlf
mov EDX, OFFSET choice
call WriteString
call ReadInt

mov updateMapValue, EAX
mov EAX, 1
mov direction1, EAX
mov EAX, 4
mov direction2, EAX

errorRead direction1, direction2, updateMapValue

cmp EAX, 0
jne errorLRUD
jmp updateLRUD

errorLRUD:
mov EDX, OFFSET errorPrompt
call WriteString
call Crlf 
call Crlf
jmp beginLRUD

updateLRUD:
updateMap updateMapValue
call continueGame
ret
turningLRUD ENDP

; ==============================================================================
; turningLRD PROC
; ------------------------------------------------------------------------------
; Definition:	Writes that the player has encountered a crossroad, then gives	
;				them the choice of turning left, right, and down also gives 
;				instructions of what to enter to make their choice and reads the 
;				typed value and stores it into EAX. Then uses that value to 
;               update the "mapCurrent" to the correct value.
; ------------------------------------------------------------------------------
; Sections:		**beginLRD
;				**errorLRD
;				**updateLRD
; ==============================================================================
turningLRD PROC
call leftRightArt
call textBox

beginLRD:
mov EDX, OFFSET crossroad
call WriteString
call Crlf
mov EDX, OFFSET turnL
call WriteString
call Crlf
mov EDX, OFFSET turnR
call WriteString
call Crlf
mov EDX, OFFSET turnD
call WriteString
call Crlf
mov EDX, OFFSET instTrnLRD
call WriteString
call Crlf
mov EDX, OFFSET choice
call WriteString
call ReadInt

mov updateMapValue, EAX
mov EAX, 0
mov direction1, EAX
mov EAX, 1
mov direction2, EAX
mov EAX, 3
mov direction3, EAX

errorReadLRD direction1, direction2, direction3, updateMapValue

cmp EAX, 0
jne errorLRD
jmp updateLRD

errorLRD:
mov EDX, OFFSET errorPrompt
call WriteString
call Crlf 
call Crlf
jmp beginLRD

updateLRD:
updateMap updateMapValue
call continueGame
ret
turningLRD ENDP

; ==============================================================================
; turningLRU PROC
; ------------------------------------------------------------------------------
; Definition:	Writes that the player has encountered a crossroad, then gives	
;				them the choice of turning left, right, and up also gives 
;				instructions of what to enter to make their choice and reads the 
;				typed value and stores it into EAX. Then uses that value to 
;               update the "mapCurrent" to the correct value.
; ------------------------------------------------------------------------------
; Sections:		**beginLRU
;				**errorLRU
;				**updateLRU
; ==============================================================================
turningLRU PROC
call leftRightStraightArt
call textBox

beginLRU:
mov EDX, OFFSET crossroad
call WriteString
call Crlf
mov EDX, OFFSET turnL
call WriteString
call Crlf
mov EDX, OFFSET turnR
call WriteString
call Crlf
mov EDX, OFFSET turnU
call WriteString
call Crlf
mov EDX, OFFSET instTrnLRU
call WriteString
call Crlf
mov EDX, OFFSET choice
call WriteString
call ReadInt

mov updateMapValue, EAX
mov EAX, 0
mov direction1, EAX
mov EAX, 2
mov direction2, EAX

errorRead direction1, direction2, updateMapValue

cmp EAX, 0
jne errorLRU
jmp updateLRU

errorLRU:
mov EDX, OFFSET errorPrompt
call WriteString
call Crlf 
call Crlf
jmp beginLRU

updateLRU:
updateMap updateMapValue
call continueGame
ret
turningLRU ENDP

; ==============================================================================
; turningRU PROC
; ------------------------------------------------------------------------------
; Definition:	Writes that the player has encountered a crossroad, then gives	
;				them the choice of turning right, and up also gives instructions
;				of what to enter to make their choice and reads the typed value
;				and stores it into EAX. Then uses that value to update the 
;               "mapCurrent" to the correct value.
; ------------------------------------------------------------------------------
; Sections:		**beginRU
;				**errorRU
;				**updateRU
; ==============================================================================
turningRU PROC
call leftRightStraightArt
call textBox

beginRU:
mov EDX, OFFSET crossroad
call WriteString
call Crlf
mov EDX, OFFSET turnR
call WriteString
call Crlf
mov EDX, OFFSET turnU
call WriteString
call Crlf
mov EDX, OFFSET instTrnRU
call WriteString
call Crlf
mov EDX, OFFSET choice
call WriteString
call ReadInt

mov updateMapValue, EAX
mov EAX, 1
mov direction1, EAX
mov EAX, 2
mov direction2, EAX

errorRead direction1, direction2, updateMapValue

cmp EAX, 0
jne errorRU
jmp updateRU

errorRU:
mov EDX, OFFSET errorPrompt
call WriteString
call Crlf 
call Crlf
jmp beginRU

updateRU:
updateMap updateMapValue
call continueGame
ret
turningRU ENDP

; ------------------------------------------------------------------------------
; ----------------------------Monsters and Stats--------------------------------
; ------------------------------------------------------------------------------

; ==============================================================================
; Monster Encounters Code
; ==============================================================================
; Player Begining Stats	-	[ST=5 | SPD=5]
; Monster List:-----------------------------------------------------------------
; Bunny					-	[ST=1 | SPD=1]
; Bats					-	[ST=1 | SPD=1]
; Wolf					-	[ST=4 | SPD=6]
; Giant Spider			-	[ST=7 | SPD=2]
; Troll					-	[ST=6 | SPD=6]
; ==============================================================================

; ==============================================================================
; setArrays PROC
; ------------------------------------------------------------------------------
; Definition:	Sets the stats of the monsters and the player in their 
;               respective array.
; ------------------------------------------------------------------------------
; Sections:		N/A
; ==============================================================================
setArrays proc
	mov ESI, OFFSET playerArray
	mov EBX, 5
	mov [ESI], EBX
	mov [ESI+4], EBX

	mov ESI, OFFSET bunnyArray
	mov EBX, 1
	mov [ESI], EBX
	mov EBX, 1
	mov [ESI+4], EBX

	mov ESI, OFFSET batsArray
	mov EBX, 1
	mov [ESI], EBX
	mov EBX, 2
	mov [ESI+4], EBX

	mov ESI, OFFSET giantSpiderArr
	mov EBX, 7
	mov [ESI], EBX
	mov EBX, 2
	mov [ESI+4], EBX

	mov ESI, OFFSET trollArray
	mov EBX, 6
	mov [ESI], EBX
	mov EBX, 6
	mov [ESI+4], EBX

	mov ESI, OFFSET wolfArray
	mov EBX, 4
	mov [ESI], EBX
	mov EBX, 6
	mov [ESI+4], EBX
	ret
setArrays endp

; ------------------------------------------------------------------------------
; ------------------------------------Other-------------------------------------
; ------------------------------------------------------------------------------

; ==============================================================================
; startGame PROC
; ------------------------------------------------------------------------------
; Definition:	Introduces the player to the game.
; ------------------------------------------------------------------------------
; Sections:		N/A
; ==============================================================================
startGame proc
	mov EDX, OFFSET intro1
	call WriteString
	call Crlf
	mov EDX, OFFSET intro2
	call WriteString
    call Crlf
    call textBox
	ret
startGame endp

; ==============================================================================
; playerWon PROC
; ------------------------------------------------------------------------------
; Definition:	Announce to the player that they won and exit the program.
; ------------------------------------------------------------------------------
; Sections:		N/A
; ==============================================================================
playerWon proc
	mov EDX, OFFSET ending
    call WriteString
    call Crlf
	call ReadInt
	invoke ExitProcess,0
    ret 
playerWon endp

; ==============================================================================
; textBox PROC
; ------------------------------------------------------------------------------
; Definition:	Writes out "textBoxLine" to seperate the ASCII image and text.
; ------------------------------------------------------------------------------
; Sections:		N/A
; ==============================================================================
textBox PROC
mov EDX, OFFSET textBoxLine	
call WriteString
call Crlf
ret
textBox ENDP

; ------------------------------------------------------------------------------
; -------------------------------------Main-------------------------------------
; ------------------------------------------------------------------------------

main proc
	call startGame
	call setArrays
	call turningLR

	invoke ExitProcess,0
main endp
end main