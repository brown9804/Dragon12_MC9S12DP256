; Memory maps and register equates
; Choose one of DBUG12MAP (normal operation under DBUG12)
;               EEPROMMAP  (DBUG12 in EEPROM mode)
;               FLASHMAP   (Program loaded into Flash ROM)
DBUG12MAP equ 0        ; Memory mode is DBUG12MAP
; EEPROMMAP equ 0         ; Memory mode is EEPROMMAP
#ifdef DBUG12MAP
REGBASE        equ        $0        ; register base
DATASTART equ        $1000        ; Start of data memory
DATAEND  equ        $2000        ; Stack pointer initial value (end of data RAM area)
PRSTART equ        $2000        ; Start of program memory (might be ROM)
PREND        equ        $3BFF        ; End of program memory

; Functions in D-Bug12
Getchar        equ        $EE84        ; Implemented in emulator
Putchar equ        $EE86   ; Implemented in emulator
Printf  equ     $EE88
GetCmdLine equ  $EE8A   ; FAR call
Sscanhex equ        $EE8E   ; FAR call
Isxdigit equ    $EE92
Toupper equ     $EE94
Isalpha equ     $EE96
Strlen  equ     $EE98
Strcpy  equ     $EE9A
Out2hex equ     $EE9C   ; FAR call
Out4hex equ     $EEA0   ; FAR call
SetUserVector equ $EEA4 ; No longer used
WriteEEByte equ $EEA6   ; FAR call
EraseEE equ     $EEAA   ; FAR call
ReadMem equ     $EEAE   ; FAR call
WriteMem equ    $EEB2   ; FAR call

VECTORTABLE equ $3E00        ; Vectors go here SHOULD ALSO INITIALIZE AT RUNTIME
STATICVECTORS equ 0        ; Define vectors statically (in "ROM")
INITIALIZEVECTORS equ 0        ; Initialize vectors at runtime
#endif

#ifdef EEPROMMAP
REGBASE        equ        $0        ; register base MAY BE MOVED TO MAKE FULL EEPROM ACCESSABLE
DATASTART equ        $1000        ; Start of data memory
DATAEND  equ        $3E00        ; Stack pointer initial value (end of data RAM area)
PRSTART equ        $400        ; Start of program memory
PREND        equ        $FFF        ; End of program memory

VECTORTABLE equ $3E00        ; Vectors go here -- MUST BE INITIALIZED AT RUNTIME
INITIALIZEVECTORS equ 0        ; Initialize vectors at runtime
#endif

#ifdef FLASHMAP
REGBASE        equ        $0        ; register base MAY BE MOVED TO MAKE FULL EEPROM ACCESSABLE
DATASTART equ        $1000        ; Start of data memory
DATAEND  equ        $4000        ; Stack pointer initial value (end of data RAM area)
PRSTART equ        $8000        ; Start of program memory
; Note -- there are problems using the current free assemblers with paged memory
; Best bet is to use logical addresses $8000 up only, set page register to 3E,
; Change S1 records for $8000-BFFF to S2 records for page 3E and S1 records for $C000-$EFFF to
; page 3F. Program startup vector goes in EFFE, and needs to be iin page 3F so PPAGE can be changed. 
PREND        equ        $EF7F        ; End of program memory

VECTORTABLE equ $EF80        ; Vectors go here -- MUST BE INITIALIZED STATICALLY
STATICVECTORS equ 0        ; Define vectors statically (in "ROM")
#endif


RAMSTART equ        DATASTART ; For compatibility
RAMEND equ        DATAEND   

UserRsrv0x80 equ (0*2)+VECTORTABLE
UserRsrv0x82 equ (1*2)+VECTORTABLE
UserRsrv0x84 equ (2*2)+VECTORTABLE
UserRsrv0x86 equ (3*2)+VECTORTABLE
UserRsrv0x88 equ (4*2)+VECTORTABLE
UserRsrv0x8a equ (5*2)+VECTORTABLE
UserPWMShDn equ (6*2)+VECTORTABLE
UserPortP equ (7*2)+VECTORTABLE
UserMSCAN4Tx equ (8*2)+VECTORTABLE
UserMSCAN4Rx equ (9*2)+VECTORTABLE
UserMSCAN4Errs equ (10*2)+VECTORTABLE
UserMSCAN4Wake equ (11*2)+VECTORTABLE
UserMSCAN3Tx equ (12*2)+VECTORTABLE
UserMSCAN3Rx equ (13*2)+VECTORTABLE
UserMSCAN3Errs equ (14*2)+VECTORTABLE
UserMSCAN3Wake equ (15*2)+VECTORTABLE
UserMSCAN2Tx equ (16*2)+VECTORTABLE
UserMSCAN2Rx equ (17*2)+VECTORTABLE
UserMSCAN2Errs equ (18*2)+VECTORTABLE
UserMSCAN2Wake equ (19*2)+VECTORTABLE
UserMSCAN1Tx equ (20*2)+VECTORTABLE
UserMSCAN1Rx equ (21*2)+VECTORTABLE
UserMSCAN1Errs equ (22*2)+VECTORTABLE
UserMSCAN1Wake equ (23*2)+VECTORTABLE
UserMSCAN0Tx equ (24*2)+VECTORTABLE
UserMSCAN0Rx equ (25*2)+VECTORTABLE
UserMSCAN0Errs equ (26*2)+VECTORTABLE
UserMSCAN0Wake equ (27*2)+VECTORTABLE
UserFlash equ (28*2)+VECTORTABLE
UserEEPROM equ (29*2)+VECTORTABLE
UserSPI2 equ (30*2)+VECTORTABLE
UserSPI1 equ (31*2)+VECTORTABLE
UserIIC equ (32*2)+VECTORTABLE
UserDLC equ (33*2)+VECTORTABLE
UserSCME equ (34*2)+VECTORTABLE
UserCRG equ (35*2)+VECTORTABLE
UserPAccBOv equ (36*2)+VECTORTABLE
UserModDwnCtr equ (37*2)+VECTORTABLE
UserPortH equ (38*2)+VECTORTABLE
UserPortJ equ (39*2)+VECTORTABLE
UserAtoD1 equ (40*2)+VECTORTABLE
UserAtoD0 equ (41*2)+VECTORTABLE
UserSCI1 equ (42*2)+VECTORTABLE
UserSCI0 equ (43*2)+VECTORTABLE
UserSPI0 equ (44*2)+VECTORTABLE
UserPAccEdge equ (45*2)+VECTORTABLE
UserPAccOvf equ (46*2)+VECTORTABLE
UserTimerOvf equ (47*2)+VECTORTABLE
UserTimerCh7 equ (48*2)+VECTORTABLE
UserTimerCh6 equ (49*2)+VECTORTABLE
UserTimerCh5 equ (50*2)+VECTORTABLE
UserTimerCh4 equ (51*2)+VECTORTABLE
UserTimerCh3 equ (52*2)+VECTORTABLE
UserTimerCh2 equ (53*2)+VECTORTABLE
UserTimerCh1 equ (54*2)+VECTORTABLE
UserTimerCh0 equ (55*2)+VECTORTABLE
UserRTI equ (56*2)+VECTORTABLE
UserIRQ equ (57*2)+VECTORTABLE
UserXIRQ equ (58*2)+VECTORTABLE
UserSWI equ (59*2)+VECTORTABLE
UserTrap equ (60*2)+VECTORTABLE


*
*
*  HC12 i/o register locations (9s12dp256)
*
*
PORTA:          equ REGBASE+0   ;port a = address lines a8 - a15
PORTB:          equ REGBASE+1   ;port b = address lines a0 - a7
DDRA:           equ REGBASE+2   ;port a direction register
DDRB:           equ REGBASE+3   ;port b direction register

PORTE:          equ REGBASE+8   ;port e = mode,irq and control signals
DDRE:           equ REGBASE+9   ;port e direction register
PEAR:           equ REGBASE+$a  ;port e assignments
MODE:           equ REGBASE+$b  ;mode register
PUCR:           equ REGBASE+$c  ;port pull-up control register
RDRIV:          equ REGBASE+$d  ;port reduced drive control register
EBICTL:                equ REGBASE+$e  ;e stretch control

INITRM:         equ REGBASE+$10 ;ram location register
INITRG:         equ REGBASE+$11 ;register location register
INITEE:         equ REGBASE+$12 ;eeprom location register
MISC:           equ REGBASE+$13 ;miscellaneous mapping control
MTST0:          equ REGBASE+$14 ; reserved
ITCR:           equ REGBASE+$15 ;interrupt test control register
ITEST:          equ REGBASE+$16 ;interrupt test register
MTST1:          equ REGBASE+$17 ; reserved

PARTIDH:        equ REGBASE+$1a ;part id high
PARTIDL:        equ REGBASE+$1b ;part id low
MEMSIZ0:        equ REGBASE+$1c ;memory size
MEMSIZ1:        equ REGBASE+$1d ;memory size
IRQCR:          equ REGBASE+$1e ;interrupt control register
INTCR:          equ REGBASE+$1e ;interrupt control register (old name)
HPRIO:          equ REGBASE+$1f ;high priority reg

BKPCT0:         equ REGBASE+$28 ;break control register
BKPCT1:         equ REGBASE+$29 ;break control register
BKP0X:          equ REGBASE+$2a ; break 0 index register
BKP0H:          equ REGBASE+$2b ; break 0 pointer high
BRP0L:          equ REGBASE+$2c ; break 0 pointer low
BKP1X:          equ REGBASE+$2d ; break 1 index register
BKP1H:          equ REGBASE+$2e ; break 1 pointer high
BRP1L:          equ REGBASE+$2f ; break 1 pointer low
PPAGE:                equ REGBASE+$30 ;program page register

PORTK:                equ REGBASE+$32 ;port k data
DDRK:                equ REGBASE+$33 ;port k direction

SYNR:           equ REGBASE+$34 ; synthesizer / multiplier register
REFDV:          equ REGBASE+$35 ; reference divider register
CTFLG:          equ REGBASE+$36 ; reserved
CRGFLG:         equ REGBASE+$37 ; pll flags register
CRGINT:         equ REGBASE+$38 ; pll interrupt register
CLKSEL:         equ REGBASE+$39 ; clock select register
PLLCTL:         equ REGBASE+$3a ; pll control register
RTICTL:         equ REGBASE+$3b ;real time interrupt control
COPCTL:         equ REGBASE+$3c ;watchdog control
FORBYP:         equ REGBASE+$3d ;
CTCTL:          equ REGBASE+$3e ;
ARMCOP:         equ REGBASE+$3f ;cop reset register

TIOS:           equ REGBASE+$40 ;timer input/output select
CFORC:          equ REGBASE+$41 ;timer compare force
OC7M:           equ REGBASE+$42 ;timer output compare 7 mask
OC7D:           equ REGBASE+$43 ;timer output compare 7 data
TCNT:           equ REGBASE+$44 ;timer counter register hi
*TCNT:          equ REGBASE+$45 ;timer counter register lo
TSCR:           equ REGBASE+$46 ;timer system control register (Old Name)
TSCR1:          equ REGBASE+$46 ;timer system control register
TTOV:           equ REGBASE+$47 ;reserved
TCTL1:          equ REGBASE+$48 ;timer control register 1
TCTL2:          equ REGBASE+$49 ;timer control register 2
TCTL3:          equ REGBASE+$4a ;timer control register 3
TCTL4:          equ REGBASE+$4b ;timer control register 4
TMSK1:          equ REGBASE+$4c ;timer interrupt mask 1 (Old Name)
TIE:            equ REGBASE+$4c ;timer interrupt mask 1
TMSK2:          equ REGBASE+$4d ;timer interrupt mask 2 (Old Name)
TSCR2:          equ REGBASE+$4d ;timer interrupt mask 2
TFLG1:          equ REGBASE+$4e ;timer flags 1
TFLG2:          equ REGBASE+$4f ;timer flags 2
TC0:            equ REGBASE+$50 ;timer capture/compare register 0
TC1:            equ REGBASE+$52 ;timer capture/compare register 1
TC2:            equ REGBASE+$54 ;timer capture/compare register 2
TC3:            equ REGBASE+$56 ;timer capture/compare register 3
TC4:            equ REGBASE+$58 ;timer capture/compare register 4
TC5:            equ REGBASE+$5a ;timer capture/compare register 5
TC6:            equ REGBASE+$5c ;timer capture/compare register 6
TC7:            equ REGBASE+$5e ;timer capture/compare register 7
PACTL:          equ REGBASE+$60 ;pulse accumulator controls
PAFLG:          equ REGBASE+$61 ;pulse accumulator flags
PACN3:          equ REGBASE+$62 ;pulse accumulator counter 3
PACN2:          equ REGBASE+$63 ;pulse accumulator counter 2
PACN1:          equ REGBASE+$64 ;pulse accumulator counter 1
PACN0:          equ REGBASE+$65 ;pulse accumulator counter 0
MCCTL:          equ REGBASE+$66 ;modulus down conunter control
MCFLG:          equ REGBASE+$67 ;down counter flags
ICPAR:          equ REGBASE+$68 ;input pulse accumulator control
DLYCT:          equ REGBASE+$69 ;delay count to down counter
ICOVW:          equ REGBASE+$6a ;input control overwrite register
ICSYS:          equ REGBASE+$6b ;input control system control

TIMTST:         equ REGBASE+$6d ;timer test register

PBCTL:          equ REGBASE+$70 ; pulse accumulator b control
PBFLG:          equ REGBASE+$71 ; pulse accumulator b flags
PA3H:           equ REGBASE+$72 ; pulse accumulator holding register 3
PA2H:           equ REGBASE+$73 ; pulse accumulator holding register 2
PA1H:           equ REGBASE+$74 ; pulse accumulator holding register 1
PA0H:           equ REGBASE+$75 ; pulse accumulator holding register 0
MCCNT:          equ REGBASE+$76 ; modulus down counter register
*MCCNTL:        equ REGBASE+$77 ; low byte
TCOH:           equ REGBASE+$78 ; capture 0 holding register
TC1H:           equ REGBASE+$7a ; capture 1 holding register
TC2H:           equ REGBASE+$7c ; capture 2 holding register
TC3H:           equ REGBASE+$7e ; capture 3 holding register

ATD0CTL0:       equ REGBASE+$80 ;adc control 0 (reserved)
ATD0CTL1:       equ REGBASE+$81 ;adc control 1 (reserved)
ATD0CTL2:       equ REGBASE+$82 ;adc control 2
ATD0CTL3:       equ REGBASE+$83 ;adc control 3
ATD0CTL4:       equ REGBASE+$84 ;adc control 4
ATD0CTL5:       equ REGBASE+$85 ;adc control 5
ATD0STAT:       equ REGBASE+$86 ;adc status register hi
ATD0STAT0:      equ REGBASE+$86 ;adc status register hi
ATD0STAT1:      equ REGBASE+$8b ;adc status register lo
ATD0TEST:       equ REGBASE+$88 ;adc test (reserved)
*atd0test       equ REGBASE+$89 ;

ATD0DIEN:        equ REGBASE+$8d ;

PORTAD:         equ REGBASE+$8f ;port adc = input only
ADR00H:         equ REGBASE+$90 ;adc result 0 register
ADR01H:         equ REGBASE+$92 ;adc result 1 register
ADR02H:         equ REGBASE+$94 ;adc result 2 register
ADR03H:         equ REGBASE+$96 ;adc result 3 register
ADR04H:         equ REGBASE+$98 ;adc result 4 register
ADR05H:         equ REGBASE+$9a ;adc result 5 register
ADR06H:         equ REGBASE+$9c ;adc result 6 register
ADR07H:         equ REGBASE+$9e ;adc result 7 register

PWME:                equ REGBASE+$a0 ;pwm enable
PWMPOL:         equ REGBASE+$a1 ;pwm polarity
PWMCLK:         equ REGBASE+$a2 ;pwm clock select register
PWMPRCLK:       equ REGBASE+$a3 ;pwm prescale clock select register
PWMCAE:         equ REGBASE+$a4 ;pwm center align select register
PWMCTL:         equ REGBASE+$a5 ;pwm control register
PWMTST:         equ REGBASE+$a6 ;reserved
PWMPRSC:        equ REGBASE+$a7 ;reserved
PWMSCLA:        equ REGBASE+$a8 ;pwm scale a
PWMSCLB:        equ REGBASE+$a9 ;pwm scale b
PWMSCNTA:       equ REGBASE+$aa ;reserved
PWMSCNTB:       equ REGBASE+$ab ;reserved
PWMCNT0:        equ REGBASE+$ac ;pwm channel 0 counter
PWMCNT1:        equ REGBASE+$ad ;pwm channel 1 counter
PWMCNT2:        equ REGBASE+$ae ;pwm channel 2 counter
PWMCNT3:        equ REGBASE+$af ;pwm channel 3 counter
PWMCNT4:        equ REGBASE+$b0 ;pwm channel 4 counter
PWMCNT5:        equ REGBASE+$b1 ;pwm channel 5 counter
PWMCNT6:        equ REGBASE+$b2 ;pwm channel 6 counter
PWMCNT7:        equ REGBASE+$b3 ;pwm channel 7 counter
PWMPER0:        equ REGBASE+$b4 ;pwm channel 0 period
PWMPER1:        equ REGBASE+$b5 ;pwm channel 1 period
PWMPER2:        equ REGBASE+$b6 ;pwm channel 2 period
PWMPER3:        equ REGBASE+$b7 ;pwm channel 3 period
PWMPER4:        equ REGBASE+$b8 ;pwm channel 4 period
PWMPER5:        equ REGBASE+$b9 ;pwm channel 5 period
PWMPER6:        equ REGBASE+$ba ;pwm channel 6 period
PWMPER7:        equ REGBASE+$bb ;pwm channel 7 period
PWMDTY0:        equ REGBASE+$bc ;pwm channel 0 duty cycle
PWMDTY1:        equ REGBASE+$bd ;pwm channel 1 duty cycle
PWMDTY2:        equ REGBASE+$be ;pwm channel 2 duty cycle
PWMDTY3:        equ REGBASE+$bf ;pwm channel 3 duty cycle
PWMDTY4:        equ REGBASE+$c0 ;pwm channel 4 duty cycle
PWMDTY5:        equ REGBASE+$c1 ;pwm channel 5 duty cycle
PWMDTY6:        equ REGBASE+$c2 ;pwm channel 6 duty cycle
PWMDTY7:        equ REGBASE+$c3 ;pwm channel 7 duty cycle
PWMSDN:         equ REGBASE+$c4 ;pwm shutdown register

SC0BDH:         equ REGBASE+$c8 ;sci 0 baud reg hi byte
SC0BDL:         equ REGBASE+$c9 ;sci 0 baud reg lo byte
SC0CR1:         equ REGBASE+$ca ;sci 0 control1 reg
SC0CR2:         equ REGBASE+$cb ;sci 0 control2 reg
SC0SR1:         equ REGBASE+$cc ;sci 0 status reg 1
SC0SR2:         equ REGBASE+$cd ;sci 0 status reg 2
SC0DRH:         equ REGBASE+$ce ;sci 0 data reg hi
SC0DRL:         equ REGBASE+$cf ;sci 0 data reg lo

SC1BDH:         equ REGBASE+$d0 ;sci 1 baud reg hi byte
SC1BDL:         equ REGBASE+$d1 ;sci 1 baud reg lo byte
SC1CR1:         equ REGBASE+$d2 ;sci 1 control1 reg
SC1CR2:         equ REGBASE+$d3 ;sci 1 control2 reg
SC1SR1:         equ REGBASE+$d4 ;sci 1 status reg 1
SC1SR2:         equ REGBASE+$d5 ;sci 1 status reg 2
SC1DRH:         equ REGBASE+$d6 ;sci 1 data reg hi
SC1DRL:         equ REGBASE+$d7 ;sci 1 data reg lo

SPI0CR1:        equ REGBASE+$d8 ;spi 0 control1 reg
SPI0CR2:        equ REGBASE+$d9 ;spi 0 control2 reg
SPI0BR:         equ REGBASE+$da ;spi 0 baud reg
SPI0SR:         equ REGBASE+$db ;spi 0 status reg hi
SP0DR:          equ REGBASE+$dd ;spi 0 data reg  FOR COMPATIBILITY
SPI0DR:          equ REGBASE+$dd ;spi 0 data reg

IBAD:                equ REGBASE+$e0 ;i2c bus address register
IBFD:                equ REGBASE+$e1 ;i2c bus frequency divider
IBCR:                equ REGBASE+$e2 ;i2c bus control register
IBSR:                equ REGBASE+$e3 ;i2c bus status register
IBDR:                equ REGBASE+$e4 ;i2c bus message data register

DLCBCR1:        equ REGBASE+$e8 ;bdlc control regsiter 1
DLCBSVR:        equ REGBASE+$e9 ;bdlc state vector register
DLCBCR2:        equ REGBASE+$ea ;bdlc control register 2
DLCBDR:                equ REGBASE+$eb ;bdlc data register
DLCBARD:        equ REGBASE+$ec ;bdlc analog delay register
DLCBRSR:        equ REGBASE+$ed ;bdlc rate select register
DLCSCR:                equ REGBASE+$ee ;bdlc control register
DLCBSTAT:        equ REGBASE+$ef ;bdlc status register

SPI1CR1:        equ REGBASE+$f0 ;spi 1 control1 reg
SPI1CR2:        equ REGBASE+$f1 ;spi 1 control2 reg
SPI1BR:         equ REGBASE+$f2 ;spi 1 baud reg
SPI1SR:         equ REGBASE+$f3 ;spi 1 status reg hi
SPI1DR:          equ REGBASE+$f5 ;spi 1 data reg
SP1DR:          equ REGBASE+$f5 ;spi 1 data reg   FOR COMPATIBILITY

SPI2CR1:        equ REGBASE+$f8 ;spi 2 control1 reg
SPI2CR2:        equ REGBASE+$f9 ;spi 2 control2 reg
SPI2BR:         equ REGBASE+$fa ;spi 2 baud reg
SPI2SR:         equ REGBASE+$fb ;spi 2 status reg hi
SPI2DR:         equ REGBASE+$fd ;spi 2 data reg
SP2DR:          equ REGBASE+$fd ;spi 2 data reg   FOR COMPATIBILITY

FCLKDIV:        equ REGBASE+$100 ;flash clock divider
FSEC:                equ REGBASE+$101 ;flash security register

FCNFG:                equ REGBASE+$103 ;flash configuration register
FPROT:                equ REGBASE+$104 ;flash protection register
FSTAT:                equ REGBASE+$105 ;flash status register
FCMD:                equ REGBASE+$106 ;flash command register

ECLKDIV:        equ REGBASE+$110 ;eeprom clock divider

ECNFG:                equ REGBASE+$113 ;eeprom configuration register
EPROT:                equ REGBASE+$114 ;eeprom protection register
ESTAT:                equ REGBASE+$115 ;eeprom status register
ECMD:                equ REGBASE+$116 ;eeprom command register

ATD1CTL0:       equ REGBASE+$120 ;adc1 control 0 (reserved)
ATD1CTL1:       equ REGBASE+$121 ;adc1 control 1 (reserved)
ATD1CTL2:       equ REGBASE+$122 ;adc1 control 2
ATD1CTL3:       equ REGBASE+$123 ;adc1 control 3
ATD1CTL4:       equ REGBASE+$124 ;adc1 control 4
ATD1CTL5:       equ REGBASE+$125 ;adc1 control 5
ATD1STAT0:      equ REGBASE+$126 ;adc1 status register hi
ATD1STAT1:      equ REGBASE+$12b ;adc1 status register lo
ATD1TEST:       equ REGBASE+$128 ;adc1 test (reserved)
*atd1test       equ REGBASE+$129 ;

ATDDIEN:        equ REGBASE+$12d ;adc1 input enable register

PORTAD1:        equ REGBASE+$12f ;port adc1 = input only
ADR10H:         equ REGBASE+$130 ;adc1 result 0 register
ADR11H:         equ REGBASE+$132 ;adc1 result 1 register
ADR12H:         equ REGBASE+$134 ;adc1 result 2 register
ADR13H:         equ REGBASE+$136 ;adc1 result 3 register
ADR14H:         equ REGBASE+$138 ;adc1 result 4 register
ADR15H:         equ REGBASE+$13a ;adc1 result 5 register
ADR16H:         equ REGBASE+$13c ;adc1 result 6 register
ADR17H:         equ REGBASE+$13e ;adc1 result 7 register

CAN0CTL0:        equ REGBASE+$140 ;can0 control register 0
CAN0CTL1:        equ REGBASE+$141 ;can0 control register 1
CAN0BTR0:        equ REGBASE+$142 ;can0 bus timing register 0
CAN0BTR1:        equ REGBASE+$143 ;can0 bus timing register 1
CAN0RFLG:        equ REGBASE+$144 ;can0 receiver flags
CAN0RIER:        equ REGBASE+$145 ;can0 receiver interrupt enables
CAN0TFLG:        equ REGBASE+$146 ;can0 transmit flags
CAN0TIER:        equ REGBASE+$147 ;can0 transmit interrupt enables
CAN0TARQ:        equ REGBASE+$148 ;can0 transmit message abort control
CAN0TAAK:        equ REGBASE+$149 ;can0 transmit message abort status
CAN0TBEL:        equ REGBASE+$14a ;can0 transmit buffer select
CAN0IDAC:        equ REGBASE+$14b ;can0 identfier acceptance control

CAN0RERR:        equ REGBASE+$14e ;can0 receive error counter
CAN0TERR:        equ REGBASE+$14f ;can0 transmit error counter
CAN0IDA0:        equ REGBASE+$150 ;can0 identifier acceptance register 0
CAN0IDA1:        equ REGBASE+$151 ;can0 identifier acceptance register 1
CAN0IDA2:        equ REGBASE+$152 ;can0 identifier acceptance register 2
CAN0IDA3:        equ REGBASE+$153 ;can0 identifier acceptance register 3
CAN0IDM0:        equ REGBASE+$154 ;can0 identifier mask register 0
CAN0IDM1:        equ REGBASE+$155 ;can0 identifier mask register 1
CAN0IDM2:        equ REGBASE+$156 ;can0 identifier mask register 2
CAN0IDM3:        equ REGBASE+$157 ;can0 identifier mask register 3
CAN0IDA4:        equ REGBASE+$158 ;can0 identifier acceptance register 4
CAN0IDA5:        equ REGBASE+$159 ;can0 identifier acceptance register 5
CAN0IDA6:        equ REGBASE+$15a ;can0 identifier acceptance register 6
CAN0IDA7:        equ REGBASE+$15b ;can0 identifier acceptance register 7
CAN0IDM4:        equ REGBASE+$15c ;can0 identifier mask register 4
CAN0IDM5:        equ REGBASE+$15d ;can0 identifier mask register 5
CAN0IDM6:        equ REGBASE+$15e ;can0 identifier mask register 6
CAN0IDM7:        equ REGBASE+$15f ;can0 identifier mask register 7
CAN0RXFG:        equ REGBASE+$160 ;can0 rx foreground buffer thru +$16f
CAN0TXFG:        equ REGBASE+$170 ;can0 tx foreground buffer thru +$17f

CAN1CTL0:        equ REGBASE+$180 ;can1 control register 0
CAN1CTL1:        equ REGBASE+$181 ;can1 control register 1
CAN1BTR0:        equ REGBASE+$182 ;can1 bus timing register 0
CAN1BTR1:        equ REGBASE+$183 ;can1 bus timing register 1
CAN1RFLG:        equ REGBASE+$184 ;can1 receiver flags
CAN1RIER:        equ REGBASE+$185 ;can1 receiver interrupt enables
CAN1TFLG:        equ REGBASE+$186 ;can1 transmit flags
CAN1TIER:        equ REGBASE+$187 ;can1 transmit interrupt enables
CAN1TARQ:        equ REGBASE+$188 ;can1 transmit message abort control
CAN1TAAK:        equ REGBASE+$189 ;can1 transmit message abort status
CAN1TBEL:        equ REGBASE+$18a ;can1 transmit buffer select
CAN1IDAC:        equ REGBASE+$18b ;can1 identfier acceptance control

CAN1RERR:        equ REGBASE+$18e ;can1 receive error counter
CAN1TERR:        equ REGBASE+$18f ;can1 transmit error counter
CAN1IDA0:        equ REGBASE+$190 ;can1 identifier acceptance register 0
CAN1IDA1:        equ REGBASE+$191 ;can1 identifier acceptance register 1
CAN1IDA2:        equ REGBASE+$192 ;can1 identifier acceptance register 2
CAN1IDA3:        equ REGBASE+$193 ;can1 identifier acceptance register 3
CAN1IDM0:        equ REGBASE+$194 ;can1 identifier mask register 0
CAN1IDM1:        equ REGBASE+$195 ;can1 identifier mask register 1
CAN1IDM2:        equ REGBASE+$196 ;can1 identifier mask register 2
CAN1IDM3:        equ REGBASE+$197 ;can1 identifier mask register 3
CAN1IDA4:        equ REGBASE+$198 ;can1 identifier acceptance register 4
CAN1IDA5:        equ REGBASE+$199 ;can1 identifier acceptance register 5
CAN1IDA6:        equ REGBASE+$19a ;can1 identifier acceptance register 6
CAN1IDA7:        equ REGBASE+$19b ;can1 identifier acceptance register 7
CAN1IDM4:        equ REGBASE+$19c ;can1 identifier mask register 4
CAN1IDM5:        equ REGBASE+$19d ;can1 identifier mask register 5
CAN1IDM6:        equ REGBASE+$19e ;can1 identifier mask register 6
CAN1IDM7:        equ REGBASE+$19f ;can1 identifier mask register 7
CAN1RXFG:        equ REGBASE+$1a0 ;can1 rx foreground buffer thru +$1af
CAN1TXFG:        equ REGBASE+$1b0 ;can1 tx foreground buffer thru +$1bf

CAN2CTL0:        equ REGBASE+$1c0 ;can2 control register 0
CAN2CTL1:        equ REGBASE+$1c1 ;can2 control register 1
CAN2BTR0:        equ REGBASE+$1c2 ;can2 bus timing register 0
CAN2BTR1:        equ REGBASE+$1c3 ;can2 bus timing register 1
CAN2RFLG:        equ REGBASE+$1c4 ;can2 receiver flags
CAN2RIER:        equ REGBASE+$1c5 ;can2 receiver interrupt enables
CAN2TFLG:        equ REGBASE+$1c6 ;can2 transmit flags
CAN2TIER:        equ REGBASE+$1c7 ;can2 transmit interrupt enables
CAN2TARQ:        equ REGBASE+$1c8 ;can2 transmit message abort control
CAN2TAAK:        equ REGBASE+$1c9 ;can2 transmit message abort status
CAN2TBEL:        equ REGBASE+$1ca ;can2 transmit buffer select
CAN2IDAC:        equ REGBASE+$1cb ;can2 identfier acceptance control

CAN2RERR:        equ REGBASE+$1ce ;can2 receive error counter
CAN2TERR:        equ REGBASE+$1cf ;can2 transmit error counter
CAN2IDA0:        equ REGBASE+$1d0 ;can2 identifier acceptance register 0
CAN2IDA1:        equ REGBASE+$1d1 ;can2 identifier acceptance register 1
CAN2IDA2:        equ REGBASE+$1d2 ;can2 identifier acceptance register 2
CAN2IDA3:        equ REGBASE+$1d3 ;can2 identifier acceptance register 3
CAN2IDM0:        equ REGBASE+$1d4 ;can2 identifier mask register 0
CAN2IDM1:        equ REGBASE+$1d5 ;can2 identifier mask register 1
CAN2IDM2:        equ REGBASE+$1d6 ;can2 identifier mask register 2
CAN2IDM3:        equ REGBASE+$1d7 ;can2 identifier mask register 3
CAN2IDA4:        equ REGBASE+$1d8 ;can2 identifier acceptance register 4
CAN2IDA5:        equ REGBASE+$1d9 ;can2 identifier acceptance register 5
CAN2IDA6:        equ REGBASE+$1da ;can2 identifier acceptance register 6
CAN2IDA7:        equ REGBASE+$1db ;can2 identifier acceptance register 7
CAN2IDM4:        equ REGBASE+$1dc ;can2 identifier mask register 4
CAN2IDM5:        equ REGBASE+$1dd ;can2 identifier mask register 5
CAN2IDM6:        equ REGBASE+$1de ;can2 identifier mask register 6
CAN2IDM7:        equ REGBASE+$1df ;can2 identifier mask register 7
CAN2RXFG:        equ REGBASE+$1e0 ;can2 rx foreground buffer thru +$1ef
CAN2TXFG:        equ REGBASE+$1f0 ;can2 tx foreground buffer thru +$1ff

CAN3CTL0:        equ REGBASE+$200 ;can3 control register 0
CAN3CTL1:        equ REGBASE+$201 ;can3 control register 1
CAN3BTR0:        equ REGBASE+$202 ;can3 bus timing register 0
CAN3BTR1:        equ REGBASE+$203 ;can3 bus timing register 1
CAN3RFLG:        equ REGBASE+$204 ;can3 receiver flags
CAN3RIER:        equ REGBASE+$205 ;can3 receiver interrupt enables
CAN3TFLG:        equ REGBASE+$206 ;can3 transmit flags
CAN3TIER:        equ REGBASE+$207 ;can3 transmit interrupt enables
CAN3TARQ:        equ REGBASE+$208 ;can3 transmit message abort control
CAN3TAAK:        equ REGBASE+$209 ;can3 transmit message abort status
CAN3TBEL:        equ REGBASE+$20a ;can3 transmit buffer select
CAN3IDAC:        equ REGBASE+$20b ;can3 identfier acceptance control

CAN3RERR:        equ REGBASE+$20e ;can3 receive error counter
CAN3TERR:        equ REGBASE+$20f ;can3 transmit error counter
CAN3IDA0:        equ REGBASE+$210 ;can3 identifier acceptance register 0
CAN3IDA1:        equ REGBASE+$211 ;can3 identifier acceptance register 1
CAN3IDA2:        equ REGBASE+$212 ;can3 identifier acceptance register 2
CAN3IDA3:        equ REGBASE+$213 ;can3 identifier acceptance register 3
CAN3IDM0:        equ REGBASE+$214 ;can3 identifier mask register 0
CAN3IDM1:        equ REGBASE+$215 ;can3 identifier mask register 1
CAN3IDM2:        equ REGBASE+$216 ;can3 identifier mask register 2
CAN3IDM3:        equ REGBASE+$217 ;can3 identifier mask register 3
CAN3IDA4:        equ REGBASE+$218 ;can3 identifier acceptance register 4
CAN3IDA5:        equ REGBASE+$219 ;can3 identifier acceptance register 5
CAN3IDA6:        equ REGBASE+$21a ;can3 identifier acceptance register 6
CAN3IDA7:        equ REGBASE+$21b ;can3 identifier acceptance register 7
CAN3IDM4:        equ REGBASE+$21c ;can3 identifier mask register 4
CAN3IDM5:        equ REGBASE+$21d ;can3 identifier mask register 5
CAN3IDM6:        equ REGBASE+$21e ;can3 identifier mask register 6
CAN3IDM7:        equ REGBASE+$21f ;can3 identifier mask register 7
CAN3RXFG:        equ REGBASE+$220 ;can3 rx foreground buffer thru +$22f
CAN3TXFG:        equ REGBASE+$230 ;can3 tx foreground buffer thru +$23f

PTT:                equ REGBASE+$240 ;portt data register
PTIT:                equ REGBASE+$241 ;portt input register
DDRT:                equ REGBASE+$242 ;portt direction register
RDRT:                equ REGBASE+$243 ;portt reduced drive register
PERT:                equ REGBASE+$244 ;portt pull device enable
PPST:                equ REGBASE+$245 ;portt pull polarity select

PTS:                equ REGBASE+$248 ;ports data register
PTIS:                equ REGBASE+$249 ;ports input register
DDRS:                equ REGBASE+$24a ;ports direction register
RDRS:                equ REGBASE+$24b ;ports reduced drive register
PERS:                equ REGBASE+$24c ;ports pull device enable
PPSS:                equ REGBASE+$24d ;ports pull polarity select
WOMS:                equ REGBASE+$24e ;ports wired or mode register

PTM:                equ REGBASE+$250 ;portm data register
PTIM:                equ REGBASE+$251 ;portm input register
DDRM:                equ REGBASE+$252 ;portm direction register
RDRM:                equ REGBASE+$253 ;portm reduced drive register
PERM:                equ REGBASE+$254 ;portm pull device enable
PPSM:                equ REGBASE+$255 ;portm pull polarity select
WOMM:                equ REGBASE+$256 ;portm wired or mode register
MODRR:                equ REGBASE+$257 ;portm module routing register

PTP:                equ REGBASE+$258 ;portp data register
PTIP:                equ REGBASE+$259 ;portp input register
DDRP:                equ REGBASE+$25a ;portp direction register
RDRP:                equ REGBASE+$25b ;portp reduced drive register
PERP:                equ REGBASE+$25c ;portp pull device enable
PPSP:                equ REGBASE+$25d ;portp pull polarity select
PIEP:                equ REGBASE+$25e ;portp interrupt enable register
PIFP:                equ REGBASE+$25f ;portp interrupt flag register

PTH:                equ REGBASE+$260 ;porth data register
PTIH:                equ REGBASE+$261 ;porth input register
DDRH:                equ REGBASE+$262 ;porth direction register
RDRH:                equ REGBASE+$263 ;porth reduced drive register
PERH:                equ REGBASE+$264 ;porth pull device enable
PPSH:                equ REGBASE+$265 ;porth pull polarity select
PIEH:                equ REGBASE+$266 ;porth interrupt enable register
PIFH:                equ REGBASE+$267 ;porth interrupt flag register

PTJ:                equ REGBASE+$268 ;portj data register
PTIJ:                equ REGBASE+$269 ;portj input register
DDRJ:                equ REGBASE+$26a ;portj direction register
RDRJ:                equ REGBASE+$26b ;portj reduced drive register
PERJ:                equ REGBASE+$26c ;portj pull device enable
PPSJ:                equ REGBASE+$26d ;portj pull polarity select
PIEJ:                equ REGBASE+$26e ;portj interrupt enable register
PIFJ:                equ REGBASE+$26f ;portj interrupt flag register

CAN4CTL0:        equ REGBASE+$280 ;can4 control register 0
CAN4CTL1:        equ REGBASE+$281 ;can4 control register 1
CAN4BTR0:        equ REGBASE+$282 ;can4 bus timing register 0
CAN4BTR1:        equ REGBASE+$283 ;can4 bus timing register 1
CAN4RFLG:        equ REGBASE+$284 ;can4 receiver flags
CAN4RIER:        equ REGBASE+$285 ;can4 receiver interrupt enables
CAN4TFLG:        equ REGBASE+$286 ;can4 transmit flags
CAN4TIER:        equ REGBASE+$287 ;can4 transmit interrupt enables
CAN4TARQ:        equ REGBASE+$288 ;can4 transmit message abort control
CAN4TAAK:        equ REGBASE+$289 ;can4 transmit message abort status
CAN4TBEL:        equ REGBASE+$28a ;can4 transmit buffer select
CAN4IDAC:        equ REGBASE+$28b ;can4 identfier acceptance control

CAN4RERR:        equ REGBASE+$28e ;can4 receive error counter
CAN4TERR:        equ REGBASE+$28f ;can4 transmit error counter
CAN4IDA0:        equ REGBASE+$290 ;can4 identifier acceptance register 0
CAN4IDA1:        equ REGBASE+$291 ;can4 identifier acceptance register 1
CAN4IDA2:        equ REGBASE+$292 ;can4 identifier acceptance register 2
CAN4IDA3:        equ REGBASE+$293 ;can4 identifier acceptance register 3
CAN4IDM0:        equ REGBASE+$294 ;can4 identifier mask register 0
CAN4IDM1:        equ REGBASE+$295 ;can4 identifier mask register 1
CAN4IDM2:        equ REGBASE+$296 ;can4 identifier mask register 2
CAN4IDM3:        equ REGBASE+$297 ;can4 identifier mask register 3
CAN4IDA4:        equ REGBASE+$298 ;can4 identifier acceptance register 4
CAN4IDA5:        equ REGBASE+$299 ;can4 identifier acceptance register 5
CAN4IDA6:        equ REGBASE+$29a ;can4 identifier acceptance register 6
CAN4IDA7:        equ REGBASE+$29b ;can4 identifier acceptance register 7
CAN4IDM4:        equ REGBASE+$29c ;can4 identifier mask register 4
CAN4IDM5:        equ REGBASE+$29d ;can4 identifier mask register 5
CAN4IDM6:        equ REGBASE+$29e ;can4 identifier mask register 6
CAN4IDM7:        equ REGBASE+$29f ;can4 identifier mask register 7
CAN4RXFG:        equ REGBASE+$2a0 ;can4 rx foreground buffer thru +$2af
CAN4TXFG:        equ REGBASE+$2b0 ;can4 tx foreground buffer thru +$2bf

* end registers