### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:	 LUNAR_LANDMARK_SELECTION_FOR_CM.agc
## Purpose:      Part of the source code for Colossus build 237.
##               This is for the Command Module's (CM) Apollo Guidance
##               Computer (AGC), for Apollo 8.
## Assembler:    yaYUL
## Contact:      Jim Lawton <jim DOT lawton AT gmail DOT com>
## Website:      www.ibiblio.org/apollo/index.html
## Page Scans:   www.ibiblio.org/apollo/ScansForConversion/Colossus237/
## Mod history:  2011-03-06 JL	Adapted from corresponding Colossus 249 file.
##		 2011-04-17 JL	Removed temporary line.

## Page 886
		BANK	31
		SETLOC	R35
		BANK

		COUNT	31/R35

		EBANK=	JLOOPCNT
LNDMKSEL	TC	INTPRET
		RTB
			LOADTIME	# PICK UP TIME SCALED B-28
		STORE	DSPTEM1
		EXIT
DISGET		CAF	V06N34**	# DISPLAY GROUND ELAPSED TIME
		TC	BANKCALL
		CADR	GOMARKF
		TC	ENDEXT		# TERMINATE WITH V34E
		TC	CALCTLS		# PROCEED WITH V33E
		TC	DISGET		# NEW TIME LOADED VIA V25E
CALCTLS		TC	INTPRET
		VLOAD	SET
			RLS
			ERADFLAG	# SET. CONSTANT REARTH (RM)
		STODL	0D		# PD0-5 > RP VECTOR
			RRCSML
		STODL	6D		# PD6-7 > DUMMY TIME
			RRCSML		# MPAC  > NON-ZERO FOR MOON CASE
		SET
			LUNAFLAG	# SET. LUNAR LAT-LONG
		CALL
			RPTOLONG	# RP TO LONG
		DLOAD
			LONG
		STODL	LSLONG		# SAVE LND SITE LONG.
			DSPTEM1
		STCALL	TDEC1		# ADVANCE INTEGRATION TO TIME IN TDEC1
			CSMPREC		# USING PRECISION INTEGRATION
		VLOAD
			RATT1
		STORE	POSVECT		# SAVE POSITION VECTOR SCALED B-27
		STOVL	ALPHAV		# FOR LAT-LONG
			VATT1
		STODL	VELVECT		# SAVE VEL. VECTOR B-5
			TAT
		STCALL	VECTIME		# SAVE TIME
			LAT-LONG	# COMPUTE LAT, LONG, ALT OF S/C  PD>00
		DLOAD	AXT,1		# SAVE S/C LONGITUDE
			LONG
			LSLONG		# XR1 = LANDING SITE LONG--SINUS MEDII, OCE
		STCALL	LONGSAVE	# ANUS PROCELLARUM, MARE TRANQUILLITEATIS
			ELAPTIME	# COMPUTE TL (TIME TO LANDING SITE)
## Page 887
		STORE	DSPTEM1		# SAVE TL FOR OUTPUT TO DSKY
		EXIT		
DISTLS		CAF	V06N31**	# DISPLAY TIME TO LANDING SITE
		TC	BANKCALL
		CADR	GOMARKF
		TC	ENDEXT		# TERMINATE WTIH V34E
		TC	PROCLMKS	# PROCEED WITH V33E
		TC	DISTLS		# ILLEGAL RESPONSE, DO AGAIN
PROCLMKS	TC	INTPRET		# BEGIN LANDMARK PROCESSING
		AXT,1	AXC,2		# SET COUNTERS FOR LOOP CONTROL
			KCOUNT
			JCOUNT
		SXA,2	SET
			JLOOPCNT
			ERADFLAG	# USE MEAN LUNAR RADIUS
KLOOP		SXA,1	SLOAD*
			KLOOPCNT
			BANDTABL +5,1
		STODL	NKVAL		# SAVE LONGITUDE BAND
			DPPOSMAX
		STORE	DELTAL
JLOOPP		AXT,1	XSU,1		# SET XR1 FOR LONGITUDE OF LANDMARK
			LONGTAB -2
			JLOOPCNT
		CALL
			ELAPTIME	# COMPUTE TL (TIME TO LANDMARK)
		STORE	XR1HOLD
		SET	CALL		# COMPUTE LATITUDE AND LONGITUDE OF S/C
			LUNAFLAG	# AT LANDMARK
			LAT-LONG	#                                    PD=00
		LXA,2	
			JLOOPCNT
		DLOAD*	BDSU
			LATTAB -2,2
			LAT
		ABS	PUSH		# DELTA LAT = ABS(LAT - LATJ)        PD=02
		DSU	BPL		# DELTAL OPERATOR THAN DELTA LAT
			DELTAL
			LMKLOOP		# NO
		DLOAD	STADR		#                                    PD=00
		STODL	DELTAL		# DELTA LAT = DELTAL
			XR1HOLD
		STORE	DSPTEM1		# SAVE TIME TO LANDMARK
		SXA,2
			INDEXNUM	# SAVE LANDMARK I.D.
LMKLOOP		INCR,2	SXA,2		# J = J + 2
		OCT	-2
			JLOOPCNT
		SLOAD	DSU
			X2
## Page 888
			NKVAL
		BHIZ	GOTO		# J = NKVAL
			DISLID		# YES, GO DISPLAY LANDMARK ID, MAYBE TL
			JLOOPP		# NO, ONE MORE TIME
DISLID		SLOAD	SR1		# ID = -INDEXNUM/2 + 1
			INDEXNUM
		LXC,2	INCR,2
			MPAC +0
			1D
		SXA,2	EXIT
			LANDMARK
		CAF	V05N70**	# DISPLAY LANDMARK ID
		TC	BANKCALL
		CADR	GOMARKFR
		TC	ENDEXT		# TERMINATE WITH V34E
		TC	DISTTL		# PROCEED WTIH V33E
		TC	NEXTBAND	# RECYCLE WITH V32E
		CAF	FIVE		# BLANK R1 AND R3
		TC	BLANKET
		TC	ENDOFJOB
DISTTL		CAF	V06N34**	# DISPLAY GROUND ELAPSED TIME TO LANDMARK
		TC	BANKCALL
		CADR	GOMARKF
		TC	ENDEXT		# TERMINATE WITH V34E
		TC	NEXTBAND	# PROCEED WITH V33E
		TC	DISTTL		# ILLEGAL RESPONSE, DO AGAIN
NEXTBAND	TC	INTPRET		# MUST WE GO ON
		LXA,1	SSP		# RESTORE COUNTER
			KLOOPCNT
			S1
			1D
		TIX,1	EXIT
			KLOOP		# YES, K = K - 1
		TC	ENDEXT		# K = 0, EXIT R35

## Page 889
ELAPTIME	STQ	SXA,1		# SAVE RETURN AND INDEX 1
			RETLOCN
			XR1HOLD
		SETPD
			0D		#                                    PD=00
		VLOAD	PDDL		#                                    PD=06
			HIUNITZ		# SET UP FOR RP-TO-R
			VECTIME
		PDDL	CALL		#                                    PD=08
			DPPOSMAX
			RP-TO-R		# TRANSFORM PLANETARY TO RCS         PD=00
		PDVL	UNIT		# COMPUTE AND STORE UZ               PD=06
			POSVECT		# POSITION VECTOR OF CM SCALED B-27
		PUSH	VXV		# COMPUTE AND STORE UR = UNIT(R)     PD=12
			UZZ
		VSL1	UNIT
		PUSH	VXV		# COMPUTE AND STORE UW=UNIT(UR X UZ) PD=18
			UZZ
		VSL1	UNIT
		PDVL	VXV		# COMPUTE AND STORE UN=UNIT(UW X UZ) PD=24
			POSVECT		# POSITION VECTOR OF CM SCALED B-27
			VELVECT		# VELOCITY VECTOR OF CM SCALED B-5
		VSL1	UNIT		# COMPUTE AND STORE U = UNIT(R X V)  PD=30
		PDDL	LXC,1		# RESTORE INDEX 1 COMPLEMENTED
			LONGSAVE
			XR1HOLD
		DSU*	DMP
			0,1
			RRCSML
		PUSH	SIN		# DLONG = .997(LONG - LONGJ)         PD=32
		VXSC	VSL1
			UNN		# U:W = UW COS(DLONG) + UN SIN(DLONG)
		PDDL	COS		#                                    PD=36
		VXSC	VSL1
			UW
		VAD	VXV		#                              PD=30,PD=24
		VSL1	UNIT		# UD = UNIT (U:W X U)
		STORE	ALPHAV		# SET UD FOR LAT-LONG--POINT OF CLOSEST
		DOT	SL1		# APPROACH
			URR		# COS(THETA) = (UD . UR)
		STORE	CSTH
		ACOS	SIN		# THETA = ACOS(UD.UR), 0 TO PI
		STOVL	SNTH		# SIN (THETA), 0 TO PI
			URR
		VXV	DOT
			ALPHAV
			24D
		BPL	DLOAD		# CHK (UR X UD).U
			+4D
			SNTH		#  NEG, THETA = 2 PI - THETA
## Page 890
		DCOMP			#  ERGO SIN (THETA) = -SIN (THETA)
		STORE	SNTH
		VLOAD	SET
			POSVECT
			RVSW		# TIME ONLY
		STOVL	RVEC
			VELVECT
		STORE	VVEC
		AXC,1	CALL
			10D		# MOON ONLY
			TIMETHET	# COMPUTE TRANSFER TIME
		BON	BON
			COGAFLAG	# NO SOLUTION SINCE NEAR RECTILINEAR
			ETERROR
			INFINFLG	# NO PHYSICAL SOLUTION EXISTS
			ETERROR
		DLOAD	DAD		# COMPUTE GROUND ELAPSED TIME        PD=00
			VECTIME
			T
		GOTO
			RETLOCN		# EXIT ELAPTIME
ETERROR		DLOAD	GOTO		# RETURN WITH ZERO
			HI6ZEROS
			RETLOCN

## Page 891
# SUBROUTINE TO CONVERT RP (VECTOR IN PLAN. COORD. SYSTEM, EITHER
# EARTH-FIXED OR MOON-FIXED) TO LAT, LONG, ALT.
# CALLING SEQUENCE
#  L       CALL
#  L+1            RPTOLONG
# SUBROUTINES USED
#  RP-TO-R, LAT-LONG
# INPUT
#  PD0-5D = RP VECTOR
#  PD6-7D = TIME
#  MPAC = 0 FOR EARTH, NON-ZERO FOR MOON.
#  ERADFLAG, LUNAFLAG.
# OUTPUT
#  LATITUDE IN LAT      (REVS. B-0)
#  LONGITUDE IN LONG    (REVS. B-0)
#  ALTITUDE IN ALT      (METERS B-29)
		SETLOC	R35A
		BANK

RPTOLONG	STQ	CALL		# SAVE RETURN
			RETLOCN
			RP-TO-R		# CONVERT RP TO R, B-27 FOR MOON
		BOFF	VSR2		# IF LUNAR RESCALE B-27 TO B-29
			LUNAFLAG
			+1
		STODL	ALPHAV
			RRCSML		# MPAC > DUMMY TIME
		CALL
			LAT-LONG
		GOTO
			RETLOCN
		SETLOC	R35
		BANK

BANDTABL	DEC	-12		# +60 DEGREE BAND
		DEC	-22		# +30 DEGREE BAND
		DEC	-32		# +00 DEGREE BAND
		DEC	-42		# -30 DEGREE BAND
		DEC	-52		# -60 DEGREE BAND
RRCSML		2DEC	.997
V06N34**	VN	00634		# ***************************************
V06N31**	VN	00631
V05N70**	VN	00570
KCOUNT		EQUALS	5D
JCOUNT		EQUALS	2D
UNN		EQUALS	18D
UW		EQUALS	12D
URR		EQUALS	6D
UZZ		EQUALS	0D

## Page 892
#          **** TEMPORARY VALUES FOR LANDMARK TABLES-LEVINE/SAPONARO****

#               LATTAB HAS LATITUDES THAT GO FROM +8 TO -8 DEGREES
#               LONGTAB HAS LONGITUDES THAT GO FROM +60 TO -60 DEGREES
#               LATTAB AND LONGTAB ARE SCALED REVOLUTIONS B0
#               ALTTAB HAS ALTITUDES MEASURED ABOVE THE MEAN LUNAR RADIUS
#               ALTTAB IS SCALED IN METERS B-29

		COUNT	31/LNDMK
LATTAB		2DEC	-.015231481	#   2     5  29 S
		2DEC	.002175926	#   3     0  47 N
		2DEC	.002361111	#   4     0  51 N
		2DEC	-.001851852	#   5     0  40 S
		2DEC	.002777778	#   6     1  00 N
		2DEC	-.002916667	#   7     1  03 S
		2DEC	-.005462963	#  10     1  58 S
		2DEC	.006666667	#  11     2  24 N
		2DEC	.018935185	#  12     6  49 N
		2DEC	.00250		#  13     0  54 N
		2DEC	.003425926	#  14     1  14 N
		2DEC	-.004722222	#  15     1  42 S
		2DEC	-.001481481	#  16     0  32 S
		2DEC	.003101852	#  17     1  07	N
		2DEC	.003472222	#  20     1  15 N 	N
		2DEC	-.0125		#  21     4  30 S
		2DEC	.000277777	#  22     0  06 N
		2DEC	.011342592	#  23     4  05 N
		2DEC	.003981481	#  24     1  26 N
		2DEC	-.008009259	#  25     2  53 S
		2DEC	.003240741	#  26     1  10 N
## Page 893
		2DEC	-.005694444	#  27     2  03 S
		2DEC	.002268518	#  30     0  49 N
		2DEC	-.007824074	#  31     2  49 S
		2DEC	.005416667	#  32     1  57 N
LONGTAB		2DEC	.161157407	#   2     58  01 E
		2DEC	.160046296	#   3     57  37 E
		2DEC	.143287037	#   4     51  35 E
		2DEC	.116018518	#   5     41  46 E
		2DEC	.106851852	#   6     38  28 E
		2DEC	.104675926	#   7     37  41 E
		2DEC	.094537037	#  10     34  02 E
		2DEC	.094212963	#  11     33  55 E
		2DEC	.091805555	#  12     33  03 E
		2DEC	.083564815	#  13     30  05 E
		2DEC	.065833333	#  14     23  42 E
		2DEC	.050925926	#  15     18  20 E
		2DEC	.042638889	#  16     15  21 E
		2DEC	.023009259	#  17      8  17 E
		2DEC	.010416667	#  20      3  45 E
		2DEC	.000046296	#  21      0  01 E
		2DEC	-.003703704	#  22      1  20 W
		2DEC	-.020694444	#  23      7  27 W
		2DEC	-.023703704	#  24      8  32 W
		2DEC	-.051435185	#  25     18  31 W
		2DEC	-.068055556	#  26     24  30 W
## Page 894
		2DEC	-.085092593	#  27     30  38 W
		2DEC	-.100833333	#  30     36  18 W
		2DEC	-.101944444	#  31     36  42 W
		2DEC	-.117407407	#  32     42  16 W
ALTTAB		2DEC	-2090 B-29	#  2
		2DEC	-2090 B-29	#  3
		2DEC	-1790 B-29	#  4
		2DEC	-1090 B-29	#  5
		2DEC	-940 B-29	#  6
		2DEC	-290 B-29	#  7
		2DEC	-290 B-29	#  10
		2DEC	-1549 B-29	#  11
		2DEC	-890 B-29	#  12
		2DEC	-1490 B-29	#  13
		2DEC	-3230 B-29	#  14
		2DEC	5110 B-29	#  15
		2DEC	6910 B-29	#  16
		2DEC	5110 B-29	#  17
		2DEC	3010 B-29	#  20
		2DEC	3910 B-29	#  21
		2DEC	-935 B-29	#  22
		2DEC	2360 B-29	#  23
		2DEC	2510 B-29	#  24
		2DEC	210 B-29	#  25
		2DEC	960 B-29	#  26
## Page 895
		2DEC	1310 B-29	#  27
		2DEC	1410 B-29	#  30
		2DEC	-2624 B-29	#  31
		2DEC	-2445 B-29	#  32
